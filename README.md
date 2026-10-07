# openspec-kit: schemas do OpenSpec para o time

Cinco schemas de workflow para o [OpenSpec](https://openspec.dev), prontos para copiar para dentro de um projeto. Cada schema define quais documentos uma change produz, em que ordem e com quais instruções o agente de IA trabalha em cada etapa. Os schemas não dependem de uma ferramenta de agente específica: funcionam com qualquer uma suportada pelo OpenSpec.

## Os schemas

| Schema | Versão | Para quê | Grafo | OpenSpec mínimo |
|--------|--------|----------|-------|-----------------|
| `sdd-tdd` | 3 | Funcionalidade nova ou mudança de comportamento em software | proposal, specs, design, tests, tasks; apply com portão vermelho; evidence | 1.6.0 |
| `bugfix` | 2 | Comportamento errado em algo que já existe | bug, specs, tasks | 1.6.0 |
| `data-eng` | 2 | Modelo, tabela, pipeline ou métrica em dbt, Dataform ou Spark | proposal, impact, specs, design, validation, rollout, tasks | 1.6.0 |
| `research` | 2 | Pergunta analítica, inferência causal, forecast ou experimento de modelo | question, data-audit, analysis-plan, checks, tasks; apply; results, findings | 1.10.0 |
| `spike` | 2 | Descobrir se algo é viável, com prazo fixo e código descartável | question, tasks; apply; findings | 1.10.0 |

`research` e `spike` não geram specs. Antes da 1.10.0, o `openspec validate` recusa change sem delta de spec, mesmo com `skip_specs: true`.

Artefatos depois do `apply` (`evidence`, `results`, `findings`) ficam no grafo para aparecerem como pendentes no `openspec status`, mas a instrução de cada um começa com uma pré-checagem que manda o agente parar se a execução ainda não aconteceu.

## Instalação

Pré-requisitos: Node, git e o OpenSpec (`npm install -g @fission-ai/openspec@latest`). O projeto de destino precisa ter rodado `openspec init`.

Num computador novo, um comando baixa o kit para `~/.local/share/openspec-kit` e instala os schemas no projeto:

```bash
curl -fsSL https://raw.githubusercontent.com/caiocgomes/schemas_openspec/main/install.sh \
  | bash -s -- /caminho/do/projeto
```

Para instalar só alguns schemas, passe as opções depois do caminho: `| bash -s -- . --schemas data-eng --default data-eng`.

Rodar o mesmo comando de novo atualiza a cópia baixada (`git pull`) antes de instalar. Com o kit já clonado, dá para chamar o script direto:

```bash
~/.local/share/openspec-kit/install.sh /caminho/do/projeto
```

Opções:

| Opção | Efeito |
|-------|--------|
| `--schemas sdd-tdd,data-eng` | instala só os schemas listados (padrão: todos) |
| `--default data-eng` | define `schema:` em `openspec/config.yaml` |
| `--force` | substitui schemas já instalados que estejam diferentes da versão do kit |
| `--no-update` | não atualiza a cópia baixada antes de instalar |

O script confere a versão do OpenSpec (`research` e `spike` exigem 1.10.0 ou superior), copia os schemas, roda `openspec schema validate` e confirma que cada um resolve a partir do projeto. Quando um schema instalado difere do kit, o script não o sobrescreve: avisa e sai com código 3, e `--force` faz a troca.

Commite `openspec/schemas/` junto com o código: quem clonar o projeto passa a ter os mesmos schemas, sem rodar o instalador. Uma cópia só em `~/.local/share/openspec/schemas/` funciona para você e quebra para o resto do time (`Unknown schema`).

Projetos majoritariamente de dados costumam usar `data-eng` como padrão.

## Qual schema usar

| Situação | Schema | Como pedir |
|----------|--------|------------|
| Funcionalidade nova ou mudança de comportamento | `sdd-tdd` | padrão do projeto, ou "use o schema sdd-tdd" |
| Algo existente se comporta errado | `bugfix` | "use o schema bugfix" |
| Modelo, tabela, pipeline ou métrica de dados | `data-eng` | "use o schema data-eng" |
| Pergunta analítica, causal, forecast ou experimento de modelo | `research` | "use o schema research, modo causal" |
| Viabilidade com prazo fixo | `spike` | "use o schema spike" |
| Ainda não sei se existe uma change | nenhum | `/opsx:explore` |

Pela linha de comando: `openspec new change <nome> --schema <schema>`. O agente só troca de schema quando o pedido nomeia um; sem isso, usa o padrão do projeto.

Para `research` e `data-eng`, prefira `/opsx:new` seguido de `/opsx:continue` em vez de `/opsx:propose`: o pré-registro e a análise de impacto só valem se uma pessoa lê o plano antes de o resultado existir.

## Como o `sdd-tdd` força o teste antes do código

O OpenSpec só confere se os arquivos existem, então a disciplina vem de três mecanismos no próprio fluxo:

1. **Portão vermelho.** O primeiro bloco de tarefas escreve todos os testes de cenário e stubs sem lógica, roda, exige que cada teste falhe por asserção, commita como `test(red): <change>` e para até o usuário aprovar.
2. **Testes congelados.** Teste do commit vermelho só muda com registro em "Test Changes After Red". O `evidence.md` confere com `git diff <red>..HEAD`.
3. **Evidência no fim.** O artefato `evidence` refaz o estado vermelho, confere o congelamento, registra uma mutação por capability e a suíte completa, e termina em `DECISION: PASS` ou `DECISION: FAIL`.

Se a skill `superpowers:test-driven-development` estiver instalada, o agente a usa no laço interno (testes unitários). Se não estiver, segue as regras embutidas no schema. O `evidence.md` registra qual caminho foi usado.

## Opcional: contratos de dados compartilhados entre repositórios

O OpenSpec tem stores (beta): repositórios OpenSpec independentes, registrados na máquina. Um projeto pode referenciar um store no `openspec/config.yaml`, e as instruções do agente passam a listar as specs desse store:

```yaml
references:
  - id: data-contracts
    remote: git@gitlab.com:<grupo>/data-contracts.git
```

Para o `data-eng`, isso permite manter os contratos vivos dos datasets num store único e referenciá-lo nos repositórios de dbt, Dataform e Spark. A seção Upstream do `impact.md` passa a ler o contrato real das fontes. Por ser beta, não é pré-requisito dos schemas. Detalhes em [Stores](https://openspec.dev/docs/stores).

## Limites conhecidos

- As linhas lidas por máquina nos artefatos (`Tier:`, `Mode:`, `Timebox:`, `DECISION:`, os hashes do congelamento) ainda são convenção: nenhuma ferramenta do kit as cobra. O verificador `kit.py` está especificado em `docs/superpowers/specs/2026-10-02-openspec-kit-design.md` e não foi implementado.
- O `openspec archive` pela linha de comando não bloqueia por artefato pendente nem por tarefa aberta com `--yes`. A cobrança real precisa de CI (`openspec validate --all --strict` e `openspec validate --archived`).
- No `research`, o manifesto de cada execução (`runs/<id>.json`) é escrito pelo agente.
- O comando `openspec schema` é marcado como experimental pelo upstream.
