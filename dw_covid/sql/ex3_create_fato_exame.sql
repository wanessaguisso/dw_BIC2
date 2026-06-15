-- sql/ex3_create_fato_exame.sql
-- Criação da segunda tabela fato fato_exame compartilhando dimensões conformadas

DROP TABLE IF EXISTS dw.fato_exame CASCADE;

CREATE TABLE dw.fato_exame (
    sk_fato_exame BIGSERIAL PRIMARY KEY,
    
    -- Dimensões Conformadas (Compartilhadas)
    sk_data_notificacao INT NOT NULL REFERENCES dw.dim_tempo(sk_tempo),
    sk_data_coleta INT NOT NULL REFERENCES dw.dim_tempo(sk_tempo),
    sk_local INT NOT NULL REFERENCES dw.dim_localidade(sk_local),
    sk_perfil INT NOT NULL REFERENCES dw.dim_perfil_paciente(sk_perfil),
    
    -- Atributos degenerados ou específicos do Exame
    tipo_exame VARCHAR(50) NOT NULL,       -- ex: 'RT-PCR', 'Teste Rápido', 'Sorologia', 'Sorologia IGG'
    resultado_exame VARCHAR(100) NOT NULL, -- ex: 'Positivo', 'Negativo', 'Inconclusivo', 'Desconhecido'
    
    -- Medidas
    qtd_exame INT NOT NULL DEFAULT 1
);

-- Índices recomendados para otimização de consultas
CREATE INDEX idx_fato_exame_data_notificacao ON dw.fato_exame(sk_data_notificacao);
CREATE INDEX idx_fato_exame_data_coleta ON dw.fato_exame(sk_data_coleta);
CREATE INDEX idx_fato_exame_local ON dw.fato_exame(sk_local);
CREATE INDEX idx_fato_exame_perfil ON dw.fato_exame(sk_perfil);
