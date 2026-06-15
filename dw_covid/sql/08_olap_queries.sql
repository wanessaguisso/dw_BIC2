-- 08_olap_queries.sql
-- Consultas analíticas para BI (Power BI/Metabase)

-- 1. Casos confirmados por município e mês
SELECT 
    l.municipio,
    t.ano_mes,
    SUM(f.flag_confirmado) AS casos_confirmados
FROM dw.fato_notificacao_covid f
JOIN dw.dim_localidade l ON f.sk_local = l.sk_local
JOIN dw.dim_tempo t ON f.sk_data_notificacao = t.sk_tempo
WHERE f.flag_confirmado = 1
GROUP BY l.municipio, t.ano_mes
ORDER BY l.municipio, t.ano_mes;

-- 2. Letalidade por faixa etária
SELECT 
    p.faixa_etaria,
    SUM(f.qtd_notificacao) AS total_casos,
    SUM(f.flag_obito_covid) AS total_obitos,
    ROUND( (SUM(f.flag_obito_covid)::NUMERIC / NULLIF(SUM(f.qtd_notificacao), 0)) * 100, 2) AS taxa_letalidade_percentual
FROM dw.fato_notificacao_covid f
JOIN dw.dim_perfil_paciente p ON f.sk_perfil = p.sk_perfil
WHERE f.flag_confirmado = 1
GROUP BY p.faixa_etaria
ORDER BY taxa_letalidade_percentual DESC;

-- 3. Sintomas associados à internação
SELECT 
    s.febre,
    s.dif_respiratoria,
    s.tosse,
    COUNT(*) AS total_internados
FROM dw.fato_notificacao_covid f
JOIN dw.dim_sintomas s ON f.sk_sint = s.sk_sint
WHERE f.flag_internado = 1
GROUP BY s.febre, s.dif_respiratoria, s.tosse
ORDER BY total_internados DESC
LIMIT 10;

-- 4. Tempo médio até encerramento (em dias)
SELECT 
    c.evolucao,
    ROUND(AVG(f.dias_notif_encerramento), 2) AS tempo_medio_dias
FROM dw.fato_notificacao_covid f
JOIN dw.dim_classificacao c ON f.sk_class = c.sk_class
WHERE f.dias_notif_encerramento IS NOT NULL
GROUP BY c.evolucao
ORDER BY tempo_medio_dias DESC;

-- 5. Impacto das comorbidades na letalidade (exemplo com Cardiopatia)
SELECT 
    c.com_cardio,
    SUM(f.flag_confirmado) AS casos_confirmados,
    SUM(f.flag_obito_covid) AS obitos_covid,
    ROUND( (SUM(f.flag_obito_covid)::NUMERIC / NULLIF(SUM(f.flag_confirmado), 0)) * 100, 2) AS letalidade_percentual
FROM dw.fato_notificacao_covid f
JOIN dw.dim_comorbidade c ON f.sk_como = c.sk_como
WHERE f.flag_confirmado = 1
GROUP BY c.com_cardio
ORDER BY letalidade_percentual DESC;
