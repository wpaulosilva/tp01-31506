# TP01 – Plataforma de Gestão de Alojamento Local: Reservas, Pagamentos e Extratos de Proprietários

**Unidade curricular:** Integração de Sistemas de Informação (ISI), 2026/27
**Curso:** Licenciatura em Engenharia de Sistemas Informáticos, Escola Superior de Tecnologia, Universidade Politécnica do Cávado e do Ave
**Docentes:** Luís Ferreira e Óscar Ribeiro

## Autor

| Nome | N.º de aluno |
|---|---|
| Paulo Silva | 31506 |

Trabalho realizado individualmente.

## Vídeo de demonstração

https://youtu.be/9gY5OEQGIRM

## Descrição

Processo ETL desenvolvido no **Pentaho Data Integration (Spoon 10.2)** para uma empresa fictícia de gestão de alojamento local. O processo lê proprietários, alojamentos, reservas de duas plataformas, despesas e pagamentos (em XML, CSV e JSON), valida e limpa os dados, converte para euros os pagamentos noutra moeda (API Frankfurter) e produz o extrato mensal de cada proprietário:

> receita dos pagamentos pagos − comissão da empresa − despesas = valor líquido

O extrato é exportado em CSV, JSON, XML e HTML (com XSL), carregado numa tabela do SQL Server e enviado por email num ficheiro zip. 
Os registos que não passam as validações ficam em ficheiros de rejeitados.

## Estrutura dos ficheiros

```
tp01-31506/
├── README.md
├── doc/
│   └── 31506_doc.pdf              relatório final
├── dataintegration/
│   ├── jobs/
│   │   └── etl_alojamento.kjb     Job principal
│   ├── transformacoes/            10 transformações
│   ├── xsl/
│   │   └── extrato.xsl            folha XSL 
│   └── sql/
│       ├── criar.sql              cria a base de dados e a tabela extrato (SQL Server)
│       ├── alojamento.bak         backup da base de dados
│       └── consulta_extrato.sql   consulta ao extrato: SELECT * FROM alojamento.dbo.extrato
└── data/
    ├── input/                     dados de entrada
    └── output/                    dados de saída
```

### Dados de entrada (`data/input`)

| Ficheiro | Formato | Conteúdo |
|---|---|---|
| `gestao_proprietarios_alojamentos.xml` | XML | Proprietários e alojamentos |
| `despesas.csv` | CSV | Despesas de manutenção, reparação e limpeza |
| `reservas_plataforma_a.csv` | CSV | Reservas do canal A (separador `;`, datas dd/mm/aaaa) |
| `reservas_plataforma_b.csv` | CSV | Reservas do canal B (separador `,`, datas aaaa-mm-dd) |
| `pagamentos.json` | JSON | Pagamentos (pago, pendente, falhado) |

Existe ainda uma origem externa: a API de câmbios Frankfurter (`https://api.frankfurter.dev`), que é consultada pela transformação `pagamentos.ktr`.

### Transformações (`dataintegration/transformacoes`)

| N.º | Ficheiro | O que faz |
|---|---|---|
| 1 | `proprietarios.ktr` | Lê os proprietários do XML, normaliza o telefone, valida email, NIF e telefone (expressões regulares) |
| 2 | `alojamentos.ktr` | Lê os alojamentos do XML, remove duplicados e valida os campos |
| 3 | `despesas.ktr` | Limpa as despesas (vírgula decimal), valida e acrescenta ano e mês |
| 4 | `reservas_a.ktr` | Limpa e normaliza as reservas do canal A |
| 5 | `reservas_b.ktr` | Limpa e normaliza as reservas do canal B |
| 6 | `reservas.ktr` | Junta os dois canais, remove duplicados, valida datas e alojamento, calcula o valor e anonimiza os hóspedes |
| 7 | `pagamentos.ktr` | Lê os pagamentos, filtra os pagos e converte para euros com a taxa da data de cada pagamento |
| 8 | `consolidacao.ktr` | Cruza tudo, agrupa por proprietário e mês e calcula comissão e líquido |
| 9 | `exportacao.ktr` | Exporta o extrato para JSON e XML e carrega-o na tabela `extrato` do SQL Server |
| 10 | `extrato_html.ktr` | Transforma o XML do extrato numa página HTML com a folha `extrato.xsl` |

O Job `etl_alojamento.kjb` corre as dez transformações por esta ordem e, no fim, limpa a lista de resultados, comprime os ficheiros `extrato_proprietarios.*` num zip e envia-o por email.

### Dados de saída (`data/output`)

É a pasta para onde as transformações gravam. Contém, como exemplo, o resultado de uma execução:

- `extrato_proprietarios.csv`, `.json`, `.xml` e `.html`: o extrato final;
- `*_validos.csv` / `*_validados.csv` / `reservas_validas.csv`: dados limpos intermédios;
- `*_rejeitados.csv` / `*_rejeitadas.csv` e ficheiros `*_sem_*.csv`: registos rejeitados ou sem correspondência.

## Como executar

### Ferramentas necessárias

- **Pentaho Data Integration (Community Edition) 10.2**, com o Spoon (https://pentaho.com); é preciso o Java instalado.
- **SQL Server** (testado em localhost, porta 1433) e o SQL Server Management Studio, para criar a base de dados.
- **Driver JDBC da Microsoft** (`mssql-jdbc`), copiado para a pasta `lib` do Spoon.
- Ligação à internet (API de câmbios Frankfurter e envio de email).
- Uma conta Gmail para enviar email.

### Passos

1. **Base de dados.** Há duas formas, em `dataintegration/sql/`:
   - **Criar de raiz:** executar `criar.sql` no SQL Server Management Studio. Cria a base de dados `alojamento` e a tabela `extrato` (chave primária em proprietário, ano e mês), vazia, para o Job a preencher.
   - **Restaurar o backup:** no SSMS, botão direito em *Bases de dados* > *Restaurar Base de Dados…* > *Dispositivo* > escolher `alojamento.bak`. Fica a base de dados `alojamento` com o extrato já carregado. 

   Para ver o conteúdo da tabela, executar `consulta_extrato.sql`.
2. **Ligação à base de dados.** Abrir `exportacao.ktr` no Spoon e verificar a ligação `destino` (servidor `localhost`, porta `1433`, base de dados `alojamento`). Ajustar o utilizador e a palavra-passe aos da instalação local. Se houver erro de certificado, acrescentar `trustServerCertificate=true` nas opções da ligação.
3. **Abrir o Job.** No Spoon, Ficheiro > Abrir e escolher `dataintegration/jobs/etl_alojamento.kjb`. Os caminhos dos ficheiros são relativos à pasta das transformações, por isso o projeto tem de manter esta estrutura de pastas.
4. **Parâmetros do Job** (Ctrl+J, separador Parameters):
   - `EMAIL_DESTINO`: endereço que recebe o email com o zip;
   - `EMAIL_PASSWORD`: palavra-passe de aplicação da conta Gmail que envia.
5. **Executar.** Carregar em **Run**. As transformações correm em sequência e os resultados são gravados em `data/output`. O Job demora cerca de um minuto, porque a transformação dos pagamentos faz um pedido à API por cada pagamento.

Para executar sem enviar email, desativar a ligação para a entrada **Mail** no Job (as transformações e o zip correm na mesma).

### Resultado esperado

- `data/output/extrato_proprietarios.*` com 15 linhas (7 do proprietário P01 e 8 do P04);
- tabela `alojamento.dbo.extrato` com as mesmas 15 linhas (`SELECT * FROM alojamento.dbo.extrato;`);
- ficheiros de rejeitados em `data/output`;
- um zip `extratos_<data>_<hora>.zip` com o extrato nos quatro formatos, enviado por email.

## Nota

- O relatório completo, com a descrição de cada transformação, está em `doc/31506_doc.pdf`.
