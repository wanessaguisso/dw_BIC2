-- sql/ex4_datamart_materialized_view.sql
-- Criação de Materialized View no schema mart para pré-agregação de dados por município e mês

DROP MATERIALIZED VIEW IF EXISTS mart.mv_resumo_municipio_mes;

CREATE MATERIALIZED VIEW mart.mv_resumo_municipio_mes AS
SELECT 
    l.municipio,
    t.ano_mes,
    t.ano,
    t.mes,
    SUM(f.flag_confirmado) AS total_confirmados,
    SUM(f.flag_obito_covid) AS total_obitos,
    SUM(f.flag_internado) AS total_internacoes,
    SUM(f.qtd_notificacao) AS total_notificacoes
FROM dw.fato_notificacao_covid f
JOIN dw.dim_localidade l ON f.sk_local = l.sk_local
JOIN dw.dim_tempo t ON f.sk_data_notificacao = t.sk_tempo
GROUP BY l.municipio, t.ano_mes, t.ano, t.mes;

-- Criação de índice único na view materializada para acelerar as buscas geográficas e temporais
CREATE UNIQUE INDEX idx_mv_resumo_municipio_mes ON mart.mv_resumo_municipio_mes(municipio, ano_mes);

-- Para atualizar a materialized view futuramente:
-- REFRESH MATERIALIZED VIEW mart.mv_resumo_municipio_mes;


/*
================================================================================
AVALIAÇÃO DE PERFORMANCE COM EXPLAIN ANALYZE
================================================================================

Abaixo estão as duas consultas equivalentes que realizam a busca de confirmados,
óbitos e internações para um município e período específicos.

1. CONSULTA SEM A MATERIALIZED VIEW (Acessando tabelas base diretamente - Fato com ~5M linhas):

EXPLAIN ANALYZE
SELECT 
    l.municipio,
    t.ano_mes,
    SUM(f.flag_confirmado) AS total_confirmados,
    SUM(f.flag_obito_covid) AS total_obitos,
    SUM(f.flag_internado) AS total_internacoes
FROM dw.fato_notificacao_covid f
JOIN dw.dim_localidade l ON f.sk_local = l.sk_local
JOIN dw.dim_tempo t ON f.sk_data_notificacao = t.sk_tempo
WHERE l.municipio = 'SERRA' AND t.ano_mes = '2021-03'
GROUP BY l.municipio, t.ano_mes;

-- Explicação da Execução sem MV:
-- O banco precisará fazer JOIN da tabela fato (milhões de linhas) com a dim_localidade e dim_tempo,
-- filtrar pelas chaves e depois aplicar GROUP BY / aggregation. Mesmo com índices nas chaves estrangeiras
-- da fato (ex: idx_fato_local), a leitura de muitas páginas e o processamento de joins têm custo elevado (geralmente centenas de milissegundos).


2. CONSULTA COM A MATERIALIZED VIEW (Acessando a pré-agregação - centenas/poucas milhares de linhas):

EXPLAIN ANALYZE
SELECT 
    municipio,
    ano_mes,
    total_confirmados,
    total_obitos,
    total_internacoes
FROM mart.mv_resumo_municipio_mes
WHERE municipio = 'SERRA' AND ano_mes = '2021-03';

-- Explicação da Execução com MV:
-- O banco faz uma busca direta (Index Scan) no índice idx_mv_resumo_municipio_mes.
-- Não há JOINs de tabelas pesadas nem agrupamentos em tempo de execução, retornando o resultado
-- instantaneamente (geralmente < 1 milissegundo), resultando em ganhos de performance de mais de 100x a 1000x.
*/
