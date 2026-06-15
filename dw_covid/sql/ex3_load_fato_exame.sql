-- sql/ex3_load_fato_exame.sql
-- Carga da tabela dw.fato_exame a partir da tabela de staging stg.notificacao_raw

TRUNCATE TABLE dw.fato_exame;

-- Usamos múltiplos INSERTs para processar cada tipo de exame separadamente.
-- Isso é mais performático e evita consumo excessivo de memória temporária.

-- 1. Carga de exames do tipo RT-PCR
INSERT INTO dw.fato_exame (
    sk_data_notificacao, sk_data_coleta, sk_local, sk_perfil, tipo_exame, resultado_exame, qtd_exame
)
SELECT 
    COALESCE(convert_date_sk(s.DataNotificacao), -1),
    COALESCE(convert_date_sk(s.DataColeta_RT_PCR), -1),
    COALESCE(l.sk_local, -1),
    COALESCE(p.sk_perfil, -1),
    'RT-PCR' AS tipo_exame,
    COALESCE(NULLIF(TRIM(s.ResultadoRT_PCR), ''), 'Desconhecido') AS resultado_exame,
    1 AS qtd_exame
FROM stg.notificacao_raw s
LEFT JOIN dw.dim_localidade l ON 
    l.municipio = COALESCE(NULLIF(TRIM(s.Municipio), ''), 'Desconhecido') AND
    l.bairro = COALESCE(NULLIF(TRIM(s.Bairro), ''), 'Desconhecido')
LEFT JOIN dw.dim_perfil_paciente p ON 
    p.sexo = COALESCE(NULLIF(TRIM(s.Sexo), ''), 'Desconhecido') AND
    p.faixa_etaria = COALESCE(NULLIF(TRIM(s.FaixaEtaria), ''), 'Desconhecido') AND
    p.raca_cor = COALESCE(NULLIF(TRIM(s.RacaCor), ''), 'Desconhecido') AND
    p.escolaridade = COALESCE(NULLIF(TRIM(s.Escolaridade), ''), 'Desconhecido') AND
    p.gestante = COALESCE(NULLIF(TRIM(s.Gestante), ''), 'Desconhecido') AND
    p.profissional_saude = COALESCE(NULLIF(TRIM(s.ProfissionalSaude), ''), 'Desconhecido') AND
    p.morador_rua = COALESCE(NULLIF(TRIM(s.MoradorDeRua), ''), 'Desconhecido') AND
    p.possui_deficiencia = COALESCE(NULLIF(TRIM(s.PossuiDeficiencia), ''), 'Desconhecido')
WHERE 
    (NULLIF(TRIM(s.ResultadoRT_PCR), '') IS NOT NULL AND s.ResultadoRT_PCR <> 'Não Informado') OR
    NULLIF(TRIM(s.DataColeta_RT_PCR), '') IS NOT NULL;

-- 2. Carga de exames do tipo Teste Rápido
INSERT INTO dw.fato_exame (
    sk_data_notificacao, sk_data_coleta, sk_local, sk_perfil, tipo_exame, resultado_exame, qtd_exame
)
SELECT 
    COALESCE(convert_date_sk(s.DataNotificacao), -1),
    COALESCE(convert_date_sk(s.DataColetaTesteRapido), -1),
    COALESCE(l.sk_local, -1),
    COALESCE(p.sk_perfil, -1),
    COALESCE(NULLIF(TRIM(s.TipoTesteRapido), ''), 'Teste Rápido') AS tipo_exame,
    COALESCE(NULLIF(TRIM(s.ResultadoTesteRapido), ''), 'Desconhecido') AS resultado_exame,
    1 AS qtd_exame
FROM stg.notificacao_raw s
LEFT JOIN dw.dim_localidade l ON 
    l.municipio = COALESCE(NULLIF(TRIM(s.Municipio), ''), 'Desconhecido') AND
    l.bairro = COALESCE(NULLIF(TRIM(s.Bairro), ''), 'Desconhecido')
LEFT JOIN dw.dim_perfil_paciente p ON 
    p.sexo = COALESCE(NULLIF(TRIM(s.Sexo), ''), 'Desconhecido') AND
    p.faixa_etaria = COALESCE(NULLIF(TRIM(s.FaixaEtaria), ''), 'Desconhecido') AND
    p.raca_cor = COALESCE(NULLIF(TRIM(s.RacaCor), ''), 'Desconhecido') AND
    p.escolaridade = COALESCE(NULLIF(TRIM(s.Escolaridade), ''), 'Desconhecido') AND
    p.gestante = COALESCE(NULLIF(TRIM(s.Gestante), ''), 'Desconhecido') AND
    p.profissional_saude = COALESCE(NULLIF(TRIM(s.ProfissionalSaude), ''), 'Desconhecido') AND
    p.morador_rua = COALESCE(NULLIF(TRIM(s.MoradorDeRua), ''), 'Desconhecido') AND
    p.possui_deficiencia = COALESCE(NULLIF(TRIM(s.PossuiDeficiencia), ''), 'Desconhecido')
WHERE 
    (NULLIF(TRIM(s.ResultadoTesteRapido), '') IS NOT NULL AND s.ResultadoTesteRapido <> 'Não Informado') OR
    NULLIF(TRIM(s.DataColetaTesteRapido), '') IS NOT NULL OR
    NULLIF(TRIM(s.TipoTesteRapido), '') IS NOT NULL;

-- 3. Carga de exames do tipo Sorologia (IgG/IgM total)
INSERT INTO dw.fato_exame (
    sk_data_notificacao, sk_data_coleta, sk_local, sk_perfil, tipo_exame, resultado_exame, qtd_exame
)
SELECT 
    COALESCE(convert_date_sk(s.DataNotificacao), -1),
    COALESCE(convert_date_sk(s.DataColetaSorologia), -1),
    COALESCE(l.sk_local, -1),
    COALESCE(p.sk_perfil, -1),
    'Sorologia' AS tipo_exame,
    COALESCE(NULLIF(TRIM(s.ResultadoSorologia), ''), 'Desconhecido') AS resultado_exame,
    1 AS qtd_exame
FROM stg.notificacao_raw s
LEFT JOIN dw.dim_localidade l ON 
    l.municipio = COALESCE(NULLIF(TRIM(s.Municipio), ''), 'Desconhecido') AND
    l.bairro = COALESCE(NULLIF(TRIM(s.Bairro), ''), 'Desconhecido')
LEFT JOIN dw.dim_perfil_paciente p ON 
    p.sexo = COALESCE(NULLIF(TRIM(s.Sexo), ''), 'Desconhecido') AND
    p.faixa_etaria = COALESCE(NULLIF(TRIM(s.FaixaEtaria), ''), 'Desconhecido') AND
    p.raca_cor = COALESCE(NULLIF(TRIM(s.RacaCor), ''), 'Desconhecido') AND
    p.escolaridade = COALESCE(NULLIF(TRIM(s.Escolaridade), ''), 'Desconhecido') AND
    p.gestante = COALESCE(NULLIF(TRIM(s.Gestante), ''), 'Desconhecido') AND
    p.profissional_saude = COALESCE(NULLIF(TRIM(s.ProfissionalSaude), ''), 'Desconhecido') AND
    p.morador_rua = COALESCE(NULLIF(TRIM(s.MoradorDeRua), ''), 'Desconhecido') AND
    p.possui_deficiencia = COALESCE(NULLIF(TRIM(s.PossuiDeficiencia), ''), 'Desconhecido')
WHERE 
    (NULLIF(TRIM(s.ResultadoSorologia), '') IS NOT NULL AND s.ResultadoSorologia <> 'Não Informado') OR
    NULLIF(TRIM(s.DataColetaSorologia), '') IS NOT NULL;

-- 4. Carga de exames do tipo Sorologia IgG
INSERT INTO dw.fato_exame (
    sk_data_notificacao, sk_data_coleta, sk_local, sk_perfil, tipo_exame, resultado_exame, qtd_exame
)
SELECT 
    COALESCE(convert_date_sk(s.DataNotificacao), -1),
    COALESCE(convert_date_sk(s.DataColetaSorologiaIGG), -1),
    COALESCE(l.sk_local, -1),
    COALESCE(p.sk_perfil, -1),
    'Sorologia IgG' AS tipo_exame,
    COALESCE(NULLIF(TRIM(s.ResultadoSorologia_IGG), ''), 'Desconhecido') AS resultado_exame,
    1 AS qtd_exame
FROM stg.notificacao_raw s
LEFT JOIN dw.dim_localidade l ON 
    l.municipio = COALESCE(NULLIF(TRIM(s.Municipio), ''), 'Desconhecido') AND
    l.bairro = COALESCE(NULLIF(TRIM(s.Bairro), ''), 'Desconhecido')
LEFT JOIN dw.dim_perfil_paciente p ON 
    p.sexo = COALESCE(NULLIF(TRIM(s.Sexo), ''), 'Desconhecido') AND
    p.faixa_etaria = COALESCE(NULLIF(TRIM(s.FaixaEtaria), ''), 'Desconhecido') AND
    p.raca_cor = COALESCE(NULLIF(TRIM(s.RacaCor), ''), 'Desconhecido') AND
    p.escolaridade = COALESCE(NULLIF(TRIM(s.Escolaridade), ''), 'Desconhecido') AND
    p.gestante = COALESCE(NULLIF(TRIM(s.Gestante), ''), 'Desconhecido') AND
    p.profissional_saude = COALESCE(NULLIF(TRIM(s.ProfissionalSaude), ''), 'Desconhecido') AND
    p.morador_rua = COALESCE(NULLIF(TRIM(s.MoradorDeRua), ''), 'Desconhecido') AND
    p.possui_deficiencia = COALESCE(NULLIF(TRIM(s.PossuiDeficiencia), ''), 'Desconhecido')
WHERE 
    (NULLIF(TRIM(s.ResultadoSorologia_IGG), '') IS NOT NULL AND s.ResultadoSorologia_IGG <> 'Não Informado') OR
    NULLIF(TRIM(s.DataColetaSorologiaIGG), '') IS NOT NULL;
