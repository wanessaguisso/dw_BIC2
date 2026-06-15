-- sql/ex6_scd_tipo2.sql
-- Proposta de Adaptação da DIM_LOCALIDADE para SCD (Slowly Changing Dimension) Tipo 2

-- DDL com adaptações para rastreamento histórico:

DROP TABLE IF EXISTS dw.dim_localidade_scd2 CASCADE;

CREATE TABLE dw.dim_localidade_scd2 (
    -- Chave Substituta (Surrogate Key) continua como PK única física da tabela.
    -- Ela irá mudar para o mesmo município/bairro a cada nova versão gerada.
    sk_local SERIAL PRIMARY KEY,
    
    -- Chave de Negócio (Natural Key)
    municipio VARCHAR(255),
    bairro VARCHAR(255),
    
    -- Atributos Geográficos
    uf VARCHAR(50),
    regiao_es VARCHAR(100),
    macrorregiao VARCHAR(100),
    
    -- Novo Atributo Mutável no Tempo
    populacao_municipio INT,
    
    -- Metadados de Controle do SCD Tipo 2
    data_inicio DATE NOT NULL,               -- Data de ativação desta versão do registro
    data_fim DATE,                           -- Data de expiração da versão (NULL ou '9999-12-31' indica versão ativa)
    flag_atual BOOLEAN NOT NULL DEFAULT TRUE -- TRUE indica se esta é a versão vigente
);

-- Como NÃO podemos mais ter um índice UNIQUE simples em (municipio, bairro) 
-- (pois haverá múltiplos registros históricos para a mesma combinação),
-- criamos um índice parcial único para garantir que exista apenas uma versão ativa por vez:
CREATE UNIQUE INDEX uq_localidade_vigente ON dw.dim_localidade_scd2 (municipio, bairro) WHERE flag_atual = TRUE;


/*
================================================================================
ESTRATÉGIA DE CARGA (ETL MERGE / INSERT) PARA SCD TIPO 2
================================================================================

Quando uma nova carga de dados da staging (ou de um cadastro de população) ocorrer,
o pipeline de ETL deve seguir os seguintes passos para cada registro de município:

1. IDENTIFICAÇÃO DE MUDANÇA:
   Selecionar registros da staging e comparar com a dimensão ativa (`flag_atual = TRUE`):
   - Se o município/bairro não existir na dimensão: **Caso 1 (Novo Registro)**.
   - Se o município/bairro existir na dimensão, mas o valor de `populacao_municipio` for diferente: **Caso 2 (Alteração de Atributo)**.
   - Se existir e o valor for igual: **Não faz nada**.

2. PROCESSAMENTO:
   
   - **Caso 1: Novo Registro**
     Inserir diretamente na dimensão:
     - `data_inicio` = Data da carga (ou data do censo/população)
     - `data_fim` = NULL (ou '9999-12-31')
     - `flag_atual` = TRUE
     
   - **Caso 2: Alteração de Atributo (Mudança de População)**
     Requer duas operações dentro de uma mesma transação:
     
     A. **Expirar a versão atual (Update):**
        Atualizar o registro atual na dimensão:
        ```sql
        UPDATE dw.dim_localidade_scd2
        SET data_fim = CURRENT_DATE - INTERVAL '1 day',
            flag_atual = FALSE
        WHERE municipio = :municipio AND bairro = :bairro AND flag_atual = TRUE;
        ```
        
     B. **Inserir a nova versão (Insert):**
        Inserir o novo registro com o valor populacional atualizado:
        ```sql
        INSERT INTO dw.dim_localidade_scd2 (municipio, bairro, uf, regiao_es, macrorregiao, populacao_municipio, data_inicio, data_fim, flag_atual)
        VALUES (:municipio, :bairro, :uf, :regiao_es, :macrorregiao, :populacao_nova, CURRENT_DATE, NULL, TRUE);
        ```

3. CONSISTÊNCIA NA TABELA FATO:
   No modelo SCD Tipo 2, a Tabela Fato NÃO sofre updates em suas chaves estrangeiras (`sk_local`) históricas.
   Ao carregar novos fatos (notificações ocorridas em uma data X), o JOIN da Fato com a Dimissão deve buscar a SK correspondente à versão que estava ativa no momento da ocorrência:
   
   ```sql
   LEFT JOIN dw.dim_localidade_scd2 l ON
       l.municipio = s.Municipio AND
       l.bairro = s.Bairro AND
       s.DataNotificacao::DATE >= l.data_inicio AND 
       (l.data_fim IS NULL OR s.DataNotificacao::DATE <= l.data_fim)
   ```
   Isso garante que cada fato aponte para a SK correspondente ao valor histórico de população correto na data da notificação!
*/
