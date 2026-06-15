-- 06_load_fact.sql
-- Insere os dados da staging na tabela fato resolvendo as Surrogate Keys

-- Primeiro vamos criar uma função de apoio para extrair inteiros da staging (idade, etc)
CREATE OR REPLACE FUNCTION stg_to_int(val TEXT) RETURNS INT AS $$
BEGIN
    RETURN NULLIF(REGEXP_REPLACE(val, '[^0-9-]', '', 'g'), '')::INT;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION convert_date_sk(val TEXT) RETURNS INT AS $$
DECLARE
    dt DATE;
BEGIN
    IF val IS NULL OR val = '' OR val = 'Desconhecido' THEN
        RETURN -1;
    END IF;
    -- Tenta converter a data (supondo formato YYYY-MM-DD)
    dt := val::DATE;
    RETURN TO_CHAR(dt, 'YYYYMMDD')::INT;
EXCEPTION WHEN OTHERS THEN
    RETURN -1;
END;
$$ LANGUAGE plpgsql;

-- O insert da fato (este comando seria o core do ETL Python ou executado diretamente)
-- Observação: Este script limpa a fato antes de inserir.
TRUNCATE TABLE dw.fato_notificacao_covid;

INSERT INTO dw.fato_notificacao_covid (
    sk_data_notificacao, sk_data_cadastro, sk_data_diagnostico, sk_data_coleta, 
    sk_data_encerramento, sk_data_obito, sk_local, sk_perfil, sk_class, sk_sint, sk_como, sk_teste,
    qtd_notificacao, flag_confirmado, flag_obito_covid, flag_internado, flag_cura,
    idade_anos, dias_notif_encerramento, dias_notif_obito
)
SELECT 
    COALESCE(convert_date_sk(s.DataNotificacao), -1),
    COALESCE(convert_date_sk(s.DataCadastro), -1),
    COALESCE(convert_date_sk(s.DataDiagnostico), -1),
    COALESCE(convert_date_sk(s.DataColeta_RT_PCR), -1),
    COALESCE(convert_date_sk(s.DataEncerramento), -1),
    COALESCE(convert_date_sk(s.DataObito), -1),
    COALESCE(l.sk_local, -1),
    COALESCE(p.sk_perfil, -1),
    COALESCE(c.sk_class, -1),
    COALESCE(sint.sk_sint, -1),
    COALESCE(como.sk_como, -1),
    COALESCE(t.sk_teste, -1),
    
    1 AS qtd_notificacao,
    CASE WHEN s.Classificacao ILIKE '%Confirmado%' THEN 1 ELSE 0 END AS flag_confirmado,
    CASE WHEN s.Evolucao ILIKE '%Óbito pelo agravo%' THEN 1 ELSE 0 END AS flag_obito_covid,
    CASE WHEN s.FicouInternado ILIKE 'Sim' THEN 1 ELSE 0 END AS flag_internado,
    CASE WHEN s.Evolucao ILIKE 'Cura' THEN 1 ELSE 0 END AS flag_cura,
    stg_to_int(s.IdadeNaDataNotificacao),
    
    -- Dias entre notificação e encerramento
    CASE 
        WHEN s.DataNotificacao IS NOT NULL AND s.DataEncerramento IS NOT NULL THEN
            (s.DataEncerramento::DATE - s.DataNotificacao::DATE)
        ELSE NULL
    END AS dias_notif_encerramento,
    
    -- Dias entre notificação e óbito
    CASE 
        WHEN s.DataNotificacao IS NOT NULL AND s.DataObito IS NOT NULL THEN
            (s.DataObito::DATE - s.DataNotificacao::DATE)
        ELSE NULL
    END AS dias_notif_obito

FROM stg.notificacao_raw s

-- JOIN com dim_localidade
LEFT JOIN dw.dim_localidade l ON 
    l.municipio = COALESCE(NULLIF(TRIM(s.Municipio), ''), 'Desconhecido') AND
    l.bairro = COALESCE(NULLIF(TRIM(s.Bairro), ''), 'Desconhecido')

-- JOIN com dim_perfil_paciente
LEFT JOIN dw.dim_perfil_paciente p ON 
    p.sexo = COALESCE(NULLIF(TRIM(s.Sexo), ''), 'Desconhecido') AND
    p.faixa_etaria = COALESCE(NULLIF(TRIM(s.FaixaEtaria), ''), 'Desconhecido') AND
    p.raca_cor = COALESCE(NULLIF(TRIM(s.RacaCor), ''), 'Desconhecido') AND
    p.escolaridade = COALESCE(NULLIF(TRIM(s.Escolaridade), ''), 'Desconhecido') AND
    p.gestante = COALESCE(NULLIF(TRIM(s.Gestante), ''), 'Desconhecido') AND
    p.profissional_saude = COALESCE(NULLIF(TRIM(s.ProfissionalSaude), ''), 'Desconhecido') AND
    p.morador_rua = COALESCE(NULLIF(TRIM(s.MoradorDeRua), ''), 'Desconhecido') AND
    p.possui_deficiencia = COALESCE(NULLIF(TRIM(s.PossuiDeficiencia), ''), 'Desconhecido')

-- JOIN com dim_classificacao
LEFT JOIN dw.dim_classificacao c ON
    c.classificacao = COALESCE(NULLIF(TRIM(s.Classificacao), ''), 'Desconhecido') AND
    c.evolucao = COALESCE(NULLIF(TRIM(s.Evolucao), ''), 'Desconhecido') AND
    c.criterio_confirmacao = COALESCE(NULLIF(TRIM(s.CriterioConfirmacao), ''), 'Desconhecido') AND
    c.status_notificacao = COALESCE(NULLIF(TRIM(s.StatusNotificacao), ''), 'Desconhecido')

-- JOIN com dim_sintomas
LEFT JOIN dw.dim_sintomas sint ON
    sint.febre = COALESCE(NULLIF(TRIM(s.Febre), ''), 'Desconhecido') AND
    sint.dif_respiratoria = COALESCE(NULLIF(TRIM(s.DificuldadeRespiratoria), ''), 'Desconhecido') AND
    sint.tosse = COALESCE(NULLIF(TRIM(s.Tosse), ''), 'Desconhecido') AND
    sint.coriza = COALESCE(NULLIF(TRIM(s.Coriza), ''), 'Desconhecido') AND
    sint.dor_garganta = COALESCE(NULLIF(TRIM(s.DorGarganta), ''), 'Desconhecido') AND
    sint.diarreia = COALESCE(NULLIF(TRIM(s.Diarreia), ''), 'Desconhecido') AND
    sint.cefaleia = COALESCE(NULLIF(TRIM(s.Cefaleia), ''), 'Desconhecido')

-- JOIN com dim_comorbidade
LEFT JOIN dw.dim_comorbidade como ON
    como.com_pulmao = COALESCE(NULLIF(TRIM(s.ComorbidadePulmao), ''), 'Desconhecido') AND
    como.com_cardio = COALESCE(NULLIF(TRIM(s.ComorbidadeCardio), ''), 'Desconhecido') AND
    como.com_renal = COALESCE(NULLIF(TRIM(s.ComorbidadeRenal), ''), 'Desconhecido') AND
    como.com_diabetes = COALESCE(NULLIF(TRIM(s.ComorbidadeDiabetes), ''), 'Desconhecido') AND
    como.com_tabagismo = COALESCE(NULLIF(TRIM(s.ComorbidadeTabagismo), ''), 'Desconhecido') AND
    como.com_obesidade = COALESCE(NULLIF(TRIM(s.ComorbidadeObesidade), ''), 'Desconhecido')

-- JOIN com dim_teste
LEFT JOIN dw.dim_teste t ON
    t.tipo_teste_rapido = COALESCE(NULLIF(TRIM(s.TipoTesteRapido), ''), 'Desconhecido') AND
    t.resultado_rt_pcr = COALESCE(NULLIF(TRIM(s.ResultadoRT_PCR), ''), 'Desconhecido') AND
    t.resultado_teste_rap = COALESCE(NULLIF(TRIM(s.ResultadoTesteRapido), ''), 'Desconhecido') AND
    t.resultado_sorologia = COALESCE(NULLIF(TRIM(s.ResultadoSorologia), ''), 'Desconhecido') AND
    t.resultado_sorol_igg = COALESCE(NULLIF(TRIM(s.ResultadoSorologia_IGG), ''), 'Desconhecido');
