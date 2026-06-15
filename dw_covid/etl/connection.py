import psycopg2
from sqlalchemy import create_engine
import config

def get_connection():
    """Retorna uma conexão psycopg2 para uso direto (ex: COPY, queries otimizadas)."""
    conn = psycopg2.connect(
        host=config.DB_HOST,
        port=config.DB_PORT,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
        database=config.DB_NAME,
        sslmode=config.DB_SSLMODE
    )
    return conn

def get_engine():
    """Retorna um engine do SQLAlchemy (útil com pandas)."""
    conn_str = f"postgresql://{config.DB_USER}:{config.DB_PASSWORD}@{config.DB_HOST}:{config.DB_PORT}/{config.DB_NAME}"
    if config.DB_SSLMODE and config.DB_SSLMODE not in ('prefer', 'disable'):
        conn_str += f"?sslmode={config.DB_SSLMODE}"
    return create_engine(conn_str)
