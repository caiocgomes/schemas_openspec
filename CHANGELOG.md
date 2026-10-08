# Changelog

Versões do kit. Cada schema tem a própria `version:` no `schema.yaml`, que muda só quando o schema muda.

## 4.0.0 (08/10/2026)

- `data-eng` v3 em Data TDD: Model Interface no design (schema dos stubs); validation vira plano de testes com fixture isolada por teste, teste de grão obrigatório, "Breaks if" por mutação de modelo ou de fixture, falha esperada e marcação de testes que passam em tabela vazia; tasks abre com portão vermelho (testes, fixtures, contrato e stubs com zero linhas, falha por asserção, commit `test(red)`, parada para aprovação); testes e fixtures congelados após o vermelho; checagem de mutação por modelo alterado; novo artefato `evidence` pós-apply com `DECISION: PASS | FAIL`.
- Mudanças em andamento com `data-eng` v2 passam a ver o artefato `evidence` pendente depois de `tasks`.

## 3.0.1 (07/10/2026)

- O instalador ignora arquivos criados pelo sistema operacional (`.DS_Store`, `._*`, `Thumbs.db`, `desktop.ini`) ao comparar o schema do projeto com o do kit. Antes, um `.DS_Store` bastava para o aviso "version 2 difere do kit (version 2)".
- Quando o schema do projeto difere de verdade, o aviso lista os arquivos diferentes e explica quando usar `--force`.

## 3.0.0 (07/10/2026)

- O instalador deixa a máquina no perfil expandido do OpenSpec por padrão: perfil `custom` com os doze workflows, backup da config anterior, restauração em caso de falha e `openspec update` no projeto. `--no-profile` desliga.
- Arquivo `VERSION` e este changelog; o instalador mostra a versão do kit.

## 2.0.0 (07/10/2026)

- Kit publicado em `caiocgomes/schemas_openspec` (público). Instalação em um passo via `curl`, sem `gh`.

## 1.0.0 (07/10/2026)

- Cinco schemas: `sdd-tdd` (v3), `bugfix` (v2), `data-eng` (v2), `research` (v2), `spike` (v2).
- `install.sh`: baixa ou atualiza o kit, confere a versão do OpenSpec, instala os schemas no projeto e valida.
