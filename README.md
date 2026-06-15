# Data Warehouse - Notificações COVID-19 (Espírito Santo)

Este projeto implementa um **Data Warehouse analítico completo** a partir dos microdados de notificações de COVID-19 do Espírito Santo (aprox. 5,19 milhões de registros). A solução foi construída utilizando **PostgreSQL** para o banco de dados e **Python** para a orquestração do processo de ETL, seguindo a arquitetura dimensional de **Kimball (Star Schema)**.

---

## 🏗️ Visão do Projeto e Arquitetura

O DW foi projetado para responder rapidamente a consultas analíticas (OLAP) focadas no perfil dos pacientes, evolução da doença, testes aplicados e distribuição temporal/geográfica.

A arquitetura do pipeline é composta por:
1. **Origem (Data Source):** Arquivo `MICRODADOS.csv` original colocado no diretório `data/`.
2. **Camada Staging:** Schema `stg` e tabela `notificacao_raw` (dados brutos, todas colunas `TEXT`, carga rápida de alta performance via `COPY`).
3. **ETL (Python/SQL):** 
   - Extração e de-duplicação de dimensões.
   - Tratamento de nulos/vazios substituindo por `Desconhecido` (Surrogate Key = -1).
   - Conversão de tipos de dados (datas, inteiros).
4. **Camada Dimensional (Data Warehouse):** Schema `dw` com tabela fato e dimensões otimizadas com índices.
5. **Acesso/BI:** Acesso seguro direto no schema `dw` (ou `mart`) para consumo por ferramentas como Power BI, Metabase ou Tableau.

---

## 📂 Estrutura do Projeto

```text
dw_covid/
├── data/
│   └── MICRODADOS.csv          <-- (Crie esta pasta e coloque o arquivo CSV aqui)
├── sql/
│   ├── 01_create_database.sql  <-- Cria schemas stg, dw e mart
│   ├── 02_create_staging.sql   <-- Cria tabela bruta notificacao_raw
│   ├── 03_create_dimensions.sql<-- Cria as tabelas de dimensões
│   ├── 04_create_fact.sql      <-- Cria a tabela fato e seus índices
│   ├── 05_populate_dim_tempo.sql<-- Popula a dimensão tempo (calendário 2019 a 2030)
│   ├── 06_load_fact.sql        <-- JOINs e carga pesada na fato
│   ├── 07_validation.sql       <-- Scripts de auditoria e qualidade
│   └── 08_olap_queries.sql     <-- Exemplos de consultas analíticas
├── etl/
│   ├── config.py               <-- Leitura do .env e constantes de caminhos
│   ├── connection.py           <-- Configuração de conexões psycopg2 / sqlalchemy (com suporte a SSL)
│   ├── create_schema.py        <-- Script auxiliar para criar todas as tabelas via Python
│   ├── utils.py                <-- Funções de auxílio e logger do sistema
│   ├── load_staging.py         <-- Lê o CSV e executa a carga na staging via COPY
│   ├── etl_dimensions.py       <-- Processa e popula as tabelas de dimensões
│   ├── etl_fact.py             <-- Executa a carga dimensional na fato
│   └── validations.py          <-- Validações de integridade do DW usando Pandas
├── logs/                       <-- Logs detalhados gerados pelas execuções
├── .env.example                <-- Template de variáveis do banco
├── requirements.txt            <-- Bibliotecas Python necessárias
└── README.md
```

---

## 🚀 Como Instalar e Configurar

### 1. Pré-requisitos
* **Python 3.10+** instalado.
* Banco de dados **PostgreSQL** rodando (localmente ou na nuvem, como o Aiven PostgreSQL).

### 2. Configurar o Ambiente Python
Recomenda-se utilizar um ambiente virtual (`venv`):

```bash
# Crie o ambiente virtual
python -m venv .venv

# Ative o ambiente virtual (Windows PowerShell)
.venv\Scripts\Activate.ps1

# Ative o ambiente virtual (Linux/macOS)
source .venv/bin/activate

# Instale os pacotes necessários
pip install -r requirements.txt
```

### 3. Configurar Variáveis de Ambiente (`.env`)
Copie o arquivo `.env.example` para `.env` na raiz do projeto e ajuste as credenciais do seu banco de dados:

```bash
# Copiar no Linux/macOS
cp .env.example .env

# Copiar no Windows PowerShell
Copy-Item .env.example .env
```

Abra o arquivo `.env` e configure conforme seu banco de dados. Exemplo para conexão segura com banco na nuvem (Aiven):
```env
DB_HOST=pg-13200445-nhui.a.aivencloud.com
DB_PORT=15697
DB_USER=avnadmin
DB_PASSWORD=SUA_SENHA_AQUI
DB_NAME=defaultdb
DB_SSLMODE=require   # IMPORTANTE: Use 'require' para bancos na nuvem como Aiven

DATA_DIR=data
CSV_FILENAME=MICRODADOS.csv
LOGS_DIR=logs
```

---

## ⚡ Como Rodar o Projeto

### Passo 1: Organizar os Dados
Certifique-se de que criou a pasta `data` na raiz do projeto e colocou o arquivo `MICRODADOS.csv` lá dentro.

### Passo 2: Criar as Estruturas no Banco (Schemas e Tabelas)
Você pode rodar a criação de toda a estrutura do banco diretamente usando o script Python automatizado (o qual lê os arquivos SQL e conecta ao banco respeitando o SSL):

```bash
python etl/create_schema.py
```
*(Esse comando criará automaticamente os schemas `stg`, `dw` e `mart`, além de todas as tabelas de staging, dimensões e fato e o calendário de tempo).*

---

### Passo 3: Executar a Carga de Dados (Pipeline de ETL)
Na raiz do projeto, com seu ambiente virtual ativado, execute os três scripts na ordem exata:

```bash
# 1. Carrega o CSV bruto para o banco de dados usando COPY (Etapa Staging)
python etl/load_staging.py

# 2. Processa os dados brutos e gera os registros com Surrogate Keys nas Dimensões
python etl/etl_dimensions.py

# 3. Faz o cruzamento dimensional (JOINs) e insere os registros na tabela Fato
python etl/etl_fact.py

# 4. (Opcional) Executa auditoria automatizada nas tabelas
python etl/validations.py
```

---

## 🔌 Conectando o Banco de Dados em Ferramentas Externas

### 1. Extensões de Banco do VS Code (Database Client / SQLTools)
Ao se conectar a bancos de dados na nuvem (Aiven, RDS, etc.), você poderá receber o erro `self signed certificate in certificate chain` ou `Connection terminated unexpectedly`. Para resolver:

* **Configurando por formulário:**
  * Altere a opção **SSL** de `Disabled` para **`Enabled`** (ou `Require`).
  * Baixe o **CA Certificate** (`ca.pem`) do painel do seu provedor de banco de dados e anexe-o no campo de seleção de arquivos **`CA / CA Cert Path`**.
  * Se o cliente exigir parâmetros específicos para ignorar a validação estrita do certificado (em ambiente de dev), preencha o campo **SSL** com o objeto JSON: `{"rejectUnauthorized": false}`.
* **Configurando por String de Conexão:**
  * Altere o modo de conexão para `Connection String` e insira a URI completa que já traz os parâmetros de SSL:
    `postgres://avnadmin:SUA_SENHA@pg-13200445-nhui.a.aivencloud.com:15697/defaultdb?sslmode=require`

### 2. Conectando no Power BI
1. Abra o **Power BI Desktop**.
2. Clique em **Obter Dados (Get Data)** -> **Banco de dados do PostgreSQL**.
3. Preencha os campos com as credenciais do seu `.env`:
   * **Servidor (Server):** `pg-13200445-nhui.a.aivencloud.com:15697` (ou se o campo porta for separado, divida host e porta).
   * **Banco de dados (Database):** `defaultdb`
4. Na tela de login de credenciais, digite o usuário (`avnadmin`) e a senha.
5. Selecione a opção de conexão segura SSL se for perguntado.
6. Na lista de tabelas, marque as tabelas pertencentes ao schema **`dw`**:
   * `fato_notificacao_covid`
   * `dim_localidade`
   * `dim_perfil_paciente`
   * `dim_classificacao`
   * `dim_sintomas`
   * `dim_comorbidade`
   * `dim_teste`
   * `dim_tempo`
7. Como as tabelas possuem relacionamentos físicos de chave primária/estrangeira no banco de dados, o Power BI detectará o modelo Star Schema de forma totalmente automática.

---

## 📈 Consultas OLAP
Após concluir a carga, você pode utilizar as queries prontas em `sql/08_olap_queries.sql` para extrair relatórios diretamente via comandos SQL, tais como a taxa de letalidade por perfil ou as comorbidades mais comuns em casos de óbito.

