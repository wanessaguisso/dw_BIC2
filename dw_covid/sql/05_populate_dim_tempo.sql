-- 05_populate_dim_tempo.sql
-- Popula a dimensão de tempo com datas de 2020 a 2030, além do membro Desconhecido (-1)

-- 1. Inserir o membro Desconhecido
INSERT INTO dw.dim_tempo (sk_tempo, data, dia, mes, ano, trimestre, nome_mes, dia_semana, ano_mes, eh_fim_de_semana, semana_epidemiologica)
VALUES (-1, '1900-01-01', -1, -1, -1, -1, 'Desconhecido', 'Desconhecido', 'Desc', false, -1)
ON CONFLICT (sk_tempo) DO NOTHING;

-- 2. Gerar datas de 2020-01-01 a 2030-12-31
WITH dates AS (
    SELECT generate_series(
        '2019-01-01'::DATE,
        '2030-12-31'::DATE,
        '1 day'::interval
    )::DATE AS dt
)
INSERT INTO dw.dim_tempo (sk_tempo, data, dia, mes, ano, trimestre, nome_mes, dia_semana, ano_mes, eh_fim_de_semana, semana_epidemiologica)
SELECT
    TO_CHAR(dt, 'YYYYMMDD')::INT AS sk_tempo,
    dt AS data,
    EXTRACT(DAY FROM dt) AS dia,
    EXTRACT(MONTH FROM dt) AS mes,
    EXTRACT(YEAR FROM dt) AS ano,
    EXTRACT(QUARTER FROM dt) AS trimestre,
    CASE EXTRACT(MONTH FROM dt)
        WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril' WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' WHEN 12 THEN 'Dezembro'
    END AS nome_mes,
    CASE EXTRACT(DOW FROM dt)
        WHEN 0 THEN 'Domingo' WHEN 1 THEN 'Segunda-feira' WHEN 2 THEN 'Terça-feira'
        WHEN 3 THEN 'Quarta-feira' WHEN 4 THEN 'Quinta-feira' WHEN 5 THEN 'Sexta-feira'
        WHEN 6 THEN 'Sábado'
    END AS dia_semana,
    TO_CHAR(dt, 'YYYY-MM') AS ano_mes,
    CASE WHEN EXTRACT(DOW FROM dt) IN (0, 6) THEN true ELSE false END AS eh_fim_de_semana,
    EXTRACT(WEEK FROM dt) AS semana_epidemiologica
FROM dates
ON CONFLICT (sk_tempo) DO NOTHING;
