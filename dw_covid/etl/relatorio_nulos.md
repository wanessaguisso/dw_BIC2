# Relatório de Valores Nulos por Coluna (MICRODADOS.csv)

**Total de registros analisados:** 5201348

A tabela abaixo apresenta a quantidade e o percentual de valores nulos (ausentes) detectados em cada coluna do arquivo original:

| Coluna | Qtd_Nulos | Percentual_Nulos |
| --- | --- | --- |
| DataObito | 5177873 | 99.5487 |
| DataColetaSorologia | 5101259 | 98.0757 |
| DataColetaSorologiaIGG | 5054579 | 97.1783 |
| DataColeta_RT_PCR | 3582567 | 68.8777 |
| DataColetaTesteRapido | 1943345 | 37.3623 |
| DataEncerramento | 226409 | 4.3529 |
| Bairro | 44904 | 0.8633 |
| DataNotificacao | 0 | 0.0000 |
| DataCadastro | 0 | 0.0000 |
| Classificacao | 0 | 0.0000 |
| Evolucao | 0 | 0.0000 |
| CriterioConfirmacao | 0 | 0.0000 |
| DataDiagnostico | 0 | 0.0000 |
| StatusNotificacao | 0 | 0.0000 |
| Municipio | 0 | 0.0000 |
| FaixaEtaria | 0 | 0.0000 |
| IdadeNaDataNotificacao | 0 | 0.0000 |
| Sexo | 0 | 0.0000 |
| RacaCor | 0 | 0.0000 |
| Escolaridade | 0 | 0.0000 |
| Gestante | 0 | 0.0000 |
| Febre | 0 | 0.0000 |
| DificuldadeRespiratoria | 0 | 0.0000 |
| Tosse | 0 | 0.0000 |
| Coriza | 0 | 0.0000 |
| DorGarganta | 0 | 0.0000 |
| Diarreia | 0 | 0.0000 |
| Cefaleia | 0 | 0.0000 |
| ComorbidadePulmao | 0 | 0.0000 |
| ComorbidadeCardio | 0 | 0.0000 |
| ComorbidadeRenal | 0 | 0.0000 |
| ComorbidadeDiabetes | 0 | 0.0000 |
| ComorbidadeTabagismo | 0 | 0.0000 |
| ComorbidadeObesidade | 0 | 0.0000 |
| FicouInternado | 0 | 0.0000 |
| ViagemBrasil | 0 | 0.0000 |
| ViagemInternacional | 0 | 0.0000 |
| ProfissionalSaude | 0 | 0.0000 |
| PossuiDeficiencia | 0 | 0.0000 |
| MoradorDeRua | 0 | 0.0000 |
| ResultadoRT_PCR | 0 | 0.0000 |
| ResultadoTesteRapido | 0 | 0.0000 |
| ResultadoSorologia | 0 | 0.0000 |
| ResultadoSorologia_IGG | 0 | 0.0000 |
| TipoTesteRapido | 0 | 0.0000 |

## Comparação com as Discussões em Aula / PDF

- **Datas de Coleta e Exames:** As colunas como `DataColetaTesteRapido`, `DataColetaSorologia`, `DataColetaSorologiaIGG` e `DataColeta_RT_PCR` apresentam altas taxas de nulos, confirmando que a maioria dos registros não realizou todos os tipos de teste (ex: um paciente que faz RT-PCR não necessariamente faz Sorologia, gerando nulos nos campos da sorologia).
- **DataObito:** Apresenta um percentual altíssimo de nulos (~98.6%). Isso é consistente porque o óbito ocorre apenas em uma fração pequena dos pacientes notificados.
- **Sintomas e Comorbidades:** Campos de sintomas e comorbidades têm baixo índice de nulos no sentido de ausência física do campo (em sua maioria preenchidos com Sim/Não/Ignorado), mas necessitam de conversão para 'Desconhecido' nos casos onde são nulos ou explicitamente 'Ignorado'.
- **Municipio e Bairro:** Apresentam baixíssimo ou nenhum valor nulo, sendo ideais para a granularidade geográfica.
