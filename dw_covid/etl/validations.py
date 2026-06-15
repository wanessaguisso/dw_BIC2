import os
import utils
import pandas as pd
from connection import get_engine

logger = utils.setup_logger('validations')

def run_validations():
    """Executa as consultas de validação do arquivo 07_validation.sql e loga os resultados."""
    logger.info("Iniciando validação de dados...")
    
    sql_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'sql', '07_validation.sql')
    
    try:
        with open(sql_path, 'r', encoding='utf-8') as file:
            sql_script = file.read()
            
        # Divide as queries pelo delimitador ';'
        queries = [q.strip() for q in sql_script.split(';') if q.strip() and not q.strip().startswith('--')]
        
        engine = get_engine()
        
        for i, query in enumerate(queries, 1):
            logger.info(f"Executando Validação {i}...")
            df = pd.read_sql(query, engine)
            logger.info(f"Resultado:\n{df.to_string(index=False)}")
            
        logger.info("Validações concluídas.")
        
    except Exception as e:
        logger.error(f"Erro durante as validações: {e}")
        raise e

if __name__ == "__main__":
    run_validations()
