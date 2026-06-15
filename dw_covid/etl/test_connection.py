import sys
import psycopg2

def test_db():
    try:
        print("Tentando conectar ao PostgreSQL local (sem senha)...")
        conn = psycopg2.connect(
            host="localhost",
            port=5432,
            user="postgres",
            database="postgres"
        )
        print("Conectado ao banco 'postgres' com sucesso!")
        conn.close()
        
        print("Tentando conectar ao dw_covid (sem senha)...")
        conn = psycopg2.connect(
            host="localhost",
            port=5432,
            user="postgres",
            database="dw_covid"
        )
        print("Conectado ao banco 'dw_covid' com sucesso!")
        conn.close()
    except Exception as e:
        print(f"Falha na conexão: {e}")

if __name__ == "__main__":
    test_db()
