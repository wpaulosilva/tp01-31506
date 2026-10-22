IF DB_ID('alojamento') IS NULL
    CREATE DATABASE alojamento;
GO
USE alojamento;
GO
IF OBJECT_ID('extrato') IS NOT NULL
    DROP TABLE extrato;
GO
CREATE TABLE extrato (
    proprietario_id VARCHAR(10)   NOT NULL,
    nome            VARCHAR(100)  NOT NULL,
    ano             INT           NOT NULL,
    mes             INT           NOT NULL,
    n_pagamentos    INT           NOT NULL,
    receita_eur     DECIMAL(10,2) NOT NULL,
    comissao_pct    DECIMAL(5,2)  NOT NULL,
    comissao_eur    DECIMAL(10,2) NOT NULL,
    n_despesas      INT           NOT NULL,
    despesas_eur    DECIMAL(10,2) NOT NULL,
    liquido_eur     DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (proprietario_id, ano, mes)
);
GO
