# Changelog

Versões do kit. Cada schema tem a própria `version:` no `schema.yaml`, que muda só quando o schema muda.

## 3.0.0 (07/10/2026)

- O instalador deixa a máquina no perfil expandido do OpenSpec por padrão: perfil `custom` com os doze workflows, backup da config anterior, restauração em caso de falha e `openspec update` no projeto. `--no-profile` desliga.
- Arquivo `VERSION` e este changelog; o instalador mostra a versão do kit.

## 2.0.0 (07/10/2026)

- Kit publicado em `caiocgomes/schemas_openspec` (público). Instalação em um passo via `curl`, sem `gh`.

## 1.0.0 (07/10/2026)

- Cinco schemas: `sdd-tdd` (v3), `bugfix` (v2), `data-eng` (v2), `research` (v2), `spike` (v2).
- `install.sh`: baixa ou atualiza o kit, confere a versão do OpenSpec, instala os schemas no projeto e valida.
