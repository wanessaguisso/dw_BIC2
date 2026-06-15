import time
import os
import utils
from connection import get_connection

logger = utils.setup_logger('etl_fato_exame')

def run_script(cursor, sql_path, desc):
    logger.info(f"Executando script para {desc}...")
    if not os.path.exists(sql_path):
        logger.error(f"Arquivo não encontrado: {sql_path}")
        return False
        
    with open(sql_path, 'r', encoding='utf-8') as f:
        sql_content = f.read()
        
    cursor.execute(sql_content)
    logger.info(f"Sucesso ao executar {desc}.")
    return True

def load_fato_exame():
    start_time = time.time()
    logger.info("Iniciando ETL da Tabela Fato Exame (fato_exame)...")
    
    base_dir = os.path.dirname(os.path.dirname(__file__))
    ddl_path = os.path.join(base_dir, 'sql', 'ex3_create_fato_exame.sql')
    load_path = os.path.join(base_dir, 'sql', 'ex3_load_fato_exame.sql')
    
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # 1. Cria a estrutura da tabela fato_exame
        run_script(cursor, ddl_path, "criação da fato_exame")
        
        # 2. Carrega os dados na fato_exame (pode levar alguns minutos)
        logger.info("Iniciando inserção dos dados na fato_exame. Isso fará um processamento massivo via banco...")
        run_script(cursor, load_path, "carga da fato_exame")
        
        conn.commit()
        
        # Conta registros inseridos
        cursor.execute("SELECT COUNT(*) FROM dw.fato_exame;")
        count = cursor.fetchone()[0]
        logger.info(f"Carga finalizada com sucesso! {count} exames inseridos na dw.fato_exame.")
        
    except Exception as e:
        logger.error(f"Erro durante o ETL da fato_exame: {e}")
        if 'conn' in locals() and conn:
            conn.rollback()
        raise e
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()
            
    elapsed = time.time() - start_time
    logger.info(f"Tempo total ETL Fato Exame: {elapsed:.2f} segundos.")

if __name__ == "__main__":
    load_fato_exame()
