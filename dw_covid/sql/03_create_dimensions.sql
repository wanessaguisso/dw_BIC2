-- 03_create_dimensions.sql

DROP TABLE IF EXISTS dw.dim_tempo CASCADE;
CREATE TABLE dw.dim_tempo (
    sk_tempo INT PRIMARY KEY,
    data DATE,
    dia INT,
    mes INT,
    ano INT,
    trimestre INT,
    nome_mes VARCHAR(20),
    dia_semana VARCHAR(20),
    ano_mes VARCHAR(10),
    eh_fim_de_semana BOOLEAN,
    semana_epidemiologica INT
);

DROP TABLE IF EXISTS dw.dim_localidade CASCADE;
CREATE TABLE dw.dim_localidade (
    sk_local SERIAL PRIMARY KEY,
    municipio VARCHAR(255),
    bairro VARCHAR(255),
    uf VARCHAR(50),
    regiao_es VARCHAR(100),
    macrorregiao VARCHAR(100)
);

DROP TABLE IF EXISTS dw.dim_perfil_paciente CASCADE;
CREATE TABLE dw.dim_perfil_paciente (
    sk_perfil SERIAL PRIMARY KEY,
    sexo VARCHAR(50),
    faixa_etaria VARCHAR(100),
    raca_cor VARCHAR(100),
    escolaridade VARCHAR(100),
    gestante VARCHAR(50),
    profissional_saude VARCHAR(50),
    morador_rua VARCHAR(50),
    possui_deficiencia VARCHAR(50)
);

DROP TABLE IF EXISTS dw.dim_classificacao CASCADE;
CREATE TABLE dw.dim_classificacao (
    sk_class SERIAL PRIMARY KEY,
    classificacao VARCHAR(255),
    evolucao VARCHAR(255),
    criterio_confirmacao VARCHAR(255),
    status_notificacao VARCHAR(255)
);

DROP TABLE IF EXISTS dw.dim_sintomas CASCADE;
CREATE TABLE dw.dim_sintomas (
    sk_sint SERIAL PRIMARY KEY,
    febre VARCHAR(50),
    dif_respiratoria VARCHAR(50),
    tosse VARCHAR(50),
    coriza VARCHAR(50),
    dor_garganta VARCHAR(50),
    diarreia VARCHAR(50),
    cefaleia VARCHAR(50)
);

DROP TABLE IF EXISTS dw.dim_comorbidade CASCADE;
CREATE TABLE dw.dim_comorbidade (
    sk_como SERIAL PRIMARY KEY,
    com_pulmao VARCHAR(50),
    com_cardio VARCHAR(50),
    com_renal VARCHAR(50),
    com_diabetes VARCHAR(50),
    com_tabagismo VARCHAR(50),
    com_obesidade VARCHAR(50)
);

DROP TABLE IF EXISTS dw.dim_teste CASCADE;
CREATE TABLE dw.dim_teste (
    sk_teste SERIAL PRIMARY KEY,
    tipo_teste_rapido VARCHAR(255),
    resultado_rt_pcr VARCHAR(100),
    resultado_teste_rap VARCHAR(100),
    resultado_sorologia VARCHAR(100),
    resultado_sorol_igg VARCHAR(100)
);
