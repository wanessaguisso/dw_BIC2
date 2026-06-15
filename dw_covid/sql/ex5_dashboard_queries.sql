-- sql/ex5_dashboard_queries.sql
-- Consultas SQL otimizadas para plugar no Metabase ou Power BI e construir o Painel de BI

-- (a) Série Temporal de Notificações
-- Mostra a evolução diária/mensal das notificações e casos confirmados
SELECT 
    t.data AS data_notificacao,
    SUM(f.qtd_notificacao) AS total_notificacoes,
    SUM(f.flag_confirmado) AS casos_confirmados,
    SUM(f.flag_obito_covid) AS obitos_covid
FROM dw.fato_notificacao_covid f
JOIN dw.dim_tempo t ON f.sk_data_notificacao = t.sk_tempo
WHERE t.sk_tempo <> -1
GROUP BY t.data
ORDER BY t.data;


-- (b) Mapa de Calor por Município (Distribuição Espacial)
-- Agrega os casos e óbitos por município para geração do mapa
SELECT 
    l.municipio,
    l.uf,
    SUM(f.qtd_notificacao) AS total_notificacoes,
    SUM(f.flag_confirmado) AS casos_confirmados,
    SUM(f.flag_obito_covid) AS total_obitos
FROM dw.fato_notificacao_covid f
JOIN dw.dim_localidade l ON f.sk_local = l.sk_local
WHERE l.sk_local <> -1
GROUP BY l.municipio, l.uf
ORDER BY casos_confirmados DESC;


-- (c) Pirâmide Etária dos Óbitos
-- Agrega óbitos por sexo e faixa etária. Para visualização em pirâmide:
-- No BI, plota-se no gráfico de barras horizontais, configurando o masculino como valor negativo.
SELECT 
    p.faixa_etaria,
    SUM(CASE WHEN p.sexo = 'F' THEN f.flag_obito_covid ELSE 0 END) AS obitos_femininos,
    -- Multiplicado por -1 se a ferramenta de BI exigir, ou mantido positivo para ferramentas modernas
    SUM(CASE WHEN p.sexo = 'M' THEN f.flag_obito_covid ELSE 0 END) AS obitos_masculinos
FROM dw.fato_notificacao_covid f
JOIN dw.dim_perfil_paciente p ON f.sk_perfil = p.sk_perfil
WHERE f.flag_obito_covid = 1 
  AND p.sexo IN ('F', 'M') 
  AND p.faixa_etaria <> 'Desconhecida'
GROUP BY p.faixa_etaria
ORDER BY p.faixa_etaria;


-- (d) Top-5 Comorbidades em Óbitos
-- Seleciona as 5 comorbidades mais frequentes entre os pacientes que vieram a óbito por COVID-19
SELECT comorbidade, total_obitos
FROM (
    SELECT 'Cardiopatia' AS comorbidade, SUM(CASE WHEN c.com_cardio = 'Sim' THEN f.flag_obito_covid ELSE 0 END) AS total_obitos 
    FROM dw.fato_notificacao_covid f 
    JOIN dw.dim_comorbidade c ON f.sk_como = c.sk_como
    
    UNION ALL
    
    SELECT 'Diabetes', SUM(CASE WHEN c.com_diabetes = 'Sim' THEN f.flag_obito_covid ELSE 0 END) 
    FROM dw.fato_notificacao_covid f 
    JOIN dw.dim_comorbidade c ON f.sk_como = c.sk_como
    
    UNION ALL
    
    SELECT 'Obesidade', SUM(CASE WHEN c.com_obesidade = 'Sim' THEN f.flag_obito_covid ELSE 0 END) 
    FROM dw.fato_notificacao_covid f 
    JOIN dw.dim_comorbidade c ON f.sk_como = c.sk_como
    
    UNION ALL
    
    SELECT 'Doença Renal', SUM(CASE WHEN c.com_renal = 'Sim' THEN f.flag_obito_covid ELSE 0 END) 
    FROM dw.fato_notificacao_covid f 
    JOIN dw.dim_comorbidade c ON f.sk_como = c.sk_como
    
    UNION ALL
    
    SELECT 'Doença Pulmonar', SUM(CASE WHEN c.com_pulmao = 'Sim' THEN f.flag_obito_covid ELSE 0 END) 
    FROM dw.fato_notificacao_covid f 
    JOIN dw.dim_comorbidade c ON f.sk_como = c.sk_como
    
    UNION ALL
    
    SELECT 'Tabagismo', SUM(CASE WHEN c.com_tabagismo = 'Sim' THEN f.flag_obito_covid ELSE 0 END) 
    FROM dw.fato_notificacao_covid f 
    JOIN dw.dim_comorbidade c ON f.sk_como = c.sk_como
) sub
ORDER BY total_obitos DESC
LIMIT 5;
