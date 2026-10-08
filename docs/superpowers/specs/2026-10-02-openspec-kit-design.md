# openspec-kit: schemas e profile do OpenSpec para o time

Data: 02/10/2026. Status: aguardando revisão. Repositório: `~/Dev/openspec`.

## 1. Objetivo

O `openspec-kit` é um pacote distribuído pelo GitLab que dá ao time de dados e engenharia um conjunto de schemas do OpenSpec, um profile de workflows comum e um verificador mecânico. Sucesso significa que qualquer pessoa clona um projeto que adotou o kit e encontra o workflow pronto, sem configurar nada além de instalar a versão fixada do OpenSpec, e que o CI do projeto reprova uma change que finge cumprir o schema sem cumprir.

O público é o time que trabalha com dbt, Dataform e Spark/PySpark, além de engenharia de software. As ferramentas de agente variam por pessoa (Claude Code, Cursor, Codex e outras), então o kit não depende de nenhuma delas: tudo é nativo do OpenSpec mais scripts de shell e Python da biblioteca padrão.

O kit absorve o repositório `~/Dev/sdd-tdd` (schema `sdd-tdd` v2, instalador, verificador e fixture), que passa a apontar para cá.

## 2. Decisões e por quê

**Distribuição por cópia no projeto.** O OpenSpec 1.14.0 não tem gerenciador de pacotes, `extends`, import nem schema remoto; a resolução é projeto, depois usuário, depois embutido. Uma cópia só no diretório do usuário quebra para quem clona o repositório (`Unknown schema`). O instalador copia os schemas para `openspec/schemas/<nome>/` e o resultado vai para o commit do projeto.

**Cinco schemas.** `sdd-tdd`, `bugfix`, `data-eng`, `research` e `spike`. O critério para existir um schema separado é haver um artefato que não pode ser pulado e que não existe nos outros, porque artefato no grafo tem a existência cobrada pelo `status`, enquanto regra no `config.yaml` é só texto no prompt. Por esse critério o experimento de ML virou o modo `model` do `research`: os grafos eram iguais, e o OpenSpec não tem herança entre schemas, então dois schemas significariam templates duplicados para sempre.

**Schemas agnósticos de stack, com tabela de equivalência.** O time usa dbt, Dataform e Spark. As instruções descrevem o mecanismo (teste de lógica com fixture antes do build, contrato executável, versionamento com depreciação) e trazem a tabela de equivalentes por stack. A stack de cada projeto vai no `context` do `config.yaml` do projeto.

**Profile do time obrigatório e versão do OpenSpec fixada.** Medido na 1.14.0: com os arquivos gerados no commit, cada `openspec update` reescreve o conjunto de comandos do projeto para o profile de quem rodou, com diff de cerca de 14 arquivos por troca. Uma config global com a lista de workflows vazia fez o `update` apagar todos os comandos do projeto, e o `update` seguinte de outra pessoa respondeu `No configured tools found`. Os arquivos de skill gerados carregam `generatedBy: "<versão>"`, então versões diferentes do OpenSpec também produzem diff. O kit fixa o profile e a versão do OpenSpec e confere os dois no CI.

**O CI é o gate, não o OpenSpec.** O OpenSpec confere existência de arquivo. O `archive` trata erro de validação como aviso não bloqueante e arquiva tarefas incompletas com `--yes`; a skill de archive gerada manda o agente "não bloquear em avisos". O comando `verify` gerado é declaradamente consultivo e só lê artefatos do grafo. O relato da NashTech sobre spec-kit em engenharia de dados registra que o agente "can generate a convincing completion message even when the underlying artifact is incomplete". O verificador `kit.py check` no CI do projeto é o que transforma o schema em cobrança.

**Escolha de schema é manual.** O comando `propose` gerado usa o schema padrão do projeto, a menos que o usuário peça outro pelo nome; o `context` do `config.yaml` não consegue rotear, porque o schema é escolhido antes de qualquer instrução ser carregada. O kit aceita esse custo: nomes curtos, um padrão por projeto e uma página de decisão (`docs/qual-schema-usar.md`).

## 3. Fatos verificados no OpenSpec 1.14.0

Todos medidos em projetos descartáveis com `npx @fission-ai/openspec@1.14.0` e config global isolada por `XDG_CONFIG_HOME`.

1. O `schema.yaml` do `sdd-tdd` v2 valida e resolve a partir do projeto.
2. `openspec/config.yaml` aceita `schema`, `context`, `rules` por artefato e `operations.apply.guidance` / `operations.archive.guidance`.
3. O profile é config global por usuário (`openspec config path`); `init --profile` aceita só `core` ou `custom`. `config set workflows "a,b"` não gera lista; o kit escreve o JSON diretamente.
4. `openspec update` remove comandos e skills de workflows que não estão no profile ativo e reescreve os que ficam. A detecção de ferramentas depende dos arquivos já presentes no projeto.
5. `openspec update --force` oferece apagar arquivos legados fora do projeto (`~/.codex/prompts`). O kit nunca usa `--force` e roda `update` com stdin fechado.
6. Schema sem artefato `specs` valida, recebe `skip_specs` no `.openspec.yaml` e arquiva com zero deltas.
7. Schema com artefato `specs` e change sem delta: `status` mostra `specs` pendente e `validate` falha com "Change must have at least one delta"; o `archive` mostra o mesmo erro como aviso e arquiva.
8. `archive` com tarefa incompleta pede confirmação; sem terminal, falha; com `--yes`, arquiva com aviso.
9. O OpenSpec ignora `openspec/kit/` (`list`, `validate --all`, `schemas` e `doctor` limpos).
10. `validate` aceita `--all`, `--changes`, `--specs`, `--strict`, `--no-interactive` e `--json`.
11. Um artefato de resultado colocado no grafo fica pronto assim que suas dependências existem, antes de qualquer execução. Resultado não pode ser artefato do grafo.
12. Arquivos fora do grafo dentro da pasta da change (`results.md`, `deviations.md`, `findings.md`, `model-card.md`, `runs/*.json`, `runs/*.log`) não afetam `status`, `validate --strict`, `archive` nem `validate --archived`, e são movidos para o archive junto com a change.
13. O `archive` move os arquivos sem reescrever o conteúdo: os SHA-256 dos artefatos são os mesmos antes e depois.
14. `git log --follow` acompanha um arquivo da change através da mudança para `openspec/changes/archive/`.
15. Um artefato que depende de `tasks` mas não está em `apply.requires` aparece como `[ ]` pendente no `status` e como "Next", enquanto o `apply` fica `ready`. O `validate` passa sem ele, e o `archive` pela CLI arquiva sem aviso; só a skill de archive do agente avisa sobre artefato incompleto.
16. A skill `propose` gerada pela 1.14.0 proíbe editar código do projeto durante o planejamento ("Do not edit project code"). Um artefato de planejamento que escreva código de teste entra em contradição com ela; por isso o portão vermelho do `sdd-tdd` mora no início do `apply`.
17. Chave desconhecida no `.openspec.yaml` é ignorada, mas reprova no `validate --strict`. Metadados do kit (tier, modo) ficam nos artefatos, não ali. O `.openspec.yaml` aceita `retire_capabilities: true`, que autoriza o archive a apagar a spec de uma capability esvaziada.
18. O `spec-driven` atual limita a descrição de requisito a 500 caracteres (`validate --strict` reprova acima) e aceita caminhos de capability aninhados (`specs/<domínio>/<nome>/spec.md`).

## 4. Estrutura do repositório do kit

```
openspec/schemas/
  sdd-tdd/        schema.yaml + templates/
  bugfix/         schema.yaml + templates/
  data-eng/       schema.yaml + templates/
  research/       schema.yaml + templates/
  spike/          schema.yaml + templates/
kit/              conteúdo copiado para openspec/kit/ de cada projeto
  kit.py          check, freeze, run e stats (Python, só biblioteca padrão)
  profile_drift.sh
  team-profile.json
  OPENSPEC_VERSION
  gitlab-ci.snippet.yml
install.sh        instala ou atualiza o kit num projeto
setup-dev.sh      aplica o profile do time na config global da máquina
tests/
  fixtures/<schema>/valid/<change>/        change mínima que passa
  fixtures/<schema>/invalid/<regra>/       uma change por regra, que deve falhar
  test_kit.py                              testes do kit.py
  e2e.sh                                   ciclo completo por schema no OpenSpec fixado
docs/qual-schema-usar.md
README.md, INSTALL.md, CHANGELOG.md
.gitlab-ci.yml
.gitignore        inclui tasks/ (lições locais do agente, não vão para o time), .venv/, __pycache__/
```

Documentação em PT-BR. Instruções e templates dos schemas em inglês, como no `sdd-tdd`. Os tokens que o `kit.py` lê nos artefatos são fixos em inglês (seção 7.3); a prosa dos artefatos segue o idioma do projeto.

## 5. Instalador

```
install.sh [<raiz-do-projeto>] [--schemas <a,b,...>|all] [--default <schema>] [--force]
```

Sem argumentos: projeto no diretório atual, todos os schemas, padrão `sdd-tdd`.

Passos, cada um com falha explícita e mensagem de correção:

1. Confere `openspec` no PATH e versão igual a `kit/OPENSPEC_VERSION`; em divergência, falha mostrando `npm install -g @fission-ai/openspec@<versão>`.
2. Confere que `<projeto>/openspec/` existe; senão manda rodar `openspec init`.
3. Para cada schema selecionado: se `openspec/schemas/<nome>/` existe e não há `--force`, falha mostrando a `version:` instalada. Com `--force`, substitui.
4. Copia `kit/` para `openspec/kit/` (sempre substitui, porque o conteúdo é do kit).
5. Ajusta `schema:` no `openspec/config.yaml`: troca a linha existente ou insere no topo, preservando o resto. Com `--force` e sem `--default`, mantém o padrão atual.
6. Grava `openspec/kit/manifest.json` com versão do kit, schemas e suas `version:`, padrão e data.
7. Roda `openspec schema validate <nome>` e confere `openspec schema which <nome>` com `Source: project` para cada schema.
8. Se o projeto tem ferramentas de agente configuradas, roda `openspec/kit/profile_drift.sh --fix` para gerar os comandos com o profile do time.
9. Imprime o trecho de CI (`gitlab-ci.snippet.yml`) e o lembrete de commit. Não edita `.gitlab-ci.yml` do projeto.

Bash com `set -euo pipefail`, `shellcheck` limpo, edição de JSON via `node` (já garantido pelo OpenSpec). Windows não é suportado nem testado.

## 6. Profile do time

### 6.1 `team-profile.json`

```json
{
  "profile": "custom",
  "delivery": "both",
  "workflows": ["propose", "explore", "new", "continue", "apply", "update", "verify", "sync", "archive"]
}
```

É o core da 1.14.0 (propose, explore, apply, update, sync, archive) mais `new` e `continue` para o modo passo a passo, que permite revisar cada artefato antes do seguinte, e `verify` como revisão semântica consultiva. O `ff` fica de fora porque gera todos os artefatos de uma vez, sem revisão humana entre eles, o que esvazia o pré-registro do `research` e a análise de impacto do `data-eng`. O `propose` continua no profile por ser o comando de entrada do core e serve bem a `sdd-tdd`, `bugfix` e `spike`.

### 6.2 `setup-dev.sh` (uma vez por máquina)

1. Confere a versão do OpenSpec contra `OPENSPEC_VERSION`.
2. Localiza a config global com `openspec config path`.
3. Pede confirmação (pula com `--yes`) mostrando o profile atual e o do time.
4. Faz backup em `<config>.bak-<AAAAMMDDHHMMSS>`.
5. Mescla via `node`: substitui `profile`, `delivery` e `workflows`; preserva `featureFlags`, `telemetry` e qualquer outra chave.
6. Confere com `openspec config get workflows` que a lista é exatamente a do time. Se não for, restaura o backup e falha.
7. Não roda `openspec update`.

Custo assumido: o profile é global, então quem usa OpenSpec em projetos pessoais com outro profile passa a ter o do time em todos. O backup permite voltar.

### 6.3 `profile_drift.sh` (no projeto)

- Modo check (padrão, usado no CI): cria um `git worktree` temporário do `HEAD`, cria uma config isolada com `team-profile.json` (mais `telemetry.noticeSeen: true`, para o CI não imprimir aviso nem pedir interação) em `XDG_CONFIG_HOME` temporário, roda `npx -y @fission-ai/openspec@<OPENSPEC_VERSION> update .` com stdin fechado dentro do worktree, e falha se `git status --porcelain` no worktree não estiver vazio, imprimindo o diff. Remove o worktree ao sair.
- Modo `--fix` (local): mesma regeneração, no diretório de trabalho, para a pessoa corrigir o drift e commitar.

Nunca passa `--force` ao `update`.

## 7. Convenções comuns aos schemas

### 7.1 Todo artefato do grafo é obrigatório

Quando uma seção não se aplica, ela existe com corpo `N/A: <motivo>`, com motivo de pelo menos 10 caracteres. Seção vazia ou com só `N/A` é violação. O objetivo é tornar explícita a decisão de não fazer.

### 7.2 Rigor por classificação declarada

`data-eng` declara um tier no `impact`; `research` declara um modo no `question`. Cada seção dos artefatos seguintes tem uma regra de obrigatoriedade por tier ou modo, registrada em dois lugares: um comentário no template (`<!-- required: T2+ -->`, `<!-- required: causal, confirmatory -->`) para orientar o agente, e a tabela de regras do `kit.py` para cobrar. Abaixo do limiar, a seção aceita `N/A: <motivo>`; no limiar ou acima, não.

### 7.3 Tokens lidos pelo `kit.py`

Linhas `Chave: valor` em inglês nos artefatos: `Change class`, `Tier`, `Breaking contract change`, `New columns`, `New PII`, `Backfill`, `Critical consumer` (em `impact.md`), `Materialization` (em `design.md`), `Mode`, `Timebox`. Marcador `N/A:`. Hipóteses `### H<n>:`. Desvios `### D<n> (<AAAA-MM-DD>) [before-results|after-results]`. Citação de execução `run: <run-id>`. Rótulo exploratório `Decision under exploratory evidence`.

### 7.4 Resultado nasce depois do apply, como artefato com pré-checagem

Revisado em 02/10/2026 depois da leitura da documentação e do schema comunitário `superpowers-bridge`. Os artefatos de resultado (`evidence` no `sdd-tdd`, `results` e `findings` no `research`, `findings` no `spike`) ficam no grafo, depois do artefato que libera o `apply`, e fora do `apply.requires`. Pelo fato 15, isso os torna visíveis como pendentes no `status` sem bloquear o `apply`. Pelo fato 11, o `status` os aponta como "Next" antes da execução, então a instrução de cada um começa com uma pré-checagem mecânica (commit vermelho, tarefas sem checkbox aberto, manifesto em `runs/`) que manda o agente parar se a execução não aconteceu. `deviations.md` e `runs/` continuam fora do grafo, porque são registros contínuos, não artefatos com momento de criação. Tudo fica na pasta da change e vai para o archive junto com ela.

## 8. Schemas

### 8.1 `sdd-tdd` (v3, laço duplo)

Grafo: proposal $\rightarrow$ specs $\rightarrow$ design $\rightarrow$ tests $\rightarrow$ tasks, `apply`, e depois `evidence`. Apply `requires: [tasks]`, `tracks: tasks.md`.

Mudanças em relação à v2, motivadas pela crítica de 02/10/2026 (o `red` do ledger era valor inicial, não observação; `ImportError` contava como vermelho; nada separava teste e implementação no tempo; nada detectava teste afrouxado):

- **design** ganha "Interface Under Test", com as assinaturas que os stubs vão ter, e "Open Questions", resolvidas antes das tarefas.
- **tests** deixa de repetir GIVEN/WHEN/THEN. Por cenário: nome, arquivo, nível, **Breaks if** (a mudança de produção que faria o teste falhar) e **Expected red**. O ledger vai de `planned` para `red` só com SHA e trecho da falha observada, e para `green` só com o commit. Ganha o log append-only "Test Changes After Red".
- **tasks** abre com o bloco 0, o portão vermelho: escrever todos os testes de cenário e stubs sem lógica; rodar e exigir falha por asserção; commitar como `test(red): <change>`; parar até o usuário aprovar. Cada tarefa declara como é verificada; cada grupo traz os próprios testes; o último grupo faz uma checagem de mutação por capability e a suíte completa.
- **apply**: laço externo com os testes de cenário, laço interno com testes unitários um a um. Se a skill `superpowers:test-driven-development` existir, ela governa só o laço interno; o portão vermelho é do schema. Testes do commit vermelho ficam congelados.
- **evidence** (pós-apply, com pré-checagem): replay do estado vermelho, `git diff <red>..HEAD` dos testes contra o log, tabela de mutações, suíte completa, `TDD path:`, resumo do `/opsx:verify` e a linha `DECISION: PASS | FAIL`.
- **specs**: requisito com um comportamento e descrição de até 500 caracteres; caminho de capability aninhado; `skip_specs: true` para refactor puro, com o `tests.md` mapeando os testes existentes.

### 8.2 `bugfix` (v2)

Grafo: bug $\rightarrow$ specs $\rightarrow$ tasks. Apply `requires: [tasks]`, `tracks: tasks.md`.

- **bug** (`bug.md`): observado contra esperado; reprodução (passos, ambiente, frequência); hipótese de causa raiz; teste de regressão (nome, arquivo, tipo, GIVEN/WHEN/THEN, status `red`/`green`, evidência); escopo do fix e o que não muda; capability afetada.
- **specs**: delta com o requisito de regressão e seu cenário de falha. Se a capability não tem spec, cria `specs/<capability>/spec.md` só com esse requisito em `## ADDED Requirements`. A spec cresce a partir dos bugs, com custo de um requisito e um cenário por bug. O `openspec validate` já cobra o delta (fato 7).
- **tasks**: 1. escrever o teste de regressão e confirmar que falha pela razão certa; 2. confirmar a causa raiz com evidência e corrigir `bug.md` se a hipótese estava errada; 3. fix mínimo; 4. teste verde e suíte completa; 5. registrar a evidência em `bug.md`.

Instrução do apply: sem fix antes de teste vermelho; sem fix antes de causa raiz confirmada; mudar a asserção do teste para casar com o comportamento observado sem mudar a spec é violação.

Na v2: título nos templates, caminho exato da capability (`openspec list --specs`) e limite de 500 caracteres para requisito novo.

### 8.3 `data-eng` (v3, Data TDD)

Na v3 (08/10/2026, kit 4.0.0): o `data-eng` ganha a disciplina do `sdd-tdd` v3 com mecânica de dados. O design ganha Model Interface (schema de saída de cada modelo, usado pelos stubs). O validation vira plano de testes: teste de lógica com fixture isolada para todo cenário sobre a saída da transformação, teste de grão obrigatório por modelo alterado, "Breaks if" (mutação de modelo ou de fixture), falha esperada contra o stub e marcação `Vacuous on empty` para testes que passam em tabela vazia. O tasks abre com portão vermelho (stubs com o schema exato e zero linhas, falha por asserção, commit `test(red)`, parada para aprovação); testes e fixtures ficam congelados depois do vermelho; uma checagem de mutação por modelo alterado, e por cláusula de contrato a partir de T2. Novo artefato `evidence` pós-apply, com pré-checagem e `DECISION: PASS | FAIL`. Base: unit tests do dbt (que a documentação apresenta como habilitadores de TDD), relatos da Equal Experts e do startdataengineering, tSQLt, operadores de mutação de SQL da literatura e os bugs de teste que passa sem comparar no dbt Fusion (issues 15894 e 16650).

Histórico da v2:


Na v2: capability aninhada por domínio (`specs/<domínio>/<dataset>/spec.md`); `retire_capabilities: true` e a seção Retirement do rollout quando um dataset sai inteiro; um clause por requisito com descrição de até 500 caracteres; Open Questions no design, resolvidas antes das tarefas; cada tarefa declara como é verificada, e o grupo final é só de evidência de integração.

Grafo: proposal $\rightarrow$ impact $\rightarrow$ specs $\rightarrow$ design $\rightarrow$ validation $\rightarrow$ rollout $\rightarrow$ tasks. `validation` requer `specs` e `design`; `rollout` requer `impact`, `design` e `validation`. Apply `requires: [tasks]`, `tracks: tasks.md`.

**Tiers**, derivados de critérios declarados no `impact` (o tier declarado não pode ser menor que o derivado):

| Critério declarado | Tier mínimo |
|---|---|
| `Change class: additive`, sem nenhum outro critério | T1 |
| `Change class: column` (remover, renomear ou redefinir coluna) | T2 |
| `Breaking contract change: yes` (coluna removida, renomeada ou com tipo alterado, grão alterado, restrição endurecida, SLA afrouxado) | T2 |
| `New PII: yes` | T2 |
| `Backfill: yes` | T2 |
| `Change class: model-wide` (grão, filtro, agrupamento) | T3 |
| `Critical consumer: yes` | T3 |

A classificação aditiva, de coluna e de modelo inteiro segue o Recce. Acrescentar uma coluna é aditivo e não é quebra de contrato, mesmo que o delta da spec modifique o requisito de colunas; por isso coluna nova sem PII, sem backfill e sem consumidor crítico fica em T1. O tier é hipótese: se o diff do apply mostrar efeito além do declarado, o tier sobe e os artefatos afetados reabrem.

**Artefatos e seções** (entre colchetes, a partir de que tier a seção não aceita N/A):

- **proposal**: decisão de negócio atendida [T1]; consumidores [T1]; escopo e não escopo [T1].
- **impact**: montante, com contratos de entrada e profiling das fontes (unicidade da chave, nulos, órfãos, faixas, atraso) [T2]; jusante, com lineage em nível de coluna e consumidores nomeados [T1]; as linhas de classificação da tabela acima [T1]; tier [T1].
- **specs**: o contrato do dataset ou da métrica como requisitos com cenários, no vocabulário do ODCS $\geq$ 3.2.0. Grão e chave [T1]; colunas, tipo e obrigatoriedade [T1]; classificação de PII e retenção [T1, e nunca N/A para coluna nova]; SLA de latência, frequência e tempo para detectar [T2]; regras de qualidade com severidade [T1]; compatibilidade e versão ativa [T2]; definição de métrica com filtro e exclusões [quando o dataset publica métrica]; dono e canal de suporte [T1]. No archive, vira a spec viva do dataset. A spec é a fonte do requisito e cita o contrato executável (`contractId@version` quando há ODCS, senão o caminho do artefato de enforcement); o contrato executável mora no repositório de dados e é a fonte do enforcement.
- **design**: materialização [T1]; estratégia incremental e dado tardio [T1]; mapeamento fonte-alvo por campo novo ou alterado, com cada campo classificado como mapeado, de auditoria ou gerado pelo sistema [T1]; idempotência e reprocessamento [T2]; orquestração [quando muda]; custo estimado por run e por backfill [T2].
- **validation**: ledger que liga cada cenário das specs a uma evidência de um destes tipos: `logic-test` (o único que pode estar vermelho antes do build) [T1]; `data-test` ou contrato [T1]; `reconciliation` com limiar numérico [T2]; `diff` do dev ou shadow contra prod [T2]. Mais os monitores que materializam os SLAs [T2].
- **rollout**: estratégia pela classe (aditiva: deploy direto; coluna: versão nova, data de depreciação e migração dos consumidores; modelo inteiro: shadow run, reconciliação, cutover por troca de view e janela de rollback) [T1]; decisão entre histórico nulo e backfill para coluna nova em modelo incremental [T1, nunca N/A quando se aplica]; plano de backfill com partições, estratégia de escrita, dry run, publicação pausada e teto de custo [quando `Backfill: yes`]; aprovação do dono e dos donos a jusante [T2]; alertas e runbook [T3].
- **tasks**: cada tarefa aponta um arquivo e um item do ledger (`[ledger: <id>]`). Em todo grupo que altera lógica de transformação, a primeira tarefa é o `logic-test` vermelho.

**Equivalência por stack** (vai na instrução do schema):

| Mecanismo | dbt | Dataform | Spark/PySpark |
|---|---|---|---|
| Teste de lógica com fixture, vermelho antes do build | unit test com `given`/`expect` (dbt $\geq$ 1.8) | unit test em `.sqlx` com `type: "test"` e `input` mockado | pytest com DataFrames de fixture e `assertDataFrameEqual` (PySpark $\geq$ 3.5) |
| Teste de dado após o build | data tests | assertions embutidas (`nonNull`, `uniqueKey`, `rowConditions`) e assertions manuais | queries de checagem sobre a tabela materializada |
| Contrato executável | model contract com `enforced: true`; ODCS quando adotado | schema declarado e assertions; ODCS quando adotado | `StructType` explícito conferido com `assertSchemaEqual`; ODCS quando adotado |
| Versionamento com depreciação | model versions (`latest_version`, `deprecation_date`) | convenção: tabela com sufixo de versão e view estável com o nome público | a mesma convenção |
| Diff contra prod | Recce, data-diff ou query de comparação | query de comparação | comparação de DataFrames |

Instrução do apply: `logic-test` vermelho antes do modelo; build com contrato aplicado; data tests verdes; reconciliação dentro do limiar com valor observado registrado; diff anexado sem colunas ou linhas fora do que o `impact` declarou (se houver, subir o tier e reabrir); checklist de rollout com rollback testado quando T3.

### 8.4 `research` (v2)

Grafo: question $\rightarrow$ data-audit $\rightarrow$ analysis-plan $\rightarrow$ checks $\rightarrow$ tasks, `apply`, e depois results $\rightarrow$ findings (pós-apply, com pré-checagem). Apply `requires: [tasks]`, `tracks: tasks.md`. Sem artefato `specs`.

**Modos**, declarados em `question.md` com `Mode:`: `exploratory`, `confirmatory`, `causal`, `forecast`, `model`.

- **question**: pergunta; decisão de negócio que ela informa; quem decide; o que mudaria a decisão; modo.
- **data-audit**: fontes e snapshot (identificador ou hash); contagens e cobertura; defeitos conhecidos; missing distinto de zero; declaração do que já foi visto nesses dados e por quem. Nos modos `confirmatory` e `causal`, declaração explícita de que desfecho não foi cruzado com tratamento nesta etapa.
- **analysis-plan**, seções por modo:

| Seção | exploratory | confirmatory | causal | forecast | model |
|---|---|---|---|---|---|
| Hipóteses `### H<n>` com direção ou estimando | perguntas, não hipóteses | sim | sim | sim | sim |
| Construção de variáveis | sim | sim | sim | sim | sim |
| Especificação do modelo ou estimador | sim | sim | sim | sim | sim |
| Tratamento de missing e outliers | sim | sim | sim | sim | sim |
| Regra para múltiplos desfechos ou comparações | N/A permitido | sim | sim | N/A permitido | sim |
| Critério de inferência | N/A permitido | sim | sim | N/A permitido | N/A permitido |
| Robustez pré-declarada | N/A permitido | sim | sim | sim | N/A permitido |
| Bloco TARGET: elegibilidade, estratégias de tratamento, atribuição, time zero, desfecho, contraste causal, hipóteses de identificação, mapeamento para os dados | não se aplica | não se aplica | sim | não se aplica | não se aplica |
| Backtest, baseline ingênuo, métrica e horizonte | não se aplica | não se aplica | não se aplica | sim | não se aplica |
| Split, controle de vazamento, baseline, métrica e limiar de promoção | não se aplica | não se aplica | não se aplica | não se aplica | sim |
| Holdout | N/A permitido | sim | N/A permitido | sim | sim |

- **checks**: checagens executáveis, cada uma com a mutação que a quebra: raw inalterado, contagem preservada em join, seed fixa, rerun limpo reproduz o número, missing não convertido em zero, mais as específicas da análise.
- **tasks**: a primeira tarefa confere se o modo ainda vale depois da auditoria e congela o plano: SHA-256 de `question.md`, `data-audit.md`, `analysis-plan.md` e `checks.md` gravados na linha da tarefa (hoje com `shasum`/`sha256sum`; depois com `kit.py freeze`). Seguem checks e análise; cada tarefa declara como é verificada. Resultados não são tarefas.

**Pós-apply, no grafo** (com pré-checagem: congelamento feito, manifesto em `runs/`, nenhuma tarefa aberta):

- **results**: `## Pre-specified` com um bloco `### H<n>` por hipótese, na ordem do plano, inclusive as nulas, cada número com `run: <run-id>`; `## Not pre-specified (observational)`; `## Deviations Applied`.
- **findings**: resposta, recomendação, `Evidence level: pre-registered | exploratory | observational` (confirmatório, causal, forecast e model que seguiram o plano são `pre-registered`), limitações, o que mudaria a conclusão, passo confirmatório e a seção **Model Card**, obrigatória no modo `model` (dados de treino, métricas no holdout contra baseline e limiar pré-registrado, erro por segmento, decisão de promoção). Recomendação de decisão sobre evidência exploratória ou observacional exige a linha `Decision under exploratory evidence` e o passo confirmatório.

**Registros contínuos, fora do grafo** (na pasta da change):

- `runs/<run-id>.json` e `runs/<run-id>.log`: commit, árvore suja ou não, seed, snapshot, hash do lockfile, comando, exit code, início e fim, e o final de stdout e stderr. Escritos pelo agente hoje; por `kit.py run --change <nome> [--seed N] [--snapshot ID] -- <comando>` quando existir.
- `deviations.md`: só cresce. Cada entrada `### D<n> (<data>) [before-results|after-results]` traz motivo e impacto. O plano congelado nunca é editado; mudança de plano é desvio.

Base: plano de pré-análise (McKenzie; o "populated PAP" do J-PAL), item 6 do TARGET (JAMA, 2025), o preset de ciência do spec-kit (checagens com mutação, nunca reescrever plano superado), o Glite ARF (log por comando, imutabilidade com correções por cima) e, do ARIA, os documentos encadeados e a comparação obrigatória entre plano e resultado. O ARIA não é a base porque o plano dele é escrito depois de ler os dados processados e não tem hipótese, estimando, identificação nem regra de múltiplos testes; em inferência causal e pricing isso institucionaliza o garden of forking paths (Gelman e Loken).

### 8.5 `spike` (v2)

Grafo: question $\rightarrow$ tasks, `apply`, e depois findings (pós-apply, com pré-checagem). Apply `requires: [tasks]`, `tracks: tasks.md`. Sem `specs`.

- **question**: pergunta de viabilidade; decisão que depende da resposta; `Timebox:`; critério de sucesso e sinal de parada; onde fica o código descartável (branch ou diretório que não é mergeado).
- **tasks**: passos da sonda, do mais barato ao mais caro, cada um com o resultado que procura. Passos não feitos porque o timebox acabou são marcados com `(abandoned: <motivo>)`.
- **findings** (pré-checagem: nenhuma tarefa aberta): resposta, recomendação, `Timebox status: met | exceeded`, evidência, e o que foi descartado e por quê.

Fronteiras: `explore` é conversa sem arquivo, para decidir se existe uma change. O `spike` responde se algo pode ser construído ou como uma tecnologia se comporta, com timebox e código descartável. O modo `exploratory` do `research` responde algo sobre o negócio a partir de dados e produz hipótese, não decisão de construção.

## 9. Qual schema usar (`docs/qual-schema-usar.md`)

| Situação | Schema | Como pedir ao agente (comandos do Claude Code; outras ferramentas têm equivalentes) |
|---|---|---|
| Funcionalidade nova ou mudança de comportamento em software | `sdd-tdd` (padrão) | `/opsx:propose ...` |
| Comportamento errado em algo que existe | `bugfix` | "use o schema bugfix" |
| Modelo, tabela, pipeline ou métrica em dbt, Dataform ou Spark | `data-eng` | "use o schema data-eng" |
| Pergunta analítica, causal, forecast ou experimento de modelo | `research` | "use o schema research, modo causal" |
| Descobrir se algo é viável, com prazo fixo | `spike` | "use o schema spike" |
| Ainda não sei se existe uma change | nenhum | `/opsx:explore` |

Projetos majoritariamente de dados instalam com `--default data-eng`. Para `research` e `data-eng`, a página recomenda `/opsx:new` seguido de `/opsx:continue` em vez de `/opsx:propose`: o pré-registro e a análise de impacto só valem se uma pessoa lê o plano antes de o resultado existir.

## 10. `kit.py check`: regras

```
kit.py check <change-dir> [--on-disk] [--final] [--strict]
kit.py check --changed-since <git-ref> [--on-disk] [--strict]
```

Lê o schema em `.openspec.yaml`; schema fora do kit é ignorado com aviso. Sai com código diferente de zero se houver violação e lista cada uma com o código da regra.

**Fases.** Sem `--final`, o `kit.py` cobra só o que já deve existir na fase em que a change está: regras de planejamento sempre; regras de pós-execução só depois que a tarefa que as habilita está marcada (a de congelamento no `research`, a última no `spike`). Com `--final`, cobra tudo, e o que falta é violação. `--final` substitui o `--require-green` do `sdd_tdd_check.py`. Com `--changed-since`, o `kit.py` verifica toda change tocada desde a referência e aplica `--final` automaticamente às que entraram em `openspec/changes/archive/` nesse intervalo; é assim que o CI cobra o estado final exatamente no MR que arquiva.

Comuns:
- **K1**: seção com `N/A:` tem motivo de pelo menos 10 caracteres; seção vazia é violação.
- **K2**: seção obrigatória para o tier ou modo declarado não pode estar em N/A.

`sdd-tdd` (v3):
- **T1**: as regras herdadas do `sdd_tdd_check.py`: todo cenário tem bloco em `tests.md`; ledger cobre todo cenário; todo nome em `[tests: ...]` existe; `--on-disk` confere os testes nos arquivos; `--strict` torna cenário extra violação.
- **T2**: todo bloco de cenário tem `Breaks if` preenchido.
- **T3**: linha do ledger em `red` ou `green` tem SHA e, no `red`, trecho da falha; `red` sem evidência é violação.
- **T4** (depois do commit vermelho): existe commit `test(red)`, e `git diff <red>..HEAD` nos arquivos de teste de cenário só mostra mudanças registradas em "Test Changes After Red".
- **T5** (`--final`): ledger todo verde (ou não executável documentado), `evidence.md` existe, tabela de mutações tem uma linha por capability e a linha `DECISION: PASS`.
- **T6** (`--final`, opcional em CI com dependências instaladas): checkout do SHA vermelho e execução dos testes de cenário, esperando falha.

`bugfix`:
- **B1**: `bug.md` tem observado contra esperado, reprodução, causa raiz e teste de regressão com nome e arquivo.
- **B2**: o teste de regressão aparece em `[tests: ...]` de alguma tarefa.
- **B3** (`--on-disk`): o teste existe no arquivo declarado.
- **B4** (`--final`): status `green` com evidência.

`data-eng`:
- **D1**: `impact.md` tem todas as linhas de classificação com valores válidos.
- **D2**: tier declarado $\geq$ tier derivado pela tabela da seção 8.3.
- **D3**: delta com requisito REMOVED exige `Breaking contract change: yes` e `Change class` diferente de `additive`. RENAMED no OpenSpec troca só o título do requisito, com comportamento igual, e gera apenas aviso para alguém conferir se o nome público do campo mudou. Requisito MODIFIED é aceito em qualquer classe, porque o `kit.py` não distingue modificação aditiva de quebra; essa distinção fica com o `impact` e com o diff do apply.
- **D4**: com `New columns: yes`, a seção de classificação de PII da spec não pode estar em N/A.
- **D5**: com `New columns: yes` em `impact.md` e `Materialization: incremental` em `design.md`, a seção de histórico nulo ou backfill do `rollout.md` não pode estar em N/A.
- **D6**: todo cenário das specs tem linha no ledger de `validation.md`; todo `[ledger: <id>]` das tarefas existe no ledger.
- **D7** (`--final`): ledger verde com evidência; linhas `reconciliation` com limiar e valor observado dentro do limiar.

`research`:
- **R1**: `Mode:` válido em `question.md`.
- **R2** (depois do congelamento): a primeira tarefa contém os quatro hashes e eles batem com os arquivos atuais. Com `--final`, plano não congelado é violação.
- **R3** (`--final`): toda hipótese `### H<n>` do plano tem bloco em `results.md`, na mesma ordem.
- **R4** (sempre que `results.md` existir): todo `run: <run-id>` citado existe em `runs/` com exit code registrado.
- **R5** (sempre que `deviations.md` existir): em repositório git com histórico completo, o histórico do arquivo (`git log -p --follow`) não tem linha removida; toda entrada tem data e `[before-results|after-results]`. Erro de digitação numa entrada se corrige com uma entrada nova, nunca editando a antiga. Em clone raso, a regra avisa que não pôde verificar em vez de passar.
- **R6** (`--final`): `findings.md` existe com `Evidence level:` válido; com nível `exploratory` ou `observational`, recomendação de decisão exige o rótulo e o passo confirmatório.
- **R7** (`--final`): no modo `model`, a seção Model Card de `findings.md` não está em N/A e a decisão de promoção cita o limiar do plano.

`spike`:
- **S1**: `question.md` tem decisão, `Timebox:` e critério de sucesso.
- **S2** (`--final`): `findings.md` existe com recomendação e situação do timebox.

`kit.py freeze <change-dir>` imprime e grava os hashes da seção 8.4. `kit.py run` está descrito na seção 8.4.

`kit.py stats <openspec-dir>` percorre as changes arquivadas e imprime, por schema, artefato e seção, quantas vezes a seção ficou em N/A e em quantas changes ela existia. É a medida usada pela regra de poda da seção 13.

## 11. CI

**Do kit** (`.gitlab-ci.yml`):
- `shellcheck` em `install.sh`, `setup-dev.sh` e `kit/profile_drift.sh`.
- `uv run --with pytest pytest tests/` para o `kit.py`: cada regra tem uma fixture válida que passa e uma inválida que falha com o código da regra.
- `tests/e2e.sh` no OpenSpec fixado, para cada schema: `init` num diretório temporário, `install.sh`, `new change --schema <s>`, cópia da fixture válida, `status` completo, `validate --strict --no-interactive`, `kit.py check --final` verde, `archive --yes`, `validate --archived`. Para `research` e `spike`, confirma `skip_specs`. Também confere que o OpenSpec ignora `openspec/kit/`.
- Os fatos 12 a 14 da seção 3 sustentam a seção 7.4 e as regras R2 e R5, e o e2e os mantém como teste de regressão: a fixture válida do `research` inclui todos os arquivos de pós-execução, o e2e compara os hashes antes e depois do archive e roda `git log --follow` sobre o `deviations.md` arquivado. Se uma versão nova do OpenSpec quebrar algum deles, a seção 7.4 é revista antes da release.
- Teste do profile com `XDG_CONFIG_HOME` temporário: o `setup-dev.sh` preserva `featureFlags` e `telemetry`, recusa e restaura quando a lista resultante não confere, e o `profile_drift.sh` detecta um arquivo gerado alterado.
- Job `allow_failure` contra `@latest` do OpenSpec, para avisar cedo sobre mudança de formato.

**Dos projetos** (`kit/gitlab-ci.snippet.yml`, colado pelo time, com `GIT_DEPTH: 0` porque a regra R5 lê o histórico completo): `openspec validate --all --strict --no-interactive`; `openspec validate --archived --no-interactive`, que é a resposta nativa ao fato 8 (change arquivada com tarefa incompleta); `bash openspec/kit/profile_drift.sh`; `python3 openspec/kit/kit.py check --changed-since $CI_MERGE_REQUEST_DIFF_BASE_SHA --on-disk`, que aplica `--final` às changes arquivadas no MR.

## 12. Versionamento e atualização

O kit usa tags semver (`v1.0.0`). Cada schema tem `version:` inteiro no `schema.yaml` (estado em 08/10/2026: `sdd-tdd` 3, `data-eng` 3; `bugfix`, `research` e `spike` 2). O `manifest.json` do projeto registra os dois. Atualizar um projeto é `install.sh --force`, que recopia os schemas instalados e o `kit/`, mantendo o padrão do projeto. Atualizar a versão do OpenSpec é uma release do kit: muda `OPENSPEC_VERSION`, roda o e2e, e cada projeto roda `profile_drift.sh --fix` depois de instalar a versão nova. Mudanças já em andamento passam a usar a cópia nova na próxima etapa, porque as instruções valem por artefato.

O repositório `sdd-tdd` recebe um README apontando para o kit e uma tag final.

## 13. Riscos, limites e métricas

- **Custo por change.** Sete artefatos no `data-eng`, cinco no `research`. Métrica de poda: fração de N/A por seção, medida por `kit.py stats` nas changes arquivadas; seção que vive em N/A sai do template na release seguinte.
- **Rotular para fugir.** Declarar T1 ou `exploratory` para escapar do rigor. A tabela de tier derivado (D2) e o rótulo exploratório (R6) tornam isso visível, não impossível.
- **Plano de pré-análise caro.** Na economia acadêmica a estimativa citada pelo J-PAL é de duas a quatro semanas. O modo `exploratory` existe para não transformar o schema em teatro.
- **Congelamento por convenção.** Hash e histórico do git detectam edição do plano; não impedem. A trilha de auditoria é o git.
- **Escolha manual de schema.** Cinco nomes mais o `explore`. Mitigação: padrão por projeto e a página de decisão.
- **Profile global.** Sobrescreve o profile pessoal em todos os projetos da máquina; backup permite voltar.
- **`openspec schema` experimental.** O formato pode mudar; o job contra `@latest` avisa.
- **Sucesso.** Primeira change arquivada por alguém que não seja o autor do kit, num repositório real, para cada schema; falhas do `kit.py` por regra, para saber quais regras pegam problema de verdade.

## 14. Fora de escopo

Skills ou plugins de agente; suporte a Windows; roteamento automático de schema; geração de ODCS a partir da spec ou o contrário; executar dbt, Dataform, Spark ou o CLI de data contract a partir do kit (o kit cobra a evidência registrada, o CI do projeto roda as ferramentas); migração dos projetos que já usam o `sdd-tdd` em cópia de usuário.

## 15. Sequência de implementação

O plano será escalonado, com o e2e verde ao fim de cada etapa:

1. Esqueleto do repositório, `install.sh`, `setup-dev.sh`, `profile_drift.sh`, `team-profile.json`, `OPENSPEC_VERSION`, `kit.py` com as regras comuns e as do `sdd-tdd`, `sdd-tdd` migrado, CI do kit.
2. `bugfix`.
3. `data-eng`.
4. `research`, com `kit.py freeze` e `kit.py run`.
5. `spike`.
6. `docs/qual-schema-usar.md`, `INSTALL.md`, README, CHANGELOG, tag `v1.0.0` e README de redirecionamento no `sdd-tdd`.

## Fontes

- OpenSpec: https://github.com/Fission-AI/OpenSpec (docs/customization.md, CHANGELOG); comportamento da 1.14.0 medido localmente.
- ARIA: https://arxiv.org/abs/2510.11143 e https://github.com/Biaoo/aria
- Glite ARF: https://arxiv.org/html/2606.27416v1
- speckit-preset-science-study: https://github.com/Waveform-Analytics/speckit-preset-science-study
- TARGET Statement: https://jamanetwork.com/journals/jama/fullarticle/2837724
- J-PAL, pre-analysis plans: https://www.povertyactionlab.org/resource/pre-analysis-plans
- McKenzie, checklist de PAP: https://blogs.worldbank.org/en/impactevaluations/a-pre-analysis-plan-checklist
- Gelman e Loken: https://sites.stat.columbia.edu/gelman/research/unpublished/p_hacking.pdf
- van den Akker et al., pré-registro de dados secundários: https://research.tilburguniversity.edu/en/publications/preregistration-of-secondary-data-analysis-a-template-and-tutoria/
- data-engineering-agent-skills: https://github.com/vaquarkhan/data-engineering-agent-skills
- dataproduct-builder-dbt: https://github.com/entropy-data/dataproduct-builder-dbt
- dbt_data_engineering_toolkit: https://github.com/systemizing-solutions/dbt_data_engineering_toolkit
- NashTech, spec-kit para engenharia de dados: https://blog.nashtechglobal.com/github-spec-kit-for-data-engineering/
- Recce, classificação de mudança: https://docs.reccehq.com/what-you-can-explore/change-classification/
- ODCS: https://bitol-io.github.io/open-data-contract-standard/latest/schema/
- dbt model contracts, versions e unit tests: https://docs.getdbt.com/docs/mesh/govern/model-contracts, https://docs.getdbt.com/docs/mesh/govern/model-versions, https://docs.getdbt.com/docs/build/unit-tests
- Dataform assertions e unit tests: https://docs.cloud.google.com/dataform/docs/assertions
- PySpark testing: https://spark.apache.org/docs/latest/api/python/getting_started/testing_pyspark.html
