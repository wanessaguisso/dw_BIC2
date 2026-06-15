-- sql/ex2_snowflake_localidade.sql
-- Proposta de Modelagem Alternativa (Floco de Neve / Snowflake) para a DIM_LOCALIDADE

/*
================================================================================
COMPARAÇÃO: ESTRELA (STAR) vs. FLOCO DE NEVE (SNOWFLAKE)
================================================================================

| Critério               | Estrela (Star Schema) - Desnormalizado              | Floco de Neve (Snowflake) - Normalizado                |
|------------------------|-----------------------------------------------------|-------------------------------------------------------|
| Letura/Performance     | **Excelente**: Apenas 1 JOIN da Fato com a dimensão | **Menor**: Requer múltiplos JOINs em cascata para      |
|                        | para obter todos os níveis da hierarquia.            | buscar os dados (bairro -> município -> região -> macro).|
| Armazenamento          | **Maior redundância**: Repete strings (ex: regiões,   | **Otimizado**: Menor redundância, armazenando strings   |
|                        | macroregiões) para cada combinação de bairro/munic. | das entidades de nível superior apenas uma vez.       |
| Manutenção/Integridade | **Complexa**: Inconsistências de escrita (ex: erros  | **Simples/Robusta**: Regras de FK garantem integridade |
|                        | de digitação na região) devem ser tratadas no ETL.  | referencial estrita entre níveis hierárquicos.         |
| Complexidade ETL       | **Simples**: Carga em passo único (Select Distinct).| **Complexa**: Carga em múltiplos passos ordenados     |
|                        |                                                     | (macro -> região -> município -> localidade).        |
| Usabilidade para BI   | **Fácil**: Ideal para drill-down direto e amigável   | **Mais complexa**: Usuários de negócio ou ferramentas  |
|                        | para ferramentas de BI.                              | de BI precisam conhecer os relacionamentos complexos. |

Recomendação: Para Data Warehouses analíticos típicos, o modelo ESTRELA é preferível (pelo foco em performance de leitura e simplicidade de consumo). O modelo FLOCO DE NEVE é útil em casos de dimensões gigantescas com alta redundância de dados que justifiquem a economia de espaço, ou quando a integridade cadastral rigorosa é o requisito primário.
================================================================================
*/

-- DDL do Modelo Snowflake para Localidade

-- 1. Tabela Macrorregião
DROP TABLE IF EXISTS dw.dim_macrorregiao CASCADE;
CREATE TABLE dw.dim_macrorregiao (
    sk_macrorregiao SERIAL PRIMARY KEY,
    macrorregiao VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Tabela Região de Saúde (Vinculada a Macrorregião)
DROP TABLE IF EXISTS dw.dim_regiao CASCADE;
CREATE TABLE dw.dim_regiao (
    sk_regiao SERIAL PRIMARY KEY,
    regiao_es VARCHAR(100) NOT NULL UNIQUE,
    sk_macrorregiao INT NOT NULL REFERENCES dw.dim_macrorregiao(sk_macrorregiao)
);

-- 3. Tabela Município (Vinculada a Região)
DROP TABLE IF EXISTS dw.dim_municipio CASCADE;
CREATE TABLE dw.dim_municipio (
    sk_municipio SERIAL PRIMARY KEY,
    municipio VARCHAR(255) NOT NULL UNIQUE,
    uf CHAR(2) NOT NULL DEFAULT 'ES',
    sk_regiao INT NOT NULL REFERENCES dw.dim_regiao(sk_regiao)
);

-- 4. Tabela Localidade (Bairro - Nível mais fino da hierarquia, vinculada a Município)
DROP TABLE IF EXISTS dw.dim_localidade_snowflake CASCADE;
CREATE TABLE dw.dim_localidade_snowflake (
    sk_local SERIAL PRIMARY KEY,
    bairro VARCHAR(255) NOT NULL,
    sk_municipio INT NOT NULL REFERENCES dw.dim_municipio(sk_municipio),
    CONSTRAINT uq_bairro_municipio UNIQUE (bairro, sk_municipio)
);

-- Povoamento de Membros "Desconhecido" para Integridade Referencial
INSERT INTO dw.dim_macrorregiao (sk_macrorregiao, macrorregiao)
VALUES (-1, 'Desconhecido')
ON CONFLICT (sk_macrorregiao) DO NOTHING;

INSERT INTO dw.dim_regiao (sk_regiao, regiao_es, sk_macrorregiao)
VALUES (-1, 'Desconhecido', -1)
ON CONFLICT (sk_regiao) DO NOTHING;

INSERT INTO dw.dim_municipio (sk_municipio, municipio, uf, sk_regiao)
VALUES (-1, 'Desconhecido', 'ES', -1)
ON CONFLICT (sk_municipio) DO NOTHING;

INSERT INTO dw.dim_localidade_snowflake (sk_local, bairro, sk_municipio)
VALUES (-1, 'Desconhecido', -1)
ON CONFLICT (sk_local) DO NOTHING;
