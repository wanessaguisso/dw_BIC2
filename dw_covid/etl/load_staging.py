import time
import utils
import config
from connection import get_connection

logger = utils.setup_logger('load_staging')

def load_staging_data():
    """Carrega dados do CSV para a tabela de staging stg.notificacao_raw usando COPY."""
    logger.info("Iniciando carga da Staging Area...")
    
    csv_path = config.CSV_PATH
    # Como o arquivo pode não estar dentro do dw_covid, vamos usar o caminho que sabemos que ele existe
    # Se CSV_PATH falhar (por não encontrar), vamos tentar buscar no nível acima
    import os
    if not os.path.exists(csv_path):
        csv_path = r'c:\Users\guiss\Documents\prj3\BI\MICRODADOS.csv'
        logger.info(f"Caminho padrão não encontrado, utilizando fallback: {csv_path}")

    start_time = time.time()
    
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Limpar staging antes da carga
        logger.info("Truncando tabela stg.notificacao_raw...")
        cursor.execute("TRUNCATE TABLE stg.notificacao_raw;")
        
        # O comando COPY é a forma mais rápida de popular dados brutos no PostgreSQL
        # Usamos o header para mapear as colunas e DELIMITER ';' pois o CSV é brasileiro
        logger.info(f"Executando comando COPY a partir de {csv_path}...")
        with open(csv_path, 'r', encoding='LATIN1') as f:
            # next(f) # pula header se quisermos usar COPY from com header false, mas COPY header faz isso
            cursor.copy_expert(
                "COPY stg.notificacao_raw FROM STDIN WITH CSV HEADER DELIMITER ';' ENCODING 'LATIN1'", 
                f
            )
            
        conn.commit()
        
        # Conta as linhas carregadas
        cursor.execute("SELECT count(*) FROM stg.notificacao_raw;")
        count = cursor.fetchone()[0]
        logger.info(f"Carga concluída! {count} registros carregados na staging.")
        
    except Exception as e:
        logger.error(f"Erro durante a carga da staging: {e}")
        if 'conn' in locals() and conn:
            conn.rollback()
        raise e
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()
            
    elapsed = time.time() - start_time
    logger.info(f"Tempo total carga Staging: {elapsed:.2f} segundos.")

if __name__ == "__main__":
    load_staging_data()
