import os
import connection

def run_sql_file(cursor, file_path):
    print(f"Executando {os.path.basename(file_path)}...")
    with open(file_path, 'r', encoding='utf-8') as f:
        sql = f.read()
    # Executa o conteúdo do arquivo SQL
    cursor.execute(sql)

def main():
    # Encontra o diretório base do projeto
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    sql_dir = os.path.join(base_dir, 'sql')

    # Lista de arquivos SQL para rodar em ordem
    sql_files = [
        '01_create_database.sql',
        '02_create_staging.sql',
        '03_create_dimensions.sql',
        '04_create_fact.sql',
        '05_populate_dim_tempo.sql'
    ]

    try:
        conn = connection.get_connection()
        conn.autocommit = False
        cursor = conn.cursor()
        
        for sql_file in sql_files:
            file_path = os.path.join(sql_dir, sql_file)
            run_sql_file(cursor, file_path)
            
        conn.commit()
        print("\n[OK] Todas as estruturas criadas com sucesso no banco Aiven!")
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"\n[ERRO] Falha ao criar as estruturas no banco de dados: {e}")
        if 'conn' in locals():
            conn.rollback()

if __name__ == '__main__':
    main()
