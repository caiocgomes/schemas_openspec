#!/usr/bin/env bash
# openspec-kit: baixa (ou atualiza) o kit e instala os schemas do OpenSpec num projeto.
#
# Uso:
#   install.sh [<raiz-do-projeto>] [--schemas a,b,...] [--default <schema>] [--force] [--no-update]
#
# Sem argumentos: projeto no diretório atual, todos os schemas do kit.
#   --schemas    lista separada por vírgula (padrão: todos)
#   --default    define `schema:` em openspec/config.yaml
#   --force      substitui schemas já instalados que estejam diferentes da versão do kit
#   --no-update  não atualiza a cópia local do kit antes de instalar
#
# Variáveis de ambiente:
#   OPENSPEC_KIT_REPO  repositório no GitHub (padrão: caiocgomes/openspec-kit)
#   OPENSPEC_KIT_HOME  onde o kit é baixado (padrão: ~/.local/share/openspec-kit)
#
# Saída: 0 ok; 1 erro; 3 algum schema instalado difere do kit e não foi substituído (use --force).
set -euo pipefail

KIT_REPO="${OPENSPEC_KIT_REPO:-caiocgomes/openspec-kit}"
KIT_HOME="${OPENSPEC_KIT_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/openspec-kit}"
MIN_NOSPEC_VERSION="1.10.0"   # research e spike precisam disso para o validate aceitar change sem delta

PROJECT_ROOT="."
SCHEMAS_ARG=""
DEFAULT_SCHEMA=""
FORCE=0
UPDATE=1

fail() { echo "erro: $*" >&2; exit 1; }
info() { echo "$*"; }

usage() { sed -n '2,18p' "${BASH_SOURCE[0]:-$0}" 2>/dev/null | sed 's/^# \{0,1\}//' || true; }

while [ $# -gt 0 ]; do
  case "$1" in
    --schemas) [ $# -ge 2 ] || fail "--schemas precisa de uma lista"; SCHEMAS_ARG="$2"; shift 2 ;;
    --schemas=*) SCHEMAS_ARG="${1#*=}"; shift ;;
    --default) [ $# -ge 2 ] || fail "--default precisa de um nome"; DEFAULT_SCHEMA="$2"; shift 2 ;;
    --default=*) DEFAULT_SCHEMA="${1#*=}"; shift ;;
    --force) FORCE=1; shift ;;
    --no-update) UPDATE=0; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) fail "opção desconhecida: $1" ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

# --- 1. Localiza ou baixa o kit -------------------------------------------------
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
KIT_DIR=""
if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
  candidate="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
  [ -d "$candidate/openspec/schemas" ] && KIT_DIR="$candidate"
fi

if [ -z "$KIT_DIR" ]; then
  # Rodando via pipe (curl ou gh api): usa a cópia gerenciada em KIT_HOME.
  KIT_DIR="$KIT_HOME"
  if [ ! -d "$KIT_DIR/.git" ]; then
    info "baixando $KIT_REPO em $KIT_DIR"
    mkdir -p "$(dirname "$KIT_DIR")"
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
      gh repo clone "$KIT_REPO" "$KIT_DIR" -- --quiet
    else
      git clone --quiet "https://github.com/$KIT_REPO.git" "$KIT_DIR" \
        || fail "não consegui clonar $KIT_REPO. Repositório privado? Rode 'gh auth login' e tente de novo."
    fi
    UPDATE=0
  fi
fi

if [ "$UPDATE" -eq 1 ] && [ "$KIT_DIR" = "$KIT_HOME" ] && [ -d "$KIT_DIR/.git" ]; then
  if ! git -C "$KIT_DIR" pull --ff-only --quiet 2>/dev/null; then
    echo "aviso: não consegui atualizar $KIT_DIR; seguindo com a cópia local" >&2
  fi
fi

SRC_SCHEMAS="$KIT_DIR/openspec/schemas"
[ -d "$SRC_SCHEMAS" ] || fail "schemas não encontrados em $SRC_SCHEMAS"
KIT_REV="$(git -C "$KIT_DIR" rev-parse --short HEAD 2>/dev/null || echo "sem-git")"
info "kit: $KIT_DIR ($KIT_REV)"

# --- 2. Confere o OpenSpec -----------------------------------------------------
command -v openspec >/dev/null 2>&1 \
  || fail "openspec não está no PATH. Instale com: npm install -g @fission-ai/openspec@latest"
OS_VERSION="$(openspec --version 2>/dev/null | head -1 | tr -d '[:space:]')"
info "openspec $OS_VERSION"

version_ge() {  # version_ge A B -> verdadeiro se A >= B (semver numérico)
  local a b i
  IFS=. read -r -a a <<< "$1"
  IFS=. read -r -a b <<< "$2"
  for i in 0 1 2; do
    local x="${a[$i]:-0}" y="${b[$i]:-0}"
    x="${x%%[!0-9]*}"; y="${y%%[!0-9]*}"
    [ "${x:-0}" -gt "${y:-0}" ] && return 0
    [ "${x:-0}" -lt "${y:-0}" ] && return 1
  done
  return 0
}

# --- 3. Confere o projeto ------------------------------------------------------
PROJECT_ROOT="$(cd "$PROJECT_ROOT" 2>/dev/null && pwd)" || fail "diretório do projeto não existe: $PROJECT_ROOT"
[ -d "$PROJECT_ROOT/openspec" ] || fail "não existe $PROJECT_ROOT/openspec. Rode antes, dentro do projeto: openspec init"
DST_SCHEMAS="$PROJECT_ROOT/openspec/schemas"

AVAILABLE=()
for d in "$SRC_SCHEMAS"/*/; do AVAILABLE+=("$(basename "$d")"); done

SELECTED=()
if [ -n "$SCHEMAS_ARG" ]; then
  IFS=, read -r -a SELECTED <<< "$SCHEMAS_ARG"
  for s in "${SELECTED[@]}"; do
    [ -f "$SRC_SCHEMAS/$s/schema.yaml" ] || fail "schema '$s' não existe no kit. Disponíveis: ${AVAILABLE[*]}"
  done
else
  SELECTED=("${AVAILABLE[@]}")
fi

for s in "${SELECTED[@]}"; do
  if { [ "$s" = research ] || [ "$s" = spike ]; } && ! version_ge "$OS_VERSION" "$MIN_NOSPEC_VERSION"; then
    fail "'$s' exige OpenSpec >= $MIN_NOSPEC_VERSION (instalado: $OS_VERSION). Atualize com 'npm install -g @fission-ai/openspec@latest' ou omita esse schema com --schemas."
  fi
done

schema_version() { sed -n 's/^version:[[:space:]]*//p' "$1/schema.yaml" 2>/dev/null | head -1; }

# --- 4. Copia ------------------------------------------------------------------
mkdir -p "$DST_SCHEMAS"
INSTALLED=(); UPDATED=(); UNCHANGED=(); SKIPPED=()
for s in "${SELECTED[@]}"; do
  src="$SRC_SCHEMAS/$s"; dst="$DST_SCHEMAS/$s"
  if [ -e "$dst" ]; then
    if diff -rq "$src" "$dst" >/dev/null 2>&1; then
      UNCHANGED+=("$s"); continue
    fi
    if [ "$FORCE" -ne 1 ]; then
      echo "aviso: $s instalado (version $(schema_version "$dst")) difere do kit (version $(schema_version "$src")); mantido. Use --force para substituir." >&2
      SKIPPED+=("$s"); continue
    fi
    rm -rf "$dst"; cp -R "$src" "$dst"; UPDATED+=("$s")
  else
    cp -R "$src" "$dst"; INSTALLED+=("$s")
  fi
done

# --- 5. Valida o que está no projeto --------------------------------------------
cd "$PROJECT_ROOT"
for s in "${SELECTED[@]}"; do
  [ -d "$DST_SCHEMAS/$s" ] || continue
  openspec schema validate "$s" >/dev/null 2>&1 || fail "openspec schema validate $s falhou. Rode o comando para ver o erro."
  openspec schema which "$s" 2>/dev/null | grep -q '^Source: project' \
    || fail "$s não resolve a partir do projeto. Rode: openspec schema which $s"
done

# --- 6. Schema padrão ------------------------------------------------------------
if [ -n "$DEFAULT_SCHEMA" ]; then
  [ -d "$DST_SCHEMAS/$DEFAULT_SCHEMA" ] || fail "--default $DEFAULT_SCHEMA: esse schema não está instalado no projeto"
  CONFIG="$PROJECT_ROOT/openspec/config.yaml"
  if [ -f "$CONFIG" ] && grep -qE '^schema:' "$CONFIG"; then
    TMP="$(mktemp)"
    sed -E "s/^schema:.*/schema: $DEFAULT_SCHEMA/" "$CONFIG" > "$TMP" && mv "$TMP" "$CONFIG"
  elif [ -f "$CONFIG" ]; then
    TMP="$(mktemp)"
    { echo "schema: $DEFAULT_SCHEMA"; cat "$CONFIG"; } > "$TMP" && mv "$TMP" "$CONFIG"
  else
    echo "schema: $DEFAULT_SCHEMA" > "$CONFIG"
  fi
  info "padrão do projeto: schema: $DEFAULT_SCHEMA"
fi

# --- 7. Resumo -----------------------------------------------------------------
[ ${#INSTALLED[@]} -gt 0 ] && info "instalados:    ${INSTALLED[*]}"
[ ${#UPDATED[@]} -gt 0 ]   && info "atualizados:   ${UPDATED[*]}"
[ ${#UNCHANGED[@]} -gt 0 ] && info "já em dia:     ${UNCHANGED[*]}"
[ ${#SKIPPED[@]} -gt 0 ]   && info "não alterados: ${SKIPPED[*]} (diferem do kit; use --force)"
info "commite openspec/schemas/ no projeto para o time receber os mesmos schemas."

[ ${#SKIPPED[@]} -gt 0 ] && exit 3
exit 0
