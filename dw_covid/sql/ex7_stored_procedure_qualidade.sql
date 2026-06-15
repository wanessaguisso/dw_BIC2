-- sql/ex7_stored_procedure_qualidade.sql
-- Stored Procedure para Validação da Qualidade dos Dados antes/após a carga do DW

CREATE OR REPLACE PROCEDURE dw.sp_valida_qualidade_dados()
LANGUAGE plpgsql
AS $$
DECLARE
    v_missing_desconhecido INT;
    v_orfaos_tempo_notif INT;
    v_orfaos_local INT;
    v_orfaos_perfil INT;
    v_orfaos_class INT;
    v_orfaos_sint INT;
    v_orfaos_como INT;
    v_orfaos_teste INT;
    v_count_staging BIGINT;
    v_sum_fato BIGINT;
BEGIN
    RAISE NOTICE 'Iniciando validação de qualidade de dados...';

    -- (a) Validar se existe a linha "Desconhecido" (SK = -1) em todas as dimensões
    
    -- Verificando dim_tempo
    SELECT COUNT(*) INTO v_missing_desconhecido FROM dw.dim_tempo WHERE sk_tempo = -1;
    IF v_missing_desconhecido = 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Membro Desconhecido (-1) ausente na dim_tempo.';
    END IF;

    -- Verificando dim_localidade
    SELECT COUNT(*) INTO v_missing_desconhecido FROM dw.dim_localidade WHERE sk_local = -1;
    IF v_missing_desconhecido = 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Membro Desconhecido (-1) ausente na dim_localidade.';
    END IF;

    -- Verificando dim_perfil_paciente
    SELECT COUNT(*) INTO v_missing_desconhecido FROM dw.dim_perfil_paciente WHERE sk_perfil = -1;
    IF v_missing_desconhecido = 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Membro Desconhecido (-1) ausente na dim_perfil_paciente.';
    END IF;

    -- Verificando dim_classificacao
    SELECT COUNT(*) INTO v_missing_desconhecido FROM dw.dim_classificacao WHERE sk_class = -1;
    IF v_missing_desconhecido = 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Membro Desconhecido (-1) ausente na dim_classificacao.';
    END IF;

    -- Verificando dim_sintomas
    SELECT COUNT(*) INTO v_missing_desconhecido FROM dw.dim_sintomas WHERE sk_sint = -1;
    IF v_missing_desconhecido = 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Membro Desconhecido (-1) ausente na dim_sintomas.';
    END IF;

    -- Verificando dim_comorbidade
    SELECT COUNT(*) INTO v_missing_desconhecido FROM dw.dim_comorbidade WHERE sk_como = -1;
    IF v_missing_desconhecido = 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Membro Desconhecido (-1) ausente na dim_comorbidade.';
    END IF;

    -- Verificando dim_teste
    SELECT COUNT(*) INTO v_missing_desconhecido FROM dw.dim_teste WHERE sk_teste = -1;
    IF v_missing_desconhecido = 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Membro Desconhecido (-1) ausente na dim_teste.';
    END IF;

    RAISE NOTICE 'Validação (a) [Membros Desconhecidos]: SUCESSO. Todas as dimensões contêm o membro Desconhecido (-1).';


    -- (b) Validar se nenhuma SK da fato aponta para dimensão inexistente (teste de registros órfãos)
    
    -- Tempo (Notificação)
    SELECT COUNT(*) INTO v_orfaos_tempo_notif
    FROM dw.fato_notificacao_covid f
    LEFT JOIN dw.dim_tempo t ON f.sk_data_notificacao = t.sk_tempo
    WHERE t.sk_tempo IS NULL;
    IF v_orfaos_tempo_notif > 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Existem % registros órfãos para dim_tempo.', v_orfaos_tempo_notif;
    END IF;

    -- Localidade
    SELECT COUNT(*) INTO v_orfaos_local
    FROM dw.fato_notificacao_covid f
    LEFT JOIN dw.dim_localidade l ON f.sk_local = l.sk_local
    WHERE l.sk_local IS NULL;
    IF v_orfaos_local > 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Existem % registros órfãos para dim_localidade.', v_orfaos_local;
    END IF;

    -- Perfil Paciente
    SELECT COUNT(*) INTO v_orfaos_perfil
    FROM dw.fato_notificacao_covid f
    LEFT JOIN dw.dim_perfil_paciente p ON f.sk_perfil = p.sk_perfil
    WHERE p.sk_perfil IS NULL;
    IF v_orfaos_perfil > 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Existem % registros órfãos para dim_perfil_paciente.', v_orfaos_perfil;
    END IF;

    -- Classificação
    SELECT COUNT(*) INTO v_orfaos_class
    FROM dw.fato_notificacao_covid f
    LEFT JOIN dw.dim_classificacao c ON f.sk_class = c.sk_class
    WHERE c.sk_class IS NULL;
    IF v_orfaos_class > 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Existem % registros órfãos para dim_classificacao.', v_orfaos_class;
    END IF;

    -- Sintomas
    SELECT COUNT(*) INTO v_orfaos_sint
    FROM dw.fato_notificacao_covid f
    LEFT JOIN dw.dim_sintomas s ON f.sk_sint = s.sk_sint
    WHERE s.sk_sint IS NULL;
    IF v_orfaos_sint > 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Existem % registros órfãos para dim_sintomas.', v_orfaos_sint;
    END IF;

    -- Comorbidade
    SELECT COUNT(*) INTO v_orfaos_como
    FROM dw.fato_notificacao_covid f
    LEFT JOIN dw.dim_comorbidade c ON f.sk_como = c.sk_como
    WHERE c.sk_como IS NULL;
    IF v_orfaos_como > 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Existem % registros órfãos para dim_comorbidade.', v_orfaos_como;
    END IF;

    -- Teste
    SELECT COUNT(*) INTO v_orfaos_teste
    FROM dw.fato_notificacao_covid f
    LEFT JOIN dw.dim_teste t ON f.sk_teste = t.sk_teste
    WHERE t.sk_teste IS NULL;
    IF v_orfaos_teste > 0 THEN
        RAISE EXCEPTION 'Erro de Qualidade: Existem % registros órfãos para dim_teste.', v_orfaos_teste;
    END IF;

    RAISE NOTICE 'Validação (b) [Órfãos]: SUCESSO. Nenhuma FK da fato aponta para dimensões inexistentes.';


    -- (c) Validar se a soma de qtd_notificacao na fato bate com COUNT(*) da staging
    SELECT COUNT(*) INTO v_count_staging FROM stg.notificacao_raw;
    SELECT SUM(qtd_notificacao) INTO v_sum_fato FROM dw.fato_notificacao_covid;
    
    IF v_count_staging <> v_sum_fato THEN
        RAISE EXCEPTION 'Erro de Qualidade: Divergência de contagem. Staging = % linhas, Fato = % notificações.', v_count_staging, v_sum_fato;
    END IF;

    RAISE NOTICE 'Validação (c) [Consistência Volumétrica]: SUCESSO. Soma das notificações na fato (%) bate com o count da staging (%).', v_sum_fato, v_count_staging;

    RAISE NOTICE 'Auditoria concluída com SUCESSO. O Data Warehouse está íntegro!';
END;
$$;
