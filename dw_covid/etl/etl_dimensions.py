import time
import utils
from connection import get_connection

logger = utils.setup_logger('etl_dimensions')

def run_query(cursor, query, desc):
    """Executa uma query e loga a descrição"""
    logger.info(f"Processando: {desc}...")
    cursor.execute(query)

def load_dimensions():
    """Popula as dimensões a partir dos valores únicos da staging e garante o membro Desconhecido (-1)."""
    start_time = time.time()
    
    # Dicionário de queries para extrair dimensões únicas e popular.
    # O uso de COALESCE(NULLIF(TRIM(campo), ''), 'Desconhecido') segue as regras.
    dimension_queries = {
        "membro_desconhecido": """
            -- Garante o membro -1 em todas as dimensões autoincrementais
            INSERT INTO dw.dim_localidade (sk_local, municipio, bairro, uf, regiao_es, macrorregiao) 
                VALUES (-1, 'Desconhecido', 'Desconhecido', 'Desc', 'Desconhecido', 'Desconhecido') ON CONFLICT (sk_local) DO NOTHING;
            INSERT INTO dw.dim_perfil_paciente (sk_perfil, sexo, faixa_etaria, raca_cor, escolaridade, gestante, profissional_saude, morador_rua, possui_deficiencia)
                VALUES (-1, 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido') ON CONFLICT (sk_perfil) DO NOTHING;
            INSERT INTO dw.dim_classificacao (sk_class, classificacao, evolucao, criterio_confirmacao, status_notificacao)
                VALUES (-1, 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido') ON CONFLICT (sk_class) DO NOTHING;
            INSERT INTO dw.dim_sintomas (sk_sint, febre, dif_respiratoria, tosse, coriza, dor_garganta, diarreia, cefaleia)
                VALUES (-1, 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido') ON CONFLICT (sk_sint) DO NOTHING;
            INSERT INTO dw.dim_comorbidade (sk_como, com_pulmao, com_cardio, com_renal, com_diabetes, com_tabagismo, com_obesidade)
                VALUES (-1, 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido') ON CONFLICT (sk_como) DO NOTHING;
            INSERT INTO dw.dim_teste (sk_teste, tipo_teste_rapido, resultado_rt_pcr, resultado_teste_rap, resultado_sorologia, resultado_sorol_igg)
                VALUES (-1, 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido', 'Desconhecido') ON CONFLICT (sk_teste) DO NOTHING;
        """,
        "dim_localidade": """
            INSERT INTO dw.dim_localidade (municipio, bairro, uf, regiao_es, macrorregiao)
            SELECT DISTINCT 
                COALESCE(NULLIF(TRIM(Municipio), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(Bairro), ''), 'Desconhecido'),
                'ES' AS uf, -- assumindo ES, pode ser estendido
                'Desconhecido' AS regiao_es,
                'Desconhecido' AS macrorregiao
            FROM stg.notificacao_raw
            EXCEPT SELECT municipio, bairro, uf, regiao_es, macrorregiao FROM dw.dim_localidade;
        """,
        "dim_perfil_paciente": """
            INSERT INTO dw.dim_perfil_paciente (sexo, faixa_etaria, raca_cor, escolaridade, gestante, profissional_saude, morador_rua, possui_deficiencia)
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(Sexo), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(FaixaEtaria), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(RacaCor), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(Escolaridade), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(Gestante), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(ProfissionalSaude), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(MoradorDeRua), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(PossuiDeficiencia), ''), 'Desconhecido')
            FROM stg.notificacao_raw
            EXCEPT SELECT sexo, faixa_etaria, raca_cor, escolaridade, gestante, profissional_saude, morador_rua, possui_deficiencia FROM dw.dim_perfil_paciente;
        """,
        "dim_classificacao": """
            INSERT INTO dw.dim_classificacao (classificacao, evolucao, criterio_confirmacao, status_notificacao)
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(Classificacao), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(Evolucao), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(CriterioConfirmacao), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(StatusNotificacao), ''), 'Desconhecido')
            FROM stg.notificacao_raw
            EXCEPT SELECT classificacao, evolucao, criterio_confirmacao, status_notificacao FROM dw.dim_classificacao;
        """,
        "dim_sintomas": """
            INSERT INTO dw.dim_sintomas (febre, dif_respiratoria, tosse, coriza, dor_garganta, diarreia, cefaleia)
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(Febre), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(DificuldadeRespiratoria), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(Tosse), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(Coriza), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(DorGarganta), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(Diarreia), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(Cefaleia), ''), 'Desconhecido')
            FROM stg.notificacao_raw
            EXCEPT SELECT febre, dif_respiratoria, tosse, coriza, dor_garganta, diarreia, cefaleia FROM dw.dim_sintomas;
        """,
        "dim_comorbidade": """
            INSERT INTO dw.dim_comorbidade (com_pulmao, com_cardio, com_renal, com_diabetes, com_tabagismo, com_obesidade)
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(ComorbidadePulmao), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(ComorbidadeCardio), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(ComorbidadeRenal), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(ComorbidadeDiabetes), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(ComorbidadeTabagismo), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(ComorbidadeObesidade), ''), 'Desconhecido')
            FROM stg.notificacao_raw
            EXCEPT SELECT com_pulmao, com_cardio, com_renal, com_diabetes, com_tabagismo, com_obesidade FROM dw.dim_comorbidade;
        """,
        "dim_teste": """
            INSERT INTO dw.dim_teste (tipo_teste_rapido, resultado_rt_pcr, resultado_teste_rap, resultado_sorologia, resultado_sorol_igg)
            SELECT DISTINCT
                COALESCE(NULLIF(TRIM(TipoTesteRapido), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(ResultadoRT_PCR), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(ResultadoTesteRapido), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(ResultadoSorologia), ''), 'Desconhecido'),
                COALESCE(NULLIF(TRIM(ResultadoSorologia_IGG), ''), 'Desconhecido')
            FROM stg.notificacao_raw
            EXCEPT SELECT tipo_teste_rapido, resultado_rt_pcr, resultado_teste_rap, resultado_sorologia, resultado_sorol_igg FROM dw.dim_teste;
        """
    }
    
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        for name, query in dimension_queries.items():
            run_query(cursor, query, name)
            
        conn.commit()
        logger.info("Carga de dimensões concluída com sucesso.")
        
    except Exception as e:
        logger.error(f"Erro durante a carga das dimensões: {e}")
        if 'conn' in locals() and conn:
            conn.rollback()
        raise e
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()
            
    elapsed = time.time() - start_time
    logger.info(f"Tempo total ETL Dimensões: {elapsed:.2f} segundos.")

if __name__ == "__main__":
    load_dimensions()
