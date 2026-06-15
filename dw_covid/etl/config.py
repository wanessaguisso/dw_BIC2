import os
# pyrefly: ignore [missing-import]
from dotenv import load_dotenv

# Carrega variáveis de ambiente do arquivo .env
load_dotenv()

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')
DB_NAME = os.getenv('DB_NAME', 'dw_covid')
DB_SSLMODE = os.getenv('DB_SSLMODE', 'prefer')

DATA_DIR = os.getenv('DATA_DIR', '../data')
CSV_FILENAME = os.getenv('CSV_FILENAME', 'MICRODADOS.csv')
CSV_PATH = os.path.join(DATA_DIR, CSV_FILENAME)
LOGS_DIR = os.getenv('LOGS_DIR', '../logs')

# Criar pasta de logs se não existir
os.makedirs(LOGS_DIR, exist_ok=True)
