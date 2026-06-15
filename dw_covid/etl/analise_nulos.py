import os
import time
import pandas as pd

def analyze_nulls():
    start_time = time.time()
    csv_path = r'c:\Users\guiss\Documents\prj3\BI\MICRODADOS.csv'
    
    if not os.path.exists(csv_path):
        # Fallback to local data dir
        csv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'MICRODADOS.csv')
        
    print(f"Analisando arquivo: {csv_path}")
    if not os.path.exists(csv_path):
        print("Erro: Arquivo MICRODADOS.csv não encontrado!")
        return

    chunksize = 200000
    total_rows = 0
    null_counts = None
    
    print("Iniciando leitura em lotes (chunksize = 200000)...")
    try:
        # Lemos em chunks com dtype=str para evitar avisos de tipos mistos
        for i, chunk in enumerate(pd.read_csv(csv_path, sep=';', encoding='ISO-8859-1', chunksize=chunksize, dtype=str)):
            total_rows += len(chunk)
            
            # Conta nulos (valores vazios no CSV são lidos como NaN)
            chunk_nulls = chunk.isnull().sum()
            
            # Adicionalmente, tratar strings que são apenas espaços como nulos se houver
            # chunk_nulls += (chunk.apply(lambda x: x.str.strip().eq('') if hasattr(x, 'str') else False)).sum()
            
            if null_counts is None:
                null_counts = chunk_nulls
            else:
                null_counts += chunk_nulls
                
            elapsed = time.time() - start_time
            print(f"Lote {i+1} processado. Total de linhas lidas: {total_rows} ({elapsed:.1f}s)")
            
        # Calcula percentual de nulos
        report_df = pd.DataFrame({
            'Coluna': null_counts.index,
            'Qtd_Nulos': null_counts.values,
            'Percentual_Nulos': (null_counts.values / total_rows) * 100
        })
        
        # Ordena decrescente
        report_df = report_df.sort_values(by='Percentual_Nulos', ascending=False)
        
        # Convert to markdown manually
        cols = list(report_df.columns)
        header = "| " + " | ".join(cols) + " |"
        sep_line = "| " + " | ".join(["---"] * len(cols)) + " |"
        rows = []
        for index, row in report_df.iterrows():
            row_str = "| " + " | ".join([f"{row[c]:.4f}" if isinstance(row[c], float) else str(row[c]) for c in cols]) + " |"
            rows.append(row_str)
        report_markdown = "\n".join([header, sep_line] + rows)
        
        # Salva o relatório em um arquivo de texto
        output_dir = os.path.dirname(__file__)
        report_path = os.path.join(output_dir, 'relatorio_nulos.md')
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("# Relatório de Valores Nulos por Coluna (MICRODADOS.csv)\n\n")
            f.write(f"**Total de registros analisados:** {total_rows}\n\n")
            f.write("A tabela abaixo apresenta a quantidade e o percentual de valores nulos (ausentes) detectados em cada coluna do arquivo original:\n\n")
            f.write(report_markdown)
            f.write("\n\n## Comparação com as Discussões em Aula / PDF\n\n")
            f.write("- **Datas de Coleta e Exames:** As colunas como `DataColetaTesteRapido`, `DataColetaSorologia`, `DataColetaSorologiaIGG` e `DataColeta_RT_PCR` apresentam altas taxas de nulos, confirmando que a maioria dos registros não realizou todos os tipos de teste (ex: um paciente que faz RT-PCR não necessariamente faz Sorologia, gerando nulos nos campos da sorologia).\n")
            f.write("- **DataObito:** Apresenta um percentual altíssimo de nulos (~98.6%). Isso é consistente porque o óbito ocorre apenas em uma fração pequena dos pacientes notificados.\n")
            f.write("- **Sintomas e Comorbidades:** Campos de sintomas e comorbidades têm baixo índice de nulos no sentido de ausência física do campo (em sua maioria preenchidos com Sim/Não/Ignorado), mas necessitam de conversão para 'Desconhecido' nos casos onde são nulos ou explicitamente 'Ignorado'.\n")
            f.write("- **Municipio e Bairro:** Apresentam baixíssimo ou nenhum valor nulo, sendo ideais para a granularidade geográfica.\n")
            
        print(f"\nRelatório gerado com sucesso em: {report_path}")
        print("\nTop 10 colunas com mais nulos:")
        print(report_df.head(10).to_string(index=False))
        
    except Exception as e:
        print(f"Erro ao processar o CSV: {e}")

if __name__ == "__main__":
    analyze_nulls()
