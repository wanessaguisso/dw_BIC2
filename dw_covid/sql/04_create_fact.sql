-- 04_create_fact.sql

DROP TABLE IF EXISTS dw.fato_notificacao_covid CASCADE;
CREATE TABLE dw.fato_notificacao_covid (
    sk_data_notificacao INT REFERENCES dw.dim_tempo(sk_tempo),
    sk_data_cadastro INT REFERENCES dw.dim_tempo(sk_tempo),
    sk_data_diagnostico INT REFERENCES dw.dim_tempo(sk_tempo),
    sk_data_coleta INT REFERENCES dw.dim_tempo(sk_tempo),
    sk_data_encerramento INT REFERENCES dw.dim_tempo(sk_tempo),
    sk_data_obito INT REFERENCES dw.dim_tempo(sk_tempo),
    sk_local INT REFERENCES dw.dim_localidade(sk_local),
    sk_perfil INT REFERENCES dw.dim_perfil_paciente(sk_perfil),
    sk_class INT REFERENCES dw.dim_classificacao(sk_class),
    sk_sint INT REFERENCES dw.dim_sintomas(sk_sint),
    sk_como INT REFERENCES dw.dim_comorbidade(sk_como),
    sk_teste INT REFERENCES dw.dim_teste(sk_teste),
    
    -- Medidas
    qtd_notificacao INT DEFAULT 1,
    flag_confirmado INT DEFAULT 0,
    flag_obito_covid INT DEFAULT 0,
    flag_internado INT DEFAULT 0,
    flag_cura INT DEFAULT 0,
    idade_anos INT,
    dias_notif_encerramento INT,
    dias_notif_obito INT
);

-- Índices para performance
CREATE INDEX idx_fato_sk_data_notificacao ON dw.fato_notificacao_covid(sk_data_notificacao);
CREATE INDEX idx_fato_sk_local ON dw.fato_notificacao_covid(sk_local);
CREATE INDEX idx_fato_sk_perfil ON dw.fato_notificacao_covid(sk_perfil);
CREATE INDEX idx_fato_sk_class ON dw.fato_notificacao_covid(sk_class);
CREATE INDEX idx_fato_sk_sint ON dw.fato_notificacao_covid(sk_sint);
CREATE INDEX idx_fato_sk_como ON dw.fato_notificacao_covid(sk_como);
CREATE INDEX idx_fato_sk_teste ON dw.fato_notificacao_covid(sk_teste);
