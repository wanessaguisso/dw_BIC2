-- 01_create_database.sql
-- Conecte-se como postgres ou usuário com permissões de criação e execute:

-- IMPORTANTE: Não é possível rodar CREATE DATABASE de dentro de um bloco de transação, 
-- por isso você pode precisar rodar isso separadamente, ou remover o CREATE DATABASE se ele já existir.
-- CREATE DATABASE dw_covid;

-- \c dw_covid

CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS mart;
