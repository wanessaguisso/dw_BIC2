import time
import os
import utils
from connection import get_connection

logger = utils.setup_logger('etl_fact')

def load_fact():
    """Executa o script SQL 06_load_fact.sql para popular a tabela Fato."""
    logger.info("Iniciando carga da Tabela Fato...")
    start_time = time.time()
    
    # Caminho do script SQL
    sql_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'sql', '06_load_fact.sql')
    
    try:
        with open(sql_path, 'r', encoding='utf-8') as file:
            sql_script = file.read()
            
        conn = get_connection()
        cursor = conn.cursor()
        
        logger.info("Executando script de carga da fato (isso pode levar vários minutos)...")
        cursor.execute(sql_script)
        
        conn.commit()
        
        # Conta linhas
        cursor.execute("SELECT count(*) FROM dw.fato_notificacao_covid;")
        count = cursor.fetchone()[0]
        logger.info(f"Carga concluída! {count} registros inseridos na Fato.")
        
    except Exception as e:
        logger.error(f"Erro durante a carga da fato: {e}")
        if 'conn' in locals() and conn:
            conn.rollback()
        raise e
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()
            
    elapsed = time.time() - start_time
    logger.info(f"Tempo total ETL Fato: {elapsed:.2f} segundos.")

if __name__ == "__main__":
    load_fact()
