-- 07_validation.sql
-- Consultas para validar a qualidade dos dados carregados.

-- 1. Comparar quantidade de registros
SELECT 
    (SELECT COUNT(*) FROM stg.notificacao_raw) AS qtd_staging,
    (SELECT COUNT(*) FROM dw.fato_notificacao_covid) AS qtd_fato,
    CASE 
        WHEN (SELECT COUNT(*) FROM stg.notificacao_raw) = (SELECT COUNT(*) FROM dw.fato_notificacao_covid) 
        THEN 'SUCESSO: Quantidades batem' 
        ELSE 'ERRO: Divergência nas quantidades' 
    END AS status_quantidades;

-- 2. Verificar se todas as FKs possuem valor (nunca nulas)
SELECT 
    COUNT(*) AS fks_nulas_fato 
FROM dw.fato_notificacao_covid
WHERE 
    sk_data_notificacao IS NULL OR
    sk_local IS NULL OR
    sk_perfil IS NULL OR
    sk_class IS NULL OR
    sk_sint IS NULL OR
    sk_como IS NULL OR
    sk_teste IS NULL;

-- 3. Registros órfãos (ex: fato aponta para FK que não existe na dimensão)
SELECT COUNT(*) AS orfaos_local
FROM dw.fato_notificacao_covid f
LEFT JOIN dw.dim_localidade d ON f.sk_local = d.sk_local
WHERE d.sk_local IS NULL;

-- 4. Garantir existência do membro Desconhecido (-1)
SELECT 
    'dim_localidade' AS dimensao, COUNT(*) AS qtd_desconhecido FROM dw.dim_localidade WHERE sk_local = -1
UNION ALL
SELECT 'dim_perfil_paciente', COUNT(*) FROM dw.dim_perfil_paciente WHERE sk_perfil = -1
UNION ALL
SELECT 'dim_classificacao', COUNT(*) FROM dw.dim_classificacao WHERE sk_class = -1
UNION ALL
SELECT 'dim_sintomas', COUNT(*) FROM dw.dim_sintomas WHERE sk_sint = -1
UNION ALL
SELECT 'dim_comorbidade', COUNT(*) FROM dw.dim_comorbidade WHERE sk_como = -1
UNION ALL
SELECT 'dim_teste', COUNT(*) FROM dw.dim_teste WHERE sk_teste = -1
UNION ALL
SELECT 'dim_tempo', COUNT(*) FROM dw.dim_tempo WHERE sk_tempo = -1;
