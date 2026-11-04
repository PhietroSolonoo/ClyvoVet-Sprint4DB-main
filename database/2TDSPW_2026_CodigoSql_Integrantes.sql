-- =====================================================
-- PROJETO CLYVO VET - SPRINT 4
-- Mastering Relational and Non-Relational Database
-- Arquivo: 2TDSPW_2026_CodigoSql_Integrantes.sql
-- Integrantes (ordem alfabética):
-- Gustavo Barrios de Araújo - RM563358
-- Matheus Almeida Ribeiro   - RM562980
-- Phietro Solon Oliveira    - RM563842
-- =====================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;
SET PAGESIZE 200;

-- 1. LIMPEZA IDEMPOTENTE
BEGIN
    FOR r IN (
        SELECT 'DROP TRIGGER TRG_AUDITORIA_PET' cmd FROM dual
        UNION ALL SELECT 'DROP PACKAGE PKG_AUDITORIA' FROM dual
        UNION ALL SELECT 'DROP PACKAGE PKG_RELATORIOS' FROM dual
        UNION ALL SELECT 'DROP PACKAGE PKG_JSON' FROM dual
        UNION ALL SELECT 'DROP PACKAGE PKG_CADASTRO' FROM dual
        UNION ALL SELECT 'DROP PACKAGE PKG_LOG' FROM dual
        UNION ALL SELECT 'DROP PACKAGE PKG_VALIDACAO' FROM dual
        UNION ALL SELECT 'DROP TABLE TB_AUDITORIA CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP TABLE ALERTA CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP TABLE EXAME CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP TABLE MEDICAMENTO CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP TABLE VACINA CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP TABLE CONSULTA CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP TABLE VETERINARIO CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP TABLE PET CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP TABLE CLINICA CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP TABLE TUTOR CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP TABLE ERRO_LOG CASCADE CONSTRAINTS PURGE' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_TUTOR' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_PET' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_CLINICA' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_VETERINARIO' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_CONSULTA' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_VACINA' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_MEDICAMENTO' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_EXAME' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_ALERTA' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_LOG' FROM dual
        UNION ALL SELECT 'DROP SEQUENCE SEQ_ID_AUDITORIA' FROM dual
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE r.cmd;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END LOOP;
END;
/

-- 2. SEQUENCES
CREATE SEQUENCE SEQ_ID_TUTOR START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ID_PET START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ID_CLINICA START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ID_VETERINARIO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ID_CONSULTA START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ID_VACINA START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ID_MEDICAMENTO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ID_EXAME START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ID_ALERTA START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ID_LOG START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ID_AUDITORIA START WITH 1 INCREMENT BY 1;

-- 3. TABELAS
CREATE TABLE TUTOR (
    id_tutor NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    cpf VARCHAR2(14) UNIQUE NOT NULL,
    email VARCHAR2(100) UNIQUE,
    telefone VARCHAR2(20),
    data_nascimento DATE,
    endereco VARCHAR2(200)
);

CREATE TABLE PET (
    id_pet NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(50) NOT NULL,
    especie VARCHAR2(30) NOT NULL,
    raca VARCHAR2(30),
    data_nascimento DATE,
    peso NUMBER(5,2),
    sexo CHAR(1),
    castrado CHAR(1) DEFAULT 'N',
    id_tutor NUMBER(10) NOT NULL,
    CONSTRAINT CK_PET_CASTRADO CHECK (castrado IN ('S', 'N')),
    CONSTRAINT FK_PET_TUTOR FOREIGN KEY (id_tutor) REFERENCES TUTOR(id_tutor)
);

CREATE TABLE CLINICA (
    id_clinica NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    cnpj VARCHAR2(18) UNIQUE NOT NULL,
    email VARCHAR2(100) UNIQUE,
    telefone VARCHAR2(20),
    endereco VARCHAR2(200)
);

CREATE TABLE VETERINARIO (
    id_veterinario NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    crmv VARCHAR2(20) UNIQUE NOT NULL,
    especialidade VARCHAR2(50),
    email VARCHAR2(100) UNIQUE,
    telefone VARCHAR2(20),
    id_clinica NUMBER(10) NOT NULL,
    CONSTRAINT FK_VETERINARIO_CLINICA FOREIGN KEY (id_clinica) REFERENCES CLINICA(id_clinica)
);

CREATE TABLE CONSULTA (
    id_consulta NUMBER(10) PRIMARY KEY,
    data_hora TIMESTAMP NOT NULL,
    tipo VARCHAR2(30) NOT NULL,
    status VARCHAR2(20) NOT NULL,
    observacoes VARCHAR2(500),
    diagnostico VARCHAR2(500),
    tratamento VARCHAR2(500),
    id_pet NUMBER(10) NOT NULL,
    id_veterinario NUMBER(10) NOT NULL,
    CONSTRAINT FK_CONSULTA_PET FOREIGN KEY (id_pet) REFERENCES PET(id_pet),
    CONSTRAINT FK_CONSULTA_VETERINARIO FOREIGN KEY (id_veterinario) REFERENCES VETERINARIO(id_veterinario)
);

CREATE TABLE VACINA (
    id_vacina NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(50) NOT NULL,
    data_aplicacao DATE NOT NULL,
    data_proxima_dose DATE,
    fabricante VARCHAR2(50),
    lote VARCHAR2(30),
    observacoes VARCHAR2(500),
    id_pet NUMBER(10) NOT NULL,
    CONSTRAINT FK_VACINA_PET FOREIGN KEY (id_pet) REFERENCES PET(id_pet)
);

CREATE TABLE MEDICAMENTO (
    id_medicamento NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(50) NOT NULL,
    dosagem VARCHAR2(50),
    frequencia VARCHAR2(50),
    data_inicio DATE NOT NULL,
    data_fim DATE,
    status VARCHAR2(20) DEFAULT 'ativo',
    observacoes VARCHAR2(500),
    id_pet NUMBER(10) NOT NULL,
    id_consulta NUMBER(10),
    CONSTRAINT FK_MEDICAMENTO_PET FOREIGN KEY (id_pet) REFERENCES PET(id_pet),
    CONSTRAINT FK_MEDICAMENTO_CONSULTA FOREIGN KEY (id_consulta) REFERENCES CONSULTA(id_consulta)
);

CREATE TABLE EXAME (
    id_exame NUMBER(10) PRIMARY KEY,
    tipo VARCHAR2(50) NOT NULL,
    data_realizacao DATE NOT NULL,
    resultado VARCHAR2(1000),
    url_arquivo VARCHAR2(500),
    observacoes VARCHAR2(500),
    id_pet NUMBER(10) NOT NULL,
    id_consulta NUMBER(10),
    CONSTRAINT FK_EXAME_PET FOREIGN KEY (id_pet) REFERENCES PET(id_pet),
    CONSTRAINT FK_EXAME_CONSULTA FOREIGN KEY (id_consulta) REFERENCES CONSULTA(id_consulta)
);

CREATE TABLE ALERTA (
    id_alerta NUMBER(10) PRIMARY KEY,
    tipo VARCHAR2(30) NOT NULL,
    mensagem VARCHAR2(500) NOT NULL,
    data_geracao TIMESTAMP NOT NULL,
    lido CHAR(1) DEFAULT 'N',
    data_leitura TIMESTAMP,
    id_pet NUMBER(10) NOT NULL,
    CONSTRAINT CK_ALERTA_LIDO CHECK (lido IN ('S', 'N')),
    CONSTRAINT FK_ALERTA_PET FOREIGN KEY (id_pet) REFERENCES PET(id_pet)
);

CREATE TABLE ERRO_LOG (
    id_log NUMBER(10) PRIMARY KEY,
    nome_procedure VARCHAR2(100),
    usuario VARCHAR2(50),
    data_erro DATE,
    codigo_erro NUMBER,
    mensagem_erro VARCHAR2(4000)
);

CREATE TABLE TB_AUDITORIA (
    id_auditoria     NUMBER(10) PRIMARY KEY,
    nome_usuario     VARCHAR2(50) NOT NULL,
    tipo_operacao    VARCHAR2(10) NOT NULL,
    data_hora        TIMESTAMP NOT NULL,
    dados_anteriores VARCHAR2(1000),
    dados_novos      VARCHAR2(1000),
    CONSTRAINT CK_AUDITORIA_TIPO CHECK (tipo_operacao IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- 4. PACKAGE PKG_VALIDACAO
CREATE OR REPLACE PACKAGE PKG_VALIDACAO AS
    FUNCTION FUN_VALIDA_NOME(p_nome VARCHAR2) RETURN BOOLEAN;
    FUNCTION FUN_VALIDA_NOME_VACINA(p_nome VARCHAR2) RETURN BOOLEAN;
    FUNCTION FUN_VALIDA_CPF(p_cpf IN VARCHAR2) RETURN VARCHAR2;
END PKG_VALIDACAO;
/

CREATE OR REPLACE PACKAGE BODY PKG_VALIDACAO AS
    FUNCTION FUN_VALIDA_NOME(p_nome VARCHAR2)
    RETURN BOOLEAN
    IS
        v_contador NUMBER := 0;
        v_caractere VARCHAR2(1);
        e_nome_nulo EXCEPTION;
        e_nome_longo EXCEPTION;
    BEGIN
        IF p_nome IS NULL OR LENGTH(p_nome) = 0 THEN
            RAISE e_nome_nulo;
        END IF;
        IF LENGTH(p_nome) > 100 THEN
            RAISE e_nome_longo;
        END IF;
        FOR v_contador IN 1..LENGTH(p_nome) LOOP
            v_caractere := SUBSTR(p_nome, v_contador, 1);
            IF v_caractere BETWEEN '0' AND '9' THEN
                RETURN FALSE;
            END IF;
        END LOOP;
        RETURN TRUE;
    EXCEPTION
        WHEN e_nome_nulo THEN RETURN FALSE;
        WHEN e_nome_longo THEN RETURN FALSE;
        WHEN VALUE_ERROR THEN RETURN FALSE;
        WHEN OTHERS THEN RETURN FALSE;
    END FUN_VALIDA_NOME;

    FUNCTION FUN_VALIDA_NOME_VACINA(p_nome VARCHAR2)
    RETURN BOOLEAN
    IS
        e_nome_nulo EXCEPTION;
        e_nome_longo EXCEPTION;
    BEGIN
        IF p_nome IS NULL OR LENGTH(p_nome) = 0 THEN
            RAISE e_nome_nulo;
        END IF;
        IF LENGTH(p_nome) > 50 THEN
            RAISE e_nome_longo;
        END IF;
        RETURN TRUE;
    EXCEPTION
        WHEN e_nome_nulo THEN RETURN FALSE;
        WHEN e_nome_longo THEN RETURN FALSE;
        WHEN VALUE_ERROR THEN RETURN FALSE;
        WHEN OTHERS THEN RETURN FALSE;
    END FUN_VALIDA_NOME_VACINA;

    FUNCTION FUN_VALIDA_CPF(p_cpf IN VARCHAR2)
    RETURN VARCHAR2
    IS
        v_cpf              VARCHAR2(11) := '';
        v_char             VARCHAR2(1);
        v_primeiro_digito  NUMBER;
        v_soma             NUMBER;
        v_peso             NUMBER;
        v_digito1          NUMBER;
        v_digito2          NUMBER;
        v_todos_iguais     BOOLEAN;
        e_cpf_nulo         EXCEPTION;
        e_tamanho_invalido EXCEPTION;
        e_cpf_repetido     EXCEPTION;
    BEGIN
        IF p_cpf IS NULL THEN
            RAISE e_cpf_nulo;
        END IF;
        FOR i IN 1..LENGTH(p_cpf) LOOP
            v_char := SUBSTR(p_cpf, i, 1);
            IF v_char BETWEEN '0' AND '9' THEN
                v_cpf := v_cpf || v_char;
            END IF;
        END LOOP;
        IF LENGTH(v_cpf) != 11 THEN
            RAISE e_tamanho_invalido;
        END IF;
        v_primeiro_digito := TO_NUMBER(SUBSTR(v_cpf, 1, 1));
        v_todos_iguais := TRUE;
        FOR i IN 2..11 LOOP
            IF TO_NUMBER(SUBSTR(v_cpf, i, 1)) != v_primeiro_digito THEN
                v_todos_iguais := FALSE;
            END IF;
        END LOOP;
        IF v_todos_iguais THEN
            RAISE e_cpf_repetido;
        END IF;
        v_soma := 0;
        v_peso := 10;
        FOR i IN 1..9 LOOP
            v_soma := v_soma + TO_NUMBER(SUBSTR(v_cpf, i, 1)) * v_peso;
            v_peso := v_peso - 1;
        END LOOP;
        v_digito1 := 11 - MOD(v_soma, 11);
        IF v_digito1 >= 10 THEN
            v_digito1 := 0;
        END IF;
        v_soma := 0;
        v_peso := 11;
        FOR i IN 1..10 LOOP
            v_soma := v_soma + TO_NUMBER(SUBSTR(v_cpf, i, 1)) * v_peso;
            v_peso := v_peso - 1;
        END LOOP;
        v_digito2 := 11 - MOD(v_soma, 11);
        IF v_digito2 >= 10 THEN
            v_digito2 := 0;
        END IF;
        IF v_digito1 = TO_NUMBER(SUBSTR(v_cpf, 10, 1)) AND v_digito2 = TO_NUMBER(SUBSTR(v_cpf, 11, 1)) THEN
            RETURN 'VALIDO';
        ELSE
            RETURN 'INVALIDO: digito verificador nao confere';
        END IF;
    EXCEPTION
        WHEN e_cpf_nulo THEN RETURN 'INVALIDO: CPF nao informado';
        WHEN e_tamanho_invalido THEN RETURN 'INVALIDO: CPF deve conter 11 digitos numericos';
        WHEN e_cpf_repetido THEN RETURN 'INVALIDO: CPF com digitos repetidos';
        WHEN VALUE_ERROR THEN RETURN 'INVALIDO: CPF contem caracteres nao numericos';
        WHEN OTHERS THEN RETURN 'INVALIDO: ' || SQLERRM;
    END FUN_VALIDA_CPF;
END PKG_VALIDACAO;
/

-- 5. PACKAGE PKG_LOG
CREATE OR REPLACE PACKAGE PKG_LOG AS
    PROCEDURE PRC_INSERE_LOG(
        p_nome_procedure IN VARCHAR2,
        p_codigo_erro IN NUMBER,
        p_mensagem_erro IN VARCHAR2
    );
END PKG_LOG;
/

CREATE OR REPLACE PACKAGE BODY PKG_LOG AS
    PROCEDURE PRC_INSERE_LOG(
        p_nome_procedure IN VARCHAR2,
        p_codigo_erro IN NUMBER,
        p_mensagem_erro IN VARCHAR2
    )
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        e_procedure_nula EXCEPTION;
        e_erro_insert EXCEPTION;
    BEGIN
        IF p_nome_procedure IS NULL THEN
            RAISE e_procedure_nula;
        END IF;
        INSERT INTO ERRO_LOG (id_log, nome_procedure, usuario, data_erro, codigo_erro, mensagem_erro)
        VALUES (SEQ_ID_LOG.NEXTVAL, p_nome_procedure, USER, SYSDATE, p_codigo_erro, p_mensagem_erro);
        COMMIT;
    EXCEPTION
        WHEN e_procedure_nula THEN NULL;
        WHEN e_erro_insert THEN ROLLBACK;
        WHEN VALUE_ERROR THEN ROLLBACK;
        WHEN OTHERS THEN ROLLBACK;
    END PRC_INSERE_LOG;
END PKG_LOG;
/

-- 6. PACKAGE PKG_CADASTRO
CREATE OR REPLACE PACKAGE PKG_CADASTRO AS
    PROCEDURE PRC_INSERE_TUTOR(
        p_nome IN VARCHAR2, p_cpf IN VARCHAR2, p_email IN VARCHAR2, p_telefone IN VARCHAR2, p_data_nascimento IN DATE, p_endereco IN VARCHAR2, p_retorno OUT VARCHAR2
    );
    PROCEDURE PRC_INSERE_PET(
        p_nome IN VARCHAR2, p_especie IN VARCHAR2, p_raca IN VARCHAR2, p_data_nascimento IN DATE, p_peso IN NUMBER, p_sexo IN CHAR, p_castrado IN CHAR, p_id_tutor IN NUMBER, p_retorno OUT VARCHAR2
    );
    PROCEDURE PRC_INSERE_CLINICA(
        p_nome IN VARCHAR2, p_cnpj IN VARCHAR2, p_email IN VARCHAR2, p_telefone IN VARCHAR2, p_endereco IN VARCHAR2, p_retorno OUT VARCHAR2
    );
    PROCEDURE PRC_INSERE_VETERINARIO(
        p_nome IN VARCHAR2, p_crmv IN VARCHAR2, p_especialidade IN VARCHAR2, p_email IN VARCHAR2, p_telefone IN VARCHAR2, p_id_clinica IN NUMBER, p_retorno OUT VARCHAR2
    );
    PROCEDURE PRC_INSERE_CONSULTA(
        p_data_hora IN TIMESTAMP, p_tipo IN VARCHAR2, p_status IN VARCHAR2, p_observacoes IN VARCHAR2, p_diagnostico IN VARCHAR2, p_tratamento IN VARCHAR2, p_id_pet IN NUMBER, p_id_veterinario IN NUMBER, p_retorno OUT VARCHAR2
    );
    PROCEDURE PRC_INSERE_VACINA(
        p_nome IN VARCHAR2, p_data_aplicacao IN DATE, p_data_proxima_dose IN DATE, p_fabricante IN VARCHAR2, p_lote IN VARCHAR2, p_observacoes IN VARCHAR2, p_id_pet IN NUMBER, p_retorno OUT VARCHAR2
    );
    PROCEDURE PRC_INSERE_MEDICAMENTO(
        p_nome IN VARCHAR2, p_dosagem IN VARCHAR2, p_frequencia IN VARCHAR2, p_data_inicio IN DATE, p_data_fim IN DATE, p_status IN VARCHAR2, p_observacoes IN VARCHAR2, p_id_pet IN NUMBER, p_id_consulta IN NUMBER, p_retorno OUT VARCHAR2
    );
    PROCEDURE PRC_INSERE_EXAME(
        p_tipo IN VARCHAR2, p_data_realizacao IN DATE, p_resultado IN VARCHAR2, p_url_arquivo IN VARCHAR2, p_observacoes IN VARCHAR2, p_id_pet IN NUMBER, p_id_consulta IN NUMBER, p_retorno OUT VARCHAR2
    );
    PROCEDURE PRC_INSERE_ALERTA(
        p_tipo IN VARCHAR2, p_mensagem IN VARCHAR2, p_data_geracao IN TIMESTAMP, p_lido IN CHAR, p_data_leitura IN TIMESTAMP, p_id_pet IN NUMBER, p_retorno OUT VARCHAR2
    );
END PKG_CADASTRO;
/

CREATE OR REPLACE PACKAGE BODY PKG_CADASTRO AS
    PROCEDURE PRC_INSERE_TUTOR(
        p_nome IN VARCHAR2, p_cpf IN VARCHAR2, p_email IN VARCHAR2, p_telefone IN VARCHAR2, p_data_nascimento IN DATE, p_endereco IN VARCHAR2, p_retorno OUT VARCHAR2
    ) IS
        v_id_tutor NUMBER(10);
        v_status_cpf VARCHAR2(60);
    BEGIN
        IF NOT PKG_VALIDACAO.FUN_VALIDA_NOME(p_nome) THEN
            p_retorno := 'ERRO: Nome invalido';
            RETURN;
        END IF;
        v_status_cpf := PKG_VALIDACAO.FUN_VALIDA_CPF(p_cpf);
        IF v_status_cpf != 'VALIDO' THEN
            p_retorno := 'ERRO: ' || v_status_cpf;
            RETURN;
        END IF;
        v_id_tutor := SEQ_ID_TUTOR.NEXTVAL;
        INSERT INTO TUTOR (id_tutor, nome, cpf, email, telefone, data_nascimento, endereco)
        VALUES (v_id_tutor, p_nome, p_cpf, p_email, p_telefone, p_data_nascimento, p_endereco);
        COMMIT;
        p_retorno := 'Tutor cadastrado com sucesso! ID: ' || v_id_tutor;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN p_retorno := 'ERRO: CPF ou E-mail ja cadastrado'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_TUTOR', SQLCODE, SQLERRM);
        WHEN VALUE_ERROR THEN p_retorno := 'ERRO: Tipo de dado invalido'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_TUTOR', SQLCODE, SQLERRM);
        WHEN OTHERS THEN p_retorno := 'ERRO: ' || SQLERRM; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_TUTOR', SQLCODE, SQLERRM);
    END PRC_INSERE_TUTOR;

    PROCEDURE PRC_INSERE_PET(
        p_nome IN VARCHAR2, p_especie IN VARCHAR2, p_raca IN VARCHAR2, p_data_nascimento IN DATE, p_peso IN NUMBER, p_sexo IN CHAR, p_castrado IN CHAR, p_id_tutor IN NUMBER, p_retorno OUT VARCHAR2
    ) IS
        v_id_pet NUMBER(10);
    BEGIN
        IF NOT PKG_VALIDACAO.FUN_VALIDA_NOME(p_nome) THEN
            p_retorno := 'ERRO: Nome do pet invalido';
            RETURN;
        END IF;
        v_id_pet := SEQ_ID_PET.NEXTVAL;
        INSERT INTO PET (id_pet, nome, especie, raca, data_nascimento, peso, sexo, castrado, id_tutor)
        VALUES (v_id_pet, p_nome, p_especie, p_raca, p_data_nascimento, p_peso, p_sexo, NVL(p_castrado, 'N'), p_id_tutor);
        COMMIT;
        p_retorno := 'Pet cadastrado com sucesso! ID: ' || v_id_pet;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN p_retorno := 'ERRO: ID do pet ja existe'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_PET', SQLCODE, SQLERRM);
        WHEN VALUE_ERROR THEN p_retorno := 'ERRO: Tipo de dado invalido'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_PET', SQLCODE, SQLERRM);
        WHEN OTHERS THEN p_retorno := 'ERRO: ' || SQLERRM; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_PET', SQLCODE, SQLERRM);
    END PRC_INSERE_PET;

    PROCEDURE PRC_INSERE_CLINICA(
        p_nome IN VARCHAR2, p_cnpj IN VARCHAR2, p_email IN VARCHAR2, p_telefone IN VARCHAR2, p_endereco IN VARCHAR2, p_retorno OUT VARCHAR2
    ) IS
        v_id_clinica NUMBER(10);
    BEGIN
        IF NOT PKG_VALIDACAO.FUN_VALIDA_NOME(p_nome) THEN
            p_retorno := 'ERRO: Nome da clinica invalido';
            RETURN;
        END IF;
        v_id_clinica := SEQ_ID_CLINICA.NEXTVAL;
        INSERT INTO CLINICA (id_clinica, nome, cnpj, email, telefone, endereco)
        VALUES (v_id_clinica, p_nome, p_cnpj, p_email, p_telefone, p_endereco);
        COMMIT;
        p_retorno := 'Clinica cadastrada com sucesso! ID: ' || v_id_clinica;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN p_retorno := 'ERRO: CNPJ ou E-mail ja cadastrado'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_CLINICA', SQLCODE, SQLERRM);
        WHEN VALUE_ERROR THEN p_retorno := 'ERRO: Tipo de dado invalido'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_CLINICA', SQLCODE, SQLERRM);
        WHEN OTHERS THEN p_retorno := 'ERRO: ' || SQLERRM; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_CLINICA', SQLCODE, SQLERRM);
    END PRC_INSERE_CLINICA;

    PROCEDURE PRC_INSERE_VETERINARIO(
        p_nome IN VARCHAR2, p_crmv IN VARCHAR2, p_especialidade IN VARCHAR2, p_email IN VARCHAR2, p_telefone IN VARCHAR2, p_id_clinica IN NUMBER, p_retorno OUT VARCHAR2
    ) IS
        v_id_veterinario NUMBER(10);
    BEGIN
        IF NOT PKG_VALIDACAO.FUN_VALIDA_NOME(p_nome) THEN
            p_retorno := 'ERRO: Nome do veterinario invalido';
            RETURN;
        END IF;
        v_id_veterinario := SEQ_ID_VETERINARIO.NEXTVAL;
        INSERT INTO VETERINARIO (id_veterinario, nome, crmv, especialidade, email, telefone, id_clinica)
        VALUES (v_id_veterinario, p_nome, p_crmv, p_especialidade, p_email, p_telefone, p_id_clinica);
        COMMIT;
        p_retorno := 'Veterinario cadastrado com sucesso! ID: ' || v_id_veterinario;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN p_retorno := 'ERRO: CRMV ou E-mail ja cadastrado'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_VETERINARIO', SQLCODE, SQLERRM);
        WHEN VALUE_ERROR THEN p_retorno := 'ERRO: Tipo de dado invalido'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_VETERINARIO', SQLCODE, SQLERRM);
        WHEN OTHERS THEN p_retorno := 'ERRO: ' || SQLERRM; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_VETERINARIO', SQLCODE, SQLERRM);
    END PRC_INSERE_VETERINARIO;

    PROCEDURE PRC_INSERE_CONSULTA(
        p_data_hora IN TIMESTAMP, p_tipo IN VARCHAR2, p_status IN VARCHAR2, p_observacoes IN VARCHAR2, p_diagnostico IN VARCHAR2, p_tratamento IN VARCHAR2, p_id_pet IN NUMBER, p_id_veterinario IN NUMBER, p_retorno OUT VARCHAR2
    ) IS
        v_id_consulta NUMBER(10);
    BEGIN
        v_id_consulta := SEQ_ID_CONSULTA.NEXTVAL;
        INSERT INTO CONSULTA (id_consulta, data_hora, tipo, status, observacoes, diagnostico, tratamento, id_pet, id_veterinario)
        VALUES (v_id_consulta, p_data_hora, p_tipo, p_status, p_observacoes, p_diagnostico, p_tratamento, p_id_pet, p_id_veterinario);
        COMMIT;
        p_retorno := 'Consulta cadastrada com sucesso! ID: ' || v_id_consulta;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN p_retorno := 'ERRO: ID da consulta ja existe'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_CONSULTA', SQLCODE, SQLERRM);
        WHEN VALUE_ERROR THEN p_retorno := 'ERRO: Tipo de dado invalido'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_CONSULTA', SQLCODE, SQLERRM);
        WHEN OTHERS THEN p_retorno := 'ERRO: ' || SQLERRM; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_CONSULTA', SQLCODE, SQLERRM);
    END PRC_INSERE_CONSULTA;

    PROCEDURE PRC_INSERE_VACINA(
        p_nome IN VARCHAR2, p_data_aplicacao IN DATE, p_data_proxima_dose IN DATE, p_fabricante IN VARCHAR2, p_lote IN VARCHAR2, p_observacoes IN VARCHAR2, p_id_pet IN NUMBER, p_retorno OUT VARCHAR2
    ) IS
        v_id_vacina NUMBER(10);
    BEGIN
        IF NOT PKG_VALIDACAO.FUN_VALIDA_NOME_VACINA(p_nome) THEN
            p_retorno := 'ERRO: Nome da vacina nao pode ser vazio';
            RETURN;
        END IF;
        v_id_vacina := SEQ_ID_VACINA.NEXTVAL;
        INSERT INTO VACINA (id_vacina, nome, data_aplicacao, data_proxima_dose, fabricante, lote, observacoes, id_pet)
        VALUES (v_id_vacina, p_nome, p_data_aplicacao, p_data_proxima_dose, p_fabricante, p_lote, p_observacoes, p_id_pet);
        COMMIT;
        p_retorno := 'Vacina cadastrada com sucesso! ID: ' || v_id_vacina;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN p_retorno := 'ERRO: ID da vacina ja existe'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_VACINA', SQLCODE, SQLERRM);
        WHEN VALUE_ERROR THEN p_retorno := 'ERRO: Tipo de dado invalido'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_VACINA', SQLCODE, SQLERRM);
        WHEN OTHERS THEN p_retorno := 'ERRO: ' || SQLERRM; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_VACINA', SQLCODE, SQLERRM);
    END PRC_INSERE_VACINA;

    PROCEDURE PRC_INSERE_MEDICAMENTO(
        p_nome IN VARCHAR2, p_dosagem IN VARCHAR2, p_frequencia IN VARCHAR2, p_data_inicio IN DATE, p_data_fim IN DATE, p_status IN VARCHAR2, p_observacoes IN VARCHAR2, p_id_pet IN NUMBER, p_id_consulta IN NUMBER, p_retorno OUT VARCHAR2
    ) IS
        v_id_medicamento NUMBER(10);
    BEGIN
        IF NOT PKG_VALIDACAO.FUN_VALIDA_NOME(p_nome) THEN
            p_retorno := 'ERRO: Nome do medicamento invalido';
            RETURN;
        END IF;
        v_id_medicamento := SEQ_ID_MEDICAMENTO.NEXTVAL;
        INSERT INTO MEDICAMENTO (id_medicamento, nome, dosagem, frequencia, data_inicio, data_fim, status, observacoes, id_pet, id_consulta)
        VALUES (v_id_medicamento, p_nome, p_dosagem, p_frequencia, p_data_inicio, p_data_fim, NVL(p_status, 'ativo'), p_observacoes, p_id_pet, p_id_consulta);
        COMMIT;
        p_retorno := 'Medicamento cadastrado com sucesso! ID: ' || v_id_medicamento;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN p_retorno := 'ERRO: ID do medicamento ja existe'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_MEDICAMENTO', SQLCODE, SQLERRM);
        WHEN VALUE_ERROR THEN p_retorno := 'ERRO: Tipo de dado invalido'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_MEDICAMENTO', SQLCODE, SQLERRM);
        WHEN OTHERS THEN p_retorno := 'ERRO: ' || SQLERRM; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_MEDICAMENTO', SQLCODE, SQLERRM);
    END PRC_INSERE_MEDICAMENTO;

    PROCEDURE PRC_INSERE_EXAME(
        p_tipo IN VARCHAR2, p_data_realizacao IN DATE, p_resultado IN VARCHAR2, p_url_arquivo IN VARCHAR2, p_observacoes IN VARCHAR2, p_id_pet IN NUMBER, p_id_consulta IN NUMBER, p_retorno OUT VARCHAR2
    ) IS
        v_id_exame NUMBER(10);
    BEGIN
        v_id_exame := SEQ_ID_EXAME.NEXTVAL;
        INSERT INTO EXAME (id_exame, tipo, data_realizacao, resultado, url_arquivo, observacoes, id_pet, id_consulta)
        VALUES (v_id_exame, p_tipo, p_data_realizacao, p_resultado, p_url_arquivo, p_observacoes, p_id_pet, p_id_consulta);
        COMMIT;
        p_retorno := 'Exame cadastrado com sucesso! ID: ' || v_id_exame;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN p_retorno := 'ERRO: ID do exame ja existe'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_EXAME', SQLCODE, SQLERRM);
        WHEN VALUE_ERROR THEN p_retorno := 'ERRO: Tipo de dado invalido'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_EXAME', SQLCODE, SQLERRM);
        WHEN OTHERS THEN p_retorno := 'ERRO: ' || SQLERRM; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_EXAME', SQLCODE, SQLERRM);
    END PRC_INSERE_EXAME;

    PROCEDURE PRC_INSERE_ALERTA(
        p_tipo IN VARCHAR2, p_mensagem IN VARCHAR2, p_data_geracao IN TIMESTAMP, p_lido IN CHAR, p_data_leitura IN TIMESTAMP, p_id_pet IN NUMBER, p_retorno OUT VARCHAR2
    ) IS
        v_id_alerta NUMBER(10);
    BEGIN
        v_id_alerta := SEQ_ID_ALERTA.NEXTVAL;
        INSERT INTO ALERTA (id_alerta, tipo, mensagem, data_geracao, lido, data_leitura, id_pet)
        VALUES (v_id_alerta, p_tipo, p_mensagem, p_data_geracao, NVL(p_lido, 'N'), p_data_leitura, p_id_pet);
        COMMIT;
        p_retorno := 'Alerta cadastrado com sucesso! ID: ' || v_id_alerta;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN p_retorno := 'ERRO: ID do alerta ja existe'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_ALERTA', SQLCODE, SQLERRM);
        WHEN VALUE_ERROR THEN p_retorno := 'ERRO: Tipo de dado invalido'; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_ALERTA', SQLCODE, SQLERRM);
        WHEN OTHERS THEN p_retorno := 'ERRO: ' || SQLERRM; ROLLBACK; PKG_LOG.PRC_INSERE_LOG('PKG_CADASTRO.PRC_INSERE_ALERTA', SQLCODE, SQLERRM);
    END PRC_INSERE_ALERTA;
END PKG_CADASTRO;
/

-- 7. PACKAGE PKG_JSON
CREATE OR REPLACE PACKAGE PKG_JSON AS
    FUNCTION FUN_ESCAPE_JSON(p_texto IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION FUN_FORMATA_DATA(p_data IN DATE) RETURN VARCHAR2;
    FUNCTION FUN_MONTA_JSON_PET(p_id_pet IN NUMBER) RETURN CLOB;
    FUNCTION FUN_MONTA_JSON_DATASET RETURN CLOB;
END PKG_JSON;
/

CREATE OR REPLACE PACKAGE BODY PKG_JSON AS
    FUNCTION FUN_ESCAPE_JSON(p_texto IN VARCHAR2)
    RETURN VARCHAR2
    IS
        e_texto_nulo EXCEPTION;
        e_texto_longo EXCEPTION;
        v_texto VARCHAR2(32767);
    BEGIN
        IF p_texto IS NULL THEN
            RAISE e_texto_nulo;
        END IF;
        IF LENGTH(p_texto) > 30000 THEN
            RAISE e_texto_longo;
        END IF;
        v_texto := REPLACE(p_texto, '\', '\\');
        v_texto := REPLACE(v_texto, '"', '\"');
        v_texto := REPLACE(v_texto, CHR(10), '\n');
        v_texto := REPLACE(v_texto, CHR(13), '\r');
        v_texto := REPLACE(v_texto, CHR(9), '\t');
        RETURN v_texto;
    EXCEPTION
        WHEN e_texto_nulo THEN RETURN '';
        WHEN e_texto_longo THEN RETURN SUBSTR(p_texto, 1, 30000);
        WHEN VALUE_ERROR THEN RETURN '';
        WHEN OTHERS THEN RETURN '';
    END FUN_ESCAPE_JSON;

    FUNCTION FUN_FORMATA_DATA(p_data IN DATE)
    RETURN VARCHAR2
    IS
        e_data_nula EXCEPTION;
        e_data_invalida EXCEPTION;
    BEGIN
        IF p_data IS NULL THEN
            RAISE e_data_nula;
        END IF;
        IF p_data < TO_DATE('1900-01-01', 'YYYY-MM-DD') THEN
            RAISE e_data_invalida;
        END IF;
        RETURN '"' || TO_CHAR(p_data, 'YYYY-MM-DD') || '"';
    EXCEPTION
        WHEN e_data_nula THEN RETURN 'null';
        WHEN e_data_invalida THEN RETURN 'null';
        WHEN VALUE_ERROR THEN RETURN 'null';
        WHEN OTHERS THEN RETURN 'null';
    END FUN_FORMATA_DATA;

    FUNCTION FUN_MONTA_JSON_PET(p_id_pet IN NUMBER)
    RETURN CLOB
    IS
        v_nome_pet       VARCHAR2(200);
        v_especie        VARCHAR2(200);
        v_raca           VARCHAR2(200);
        v_data_nasc      DATE;
        v_peso           NUMBER;
        v_sexo           VARCHAR2(10);
        v_castrado       VARCHAR2(10);
        v_nome_tutor     VARCHAR2(200);
        v_email_tutor    VARCHAR2(200);
        v_telefone_tutor VARCHAR2(200);
        v_json           CLOB;
        v_primeiro       BOOLEAN;
        v_data_format    VARCHAR2(30);
        v_peso_format    VARCHAR2(50);
        e_id_invalido    EXCEPTION;
        e_pet_nao_encontrado EXCEPTION;
        e_erro_montagem  EXCEPTION;
    BEGIN
        IF p_id_pet IS NULL OR p_id_pet <= 0 THEN
            RAISE e_id_invalido;
        END IF;
        BEGIN
            SELECT p.nome, p.especie, p.raca, p.data_nascimento, p.peso,
                   p.sexo, p.castrado, t.nome, t.email, t.telefone
            INTO v_nome_pet, v_especie, v_raca, v_data_nasc, v_peso,
                 v_sexo, v_castrado, v_nome_tutor, v_email_tutor, v_telefone_tutor
            FROM PET p
            JOIN TUTOR t ON p.id_tutor = t.id_tutor
            WHERE p.id_pet = p_id_pet;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RAISE e_pet_nao_encontrado;
        END;
        IF v_data_nasc IS NULL THEN v_data_format := 'null';
        ELSE v_data_format := FUN_FORMATA_DATA(v_data_nasc); END IF;
        IF v_peso IS NULL THEN v_peso_format := 'null';
        ELSE v_peso_format := TO_CHAR(v_peso, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS=''.,'''); END IF;

        v_json := '{'
            || '"id_pet":' || p_id_pet || ','
            || '"nome":"' || FUN_ESCAPE_JSON(v_nome_pet) || '",'
            || '"especie":"' || FUN_ESCAPE_JSON(v_especie) || '",'
            || '"raca":"' || FUN_ESCAPE_JSON(v_raca) || '",'
            || '"data_nascimento":' || v_data_format || ','
            || '"peso":' || v_peso_format || ','
            || '"sexo":"' || FUN_ESCAPE_JSON(v_sexo) || '",'
            || '"castrado":"' || FUN_ESCAPE_JSON(v_castrado) || '",'
            || '"tutor":{'
                || '"nome":"' || FUN_ESCAPE_JSON(v_nome_tutor) || '",'
                || '"email":"' || FUN_ESCAPE_JSON(v_email_tutor) || '",'
                || '"telefone":"' || FUN_ESCAPE_JSON(v_telefone_tutor) || '"'
            || '},';

        v_json := v_json || '"consultas":[';
        v_primeiro := TRUE;
        FOR r IN (
            SELECT c.id_consulta, TO_CHAR(c.data_hora, 'YYYY-MM-DD"T"HH24:MI:SS') AS data_hora,
                   c.tipo, c.status, c.observacoes, c.diagnostico, c.tratamento,
                   v.nome AS vet_nome, v.crmv, cl.nome AS clinica_nome
            FROM CONSULTA c
            JOIN VETERINARIO v ON c.id_veterinario = v.id_veterinario
            JOIN CLINICA cl ON v.id_clinica = cl.id_clinica
            WHERE c.id_pet = p_id_pet ORDER BY c.id_consulta
        ) LOOP
            IF NOT v_primeiro THEN v_json := v_json || ','; END IF;
            v_primeiro := FALSE;
            v_json := v_json || '{'
                || '"id_consulta":' || r.id_consulta || ','
                || '"data_hora":"' || r.data_hora || '",'
                || '"tipo":"' || FUN_ESCAPE_JSON(r.tipo) || '",'
                || '"status":"' || FUN_ESCAPE_JSON(r.status) || '",'
                || '"observacoes":"' || FUN_ESCAPE_JSON(r.observacoes) || '",'
                || '"diagnostico":"' || FUN_ESCAPE_JSON(r.diagnostico) || '",'
                || '"tratamento":"' || FUN_ESCAPE_JSON(r.tratamento) || '",'
                || '"veterinario":{"nome":"' || FUN_ESCAPE_JSON(r.vet_nome) || '","crmv":"' || FUN_ESCAPE_JSON(r.crmv) || '"},'
                || '"clinica":{"nome":"' || FUN_ESCAPE_JSON(r.clinica_nome) || '"}'
                || '}';
        END LOOP;
        v_json := v_json || '],';

        v_json := v_json || '"vacinas":['; 
        v_primeiro := TRUE;
        FOR r IN (
            SELECT id_vacina, nome, data_aplicacao, data_proxima_dose, fabricante, lote, observacoes
            FROM VACINA WHERE id_pet = p_id_pet ORDER BY id_vacina
        ) LOOP
            IF NOT v_primeiro THEN v_json := v_json || ','; END IF;
            v_primeiro := FALSE;
            v_json := v_json || '{'
                || '"id_vacina":' || r.id_vacina || ','
                || '"nome":"' || FUN_ESCAPE_JSON(r.nome) || '",'
                || '"data_aplicacao":' || FUN_FORMATA_DATA(r.data_aplicacao) || ','
                || '"data_proxima_dose":' || FUN_FORMATA_DATA(r.data_proxima_dose) || ','
                || '"fabricante":"' || FUN_ESCAPE_JSON(r.fabricante) || '",'
                || '"lote":"' || FUN_ESCAPE_JSON(r.lote) || '",'
                || '"observacoes":"' || FUN_ESCAPE_JSON(r.observacoes) || '"'
                || '}';
        END LOOP;
        v_json := v_json || '],';

        v_json := v_json || '"medicamentos":['; 
        v_primeiro := TRUE;
        FOR r IN (
            SELECT id_medicamento, nome, dosagem, frequencia, data_inicio, data_fim, status, observacoes
            FROM MEDICAMENTO WHERE id_pet = p_id_pet ORDER BY id_medicamento
        ) LOOP
            IF NOT v_primeiro THEN v_json := v_json || ','; END IF;
            v_primeiro := FALSE;
            v_json := v_json || '{'
                || '"id_medicamento":' || r.id_medicamento || ','
                || '"nome":"' || FUN_ESCAPE_JSON(r.nome) || '",'
                || '"dosagem":"' || FUN_ESCAPE_JSON(r.dosagem) || '",'
                || '"frequencia":"' || FUN_ESCAPE_JSON(r.frequencia) || '",'
                || '"data_inicio":' || FUN_FORMATA_DATA(r.data_inicio) || ','
                || '"data_fim":' || FUN_FORMATA_DATA(r.data_fim) || ','
                || '"status":"' || FUN_ESCAPE_JSON(r.status) || '",'
                || '"observacoes":"' || FUN_ESCAPE_JSON(r.observacoes) || '"'
                || '}';
        END LOOP;
        v_json := v_json || '],';

        v_json := v_json || '"exames":['; 
        v_primeiro := TRUE;
        FOR r IN (
            SELECT id_exame, tipo, data_realizacao, resultado, url_arquivo, observacoes
            FROM EXAME WHERE id_pet = p_id_pet ORDER BY id_exame
        ) LOOP
            IF NOT v_primeiro THEN v_json := v_json || ','; END IF;
            v_primeiro := FALSE;
            v_json := v_json || '{'
                || '"id_exame":' || r.id_exame || ','
                || '"tipo":"' || FUN_ESCAPE_JSON(r.tipo) || '",'
                || '"data_realizacao":' || FUN_FORMATA_DATA(r.data_realizacao) || ','
                || '"resultado":"' || FUN_ESCAPE_JSON(r.resultado) || '",'
                || '"url_arquivo":"' || FUN_ESCAPE_JSON(r.url_arquivo) || '",'
                || '"observacoes":"' || FUN_ESCAPE_JSON(r.observacoes) || '"'
                || '}';
        END LOOP;
        v_json := v_json || '],';

        v_json := v_json || '"alertas":['; 
        v_primeiro := TRUE;
        FOR r IN (
            SELECT id_alerta, tipo, mensagem, TO_CHAR(data_geracao, 'YYYY-MM-DD"T"HH24:MI:SS') AS data_geracao,
                   lido, TO_CHAR(data_leitura, 'YYYY-MM-DD"T"HH24:MI:SS') AS data_leitura
            FROM ALERTA WHERE id_pet = p_id_pet ORDER BY id_alerta
        ) LOOP
            IF NOT v_primeiro THEN v_json := v_json || ','; END IF;
            v_primeiro := FALSE;
            v_json := v_json || '{'
                || '"id_alerta":' || r.id_alerta || ','
                || '"tipo":"' || FUN_ESCAPE_JSON(r.tipo) || '",'
                || '"mensagem":"' || FUN_ESCAPE_JSON(r.mensagem) || '",'
                || '"data_geracao":"' || r.data_geracao || '",'
                || '"lido":"' || FUN_ESCAPE_JSON(r.lido) || '",'
                || '"data_leitura":' || CASE WHEN r.data_leitura IS NULL THEN 'null' ELSE '"' || r.data_leitura || '"' END
                || '}';
        END LOOP;
        v_json := v_json || ']';

        v_json := v_json || '}';
        RETURN v_json;
    EXCEPTION
        WHEN e_id_invalido THEN RETURN '{"erro":"id_pet invalido"}';
        WHEN e_pet_nao_encontrado THEN RETURN '{"erro":"pet nao encontrado"}';
        WHEN e_erro_montagem THEN RETURN '{"erro":"erro ao montar JSON"}';
        WHEN OTHERS THEN RETURN '{"erro":"' || REPLACE(SQLERRM, '"', '\"') || '"}';
    END FUN_MONTA_JSON_PET;

    FUNCTION FUN_MONTA_JSON_DATASET
    RETURN CLOB
    IS
        v_json CLOB := '[';
        v_primeiro BOOLEAN := TRUE;
        v_qtd NUMBER;
        e_sem_pets EXCEPTION;
        e_erro_montagem EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO v_qtd FROM PET;
        IF v_qtd = 0 THEN RAISE e_sem_pets; END IF;
        FOR r IN (SELECT id_pet FROM PET ORDER BY id_pet) LOOP
            IF NOT v_primeiro THEN v_json := v_json || ','; END IF;
            v_primeiro := FALSE;
            v_json := v_json || FUN_MONTA_JSON_PET(r.id_pet);
        END LOOP;
        v_json := v_json || ']';
        RETURN v_json;
    EXCEPTION
        WHEN e_sem_pets THEN RETURN '[]';
        WHEN e_erro_montagem THEN RETURN '[]';
        WHEN VALUE_ERROR THEN RETURN '[]';
        WHEN OTHERS THEN RETURN '[]';
    END FUN_MONTA_JSON_DATASET;
END PKG_JSON;
/

-- 8. PACKAGE PKG_RELATORIOS
CREATE OR REPLACE PACKAGE PKG_RELATORIOS AS
    PROCEDURE PRC_RELATORIO_JSON_PET_TUTOR;
    PROCEDURE PRC_RELATORIO_PESO_POR_ESPECIE;
END PKG_RELATORIOS;
/

CREATE OR REPLACE PACKAGE BODY PKG_RELATORIOS AS
    PROCEDURE PRC_RELATORIO_JSON_PET_TUTOR IS
        v_qtd_registros NUMBER;
        v_contador NUMBER := 0;
        v_json CLOB;
        e_sem_dados EXCEPTION;
        e_erro_json EXCEPTION;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== RELATORIO JSON: PETS E TUTORES ===');
        SELECT COUNT(*) INTO v_qtd_registros FROM PET;
        IF v_qtd_registros = 0 THEN RAISE e_sem_dados; END IF;
        DBMS_OUTPUT.PUT_LINE('[');
        FOR reg IN (SELECT id_pet FROM PET ORDER BY id_pet) LOOP
            v_contador := v_contador + 1;
            v_json := PKG_JSON.FUN_MONTA_JSON_PET(reg.id_pet);
            IF v_contador < v_qtd_registros THEN
                DBMS_OUTPUT.PUT_LINE('  ' || DBMS_LOB.SUBSTR(v_json, 4000, 1) || ',');
            ELSE
                DBMS_OUTPUT.PUT_LINE('  ' || DBMS_LOB.SUBSTR(v_json, 4000, 1));
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(']');
        DBMS_OUTPUT.PUT_LINE('Total de registros no JSON: ' || v_contador);
    EXCEPTION
        WHEN e_sem_dados THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Nenhum pet encontrado');
            PKG_LOG.PRC_INSERE_LOG('PKG_RELATORIOS.PRC_RELATORIO_JSON_PET_TUTOR', -20001, 'Nenhum pet encontrado');
        WHEN e_erro_json THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: falha ao montar JSON');
            PKG_LOG.PRC_INSERE_LOG('PKG_RELATORIOS.PRC_RELATORIO_JSON_PET_TUTOR', -20002, 'Falha ao montar JSON');
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: valor invalido - ' || SQLERRM);
            PKG_LOG.PRC_INSERE_LOG('PKG_RELATORIOS.PRC_RELATORIO_JSON_PET_TUTOR', SQLCODE, SQLERRM);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
            PKG_LOG.PRC_INSERE_LOG('PKG_RELATORIOS.PRC_RELATORIO_JSON_PET_TUTOR', SQLCODE, SQLERRM);
    END PRC_RELATORIO_JSON_PET_TUTOR;

    PROCEDURE PRC_RELATORIO_PESO_POR_ESPECIE IS
        CURSOR c_peso IS
            SELECT p.especie, t.nome AS tutor_nome, p.peso
            FROM PET p JOIN TUTOR t ON p.id_tutor = t.id_tutor
            ORDER BY p.especie, t.nome, p.id_pet;
        v_especie_anterior  PET.especie%TYPE := NULL;
        v_tutor_anterior    TUTOR.nome%TYPE := NULL;
        v_soma_combo        NUMBER := 0;
        v_soma_especie      NUMBER := 0;
        v_soma_geral        NUMBER := 0;
        v_primeiro_registro BOOLEAN := TRUE;
        v_qtd_registros     NUMBER;
        e_sem_dados         EXCEPTION;
        e_peso_invalido     EXCEPTION;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== RELATORIO DE PESO POR ESPECIE E TUTOR ===');
        SELECT COUNT(*) INTO v_qtd_registros FROM PET;
        IF v_qtd_registros = 0 THEN RAISE e_sem_dados; END IF;
        DBMS_OUTPUT.PUT_LINE(RPAD('ESPECIE', 13) || RPAD('TUTOR', 28) || LPAD('PESO(kg)', 10));
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 13, '-') || RPAD('-', 28, '-') || RPAD('-', 10, '-'));
        FOR reg IN c_peso LOOP
            IF reg.peso IS NULL OR reg.peso <= 0 THEN RAISE e_peso_invalido; END IF;
            IF v_primeiro_registro THEN
                v_especie_anterior := reg.especie;
                v_tutor_anterior := reg.tutor_nome;
                v_primeiro_registro := FALSE;
            END IF;
            IF reg.especie != v_especie_anterior OR reg.tutor_nome != v_tutor_anterior THEN
                DBMS_OUTPUT.PUT_LINE(RPAD(v_especie_anterior, 13) || RPAD(v_tutor_anterior, 28) || LPAD(TO_CHAR(v_soma_combo, '999999.99'), 10));
                v_soma_especie := v_soma_especie + v_soma_combo;
                v_soma_combo := 0;
                IF reg.especie != v_especie_anterior THEN
                    DBMS_OUTPUT.PUT_LINE(RPAD('Sub Total', 13) || RPAD(' ', 28) || LPAD(TO_CHAR(v_soma_especie, '999999.99'), 10));
                    v_soma_geral := v_soma_geral + v_soma_especie;
                    v_soma_especie := 0;
                END IF;
                v_especie_anterior := reg.especie;
                v_tutor_anterior := reg.tutor_nome;
            END IF;
            v_soma_combo := v_soma_combo + reg.peso;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(RPAD(v_especie_anterior, 13) || RPAD(v_tutor_anterior, 28) || LPAD(TO_CHAR(v_soma_combo, '999999.99'), 10));
        v_soma_especie := v_soma_especie + v_soma_combo;
        DBMS_OUTPUT.PUT_LINE(RPAD('Sub Total', 13) || RPAD(' ', 28) || LPAD(TO_CHAR(v_soma_especie, '999999.99'), 10));
        v_soma_geral := v_soma_geral + v_soma_especie;
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 13, '-') || RPAD('-', 28, '-') || RPAD('-', 10, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Total Geral', 13) || RPAD(' ', 28) || LPAD(TO_CHAR(v_soma_geral, '999999.99'), 10));
    EXCEPTION
        WHEN e_sem_dados THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Nao ha pets cadastrados');
            PKG_LOG.PRC_INSERE_LOG('PKG_RELATORIOS.PRC_RELATORIO_PESO_POR_ESPECIE', -20003, 'Tabela PET vazia');
        WHEN e_peso_invalido THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: Peso invalido encontrado');
            PKG_LOG.PRC_INSERE_LOG('PKG_RELATORIOS.PRC_RELATORIO_PESO_POR_ESPECIE', -20004, 'Peso invalido');
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: valor invalido - ' || SQLERRM);
            PKG_LOG.PRC_INSERE_LOG('PKG_RELATORIOS.PRC_RELATORIO_PESO_POR_ESPECIE', SQLCODE, SQLERRM);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
            PKG_LOG.PRC_INSERE_LOG('PKG_RELATORIOS.PRC_RELATORIO_PESO_POR_ESPECIE', SQLCODE, SQLERRM);
    END PRC_RELATORIO_PESO_POR_ESPECIE;
END PKG_RELATORIOS;
/

-- 9. PACKAGE PKG_AUDITORIA
CREATE OR REPLACE PACKAGE PKG_AUDITORIA AS
    PROCEDURE PRC_GRAVA_AUDITORIA(
        p_usuario IN VARCHAR2, p_tipo_operacao IN VARCHAR2, p_dados_anteriores IN VARCHAR2, p_dados_novos IN VARCHAR2
    );
END PKG_AUDITORIA;
/
CREATE OR REPLACE PACKAGE BODY PKG_AUDITORIA AS
    PROCEDURE PRC_GRAVA_AUDITORIA(
        p_usuario IN VARCHAR2, p_tipo_operacao IN VARCHAR2, p_dados_anteriores IN VARCHAR2, p_dados_novos IN VARCHAR2
    ) IS
        e_usuario_nulo EXCEPTION;
        e_tipo_invalido EXCEPTION;
    BEGIN
        IF p_usuario IS NULL THEN RAISE e_usuario_nulo; END IF;
        IF p_tipo_operacao NOT IN ('INSERT', 'UPDATE', 'DELETE') THEN RAISE e_tipo_invalido; END IF;
        INSERT INTO TB_AUDITORIA (id_auditoria, nome_usuario, tipo_operacao, data_hora, dados_anteriores, dados_novos)
        VALUES (SEQ_ID_AUDITORIA.NEXTVAL, p_usuario, p_tipo_operacao, SYSTIMESTAMP, p_dados_anteriores, p_dados_novos);
    EXCEPTION
        WHEN e_usuario_nulo THEN RAISE;
        WHEN e_tipo_invalido THEN RAISE;
        WHEN OTHERS THEN RAISE;
    END PRC_GRAVA_AUDITORIA;
END PKG_AUDITORIA;
/

-- 10. TRIGGER DE AUDITORIA
CREATE OR REPLACE TRIGGER TRG_AUDITORIA_PET
AFTER INSERT OR UPDATE OR DELETE ON PET
FOR EACH ROW
DECLARE
    v_tipo_operacao VARCHAR2(10);
    v_dados_antigos VARCHAR2(1000);
    v_dados_novos   VARCHAR2(1000);
BEGIN
    IF INSERTING THEN
        v_tipo_operacao := 'INSERT';
        v_dados_antigos := NULL;
        v_dados_novos := 'id_pet=' || :NEW.id_pet || ';nome=' || :NEW.nome || ';especie=' || :NEW.especie || ';raca=' || :NEW.raca || ';peso=' || :NEW.peso || ';id_tutor=' || :NEW.id_tutor;
    ELSIF UPDATING THEN
        v_tipo_operacao := 'UPDATE';
        v_dados_antigos := 'id_pet=' || :OLD.id_pet || ';nome=' || :OLD.nome || ';especie=' || :OLD.especie || ';raca=' || :OLD.raca || ';peso=' || :OLD.peso || ';id_tutor=' || :OLD.id_tutor;
        v_dados_novos := 'id_pet=' || :NEW.id_pet || ';nome=' || :NEW.nome || ';especie=' || :NEW.especie || ';raca=' || :NEW.raca || ';peso=' || :NEW.peso || ';id_tutor=' || :NEW.id_tutor;
    ELSIF DELETING THEN
        v_tipo_operacao := 'DELETE';
        v_dados_antigos := 'id_pet=' || :OLD.id_pet || ';nome=' || :OLD.nome || ';especie=' || :OLD.especie || ';raca=' || :OLD.raca || ';peso=' || :OLD.peso || ';id_tutor=' || :OLD.id_tutor;
        v_dados_novos := NULL;
    END IF;
    PKG_AUDITORIA.PRC_GRAVA_AUDITORIA(USER, v_tipo_operacao, v_dados_antigos, v_dados_novos);
EXCEPTION
    WHEN OTHERS THEN
        PKG_LOG.PRC_INSERE_LOG('TRG_AUDITORIA_PET', SQLCODE, SQLERRM);
        RAISE;
END;
/

-- 11. CARGA DE DADOS VIA PACKAGE
DECLARE
    v_retorno VARCHAR2(300);
BEGIN
    -- TUTORES
    PKG_CADASTRO.PRC_INSERE_TUTOR('Ana Beatriz Oliveira', '11144477735', 'ana.oliveira@email.com', '(11) 98765-4321', TO_DATE('15/03/1985', 'DD/MM/YYYY'), 'Rua das Flores, 123 - Sao Paulo/SP', v_retorno);
    PKG_CADASTRO.PRC_INSERE_TUTOR('Carlos Eduardo Santos', '22255588846', 'carlos.santos@email.com', '(11) 97654-3210', TO_DATE('22/07/1990', 'DD/MM/YYYY'), 'Avenida Brasil, 456 - Rio de Janeiro/RJ', v_retorno);
    PKG_CADASTRO.PRC_INSERE_TUTOR('Mariana Fernandes Souza', '33366699957', 'mariana.souza@email.com', '(31) 98765-1234', TO_DATE('10/11/1982', 'DD/MM/YYYY'), 'Rua Bahia, 789 - Belo Horizonte/MG', v_retorno);
    PKG_CADASTRO.PRC_INSERE_TUTOR('Roberto Almeida Lima', '44477700083', 'roberto.lima@email.com', '(41) 99876-5432', TO_DATE('05/02/1995', 'DD/MM/YYYY'), 'Rua XV de Novembro, 1010 - Curitiba/PR', v_retorno);
    PKG_CADASTRO.PRC_INSERE_TUTOR('Fernanda Costa Rocha', '55588811194', 'fernanda.rocha@email.com', '(51) 97654-9876', TO_DATE('30/09/1988', 'DD/MM/YYYY'), 'Rua da Praia, 202 - Porto Alegre/RS', v_retorno);

    -- PETS
    PKG_CADASTRO.PRC_INSERE_PET('Rex', 'Cao', 'Pastor Alemao', TO_DATE('20/08/2019', 'DD/MM/YYYY'), 32.0, 'M', 'S', 1, v_retorno);
    PKG_CADASTRO.PRC_INSERE_PET('Luna', 'Cao', 'Golden Retriever', TO_DATE('15/03/2021', 'DD/MM/YYYY'), 22.0, 'F', 'N', 1, v_retorno);
    PKG_CADASTRO.PRC_INSERE_PET('Mia', 'Gato', 'Siames', TO_DATE('05/01/2022', 'DD/MM/YYYY'), 4.5, 'F', 'S', 2, v_retorno);
    PKG_CADASTRO.PRC_INSERE_PET('Nina', 'Roedor', 'Hamster', TO_DATE('10/02/2023', 'DD/MM/YYYY'), 0.08, 'F', 'N', 4, v_retorno);
    PKG_CADASTRO.PRC_INSERE_PET('Billy', 'Cao', 'SRD', TO_DATE('25/12/2018', 'DD/MM/YYYY'), 18.5, 'M', 'S', 5, v_retorno);
    PKG_CADASTRO.PRC_INSERE_PET('Jade', 'Reptil', 'Gecko', TO_DATE('03/07/2022', 'DD/MM/YYYY'), 0.05, 'F', 'N', 5, v_retorno);

    -- CLINICAS
    PKG_CADASTRO.PRC_INSERE_CLINICA('Hospital Veterinario PetSaude', '12345678000190', 'contato@petsaude.com.br', '(11) 3456-7890', 'Av. Paulista, 1000 - Sao Paulo/SP', v_retorno);
    PKG_CADASTRO.PRC_INSERE_CLINICA('Clinica Veterinaria BemEstar', '23456789000101', 'contato@bemestar.vet', '(21) 3456-7891', 'Rua do Carmo, 200 - Rio de Janeiro/RJ', v_retorno);
    PKG_CADASTRO.PRC_INSERE_CLINICA('Centro Veterinario Animal Feliz', '34567890000112', 'contato@animalfeliz.com', '(31) 3456-7892', 'Rua Paraiba, 500 - Belo Horizonte/MG', v_retorno);
    PKG_CADASTRO.PRC_INSERE_CLINICA('Clinica Veterinaria Vida Animal', '45678901000123', 'contato@vidaanimal.com.br', '(41) 3456-7893', 'Rua XV de Novembro, 1500 - Curitiba/PR', v_retorno);
    PKG_CADASTRO.PRC_INSERE_CLINICA('Hospital Veterinario PatasUnidas', '56789012000134', 'contato@patasunidas.vet', '(51) 3456-7894', 'Av. Ipiranga, 800 - Porto Alegre/RS', v_retorno);

    -- VETERINARIOS
    PKG_CADASTRO.PRC_INSERE_VETERINARIO('Dra. Beatriz Mendes', 'CRMV-SP 12345', 'Clinica Geral', 'beatriz.mendes@vet.com', '(11) 98765-1234', 1, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VETERINARIO('Dr. Ricardo Alves', 'CRMV-SP 12346', 'Cirurgia', 'ricardo.alves@vet.com', '(11) 98765-5678', 1, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VETERINARIO('Dra. Carla Souza', 'CRMV-RJ 54321', 'Dermatologia', 'carla.souza@vet.com', '(21) 98765-4321', 2, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VETERINARIO('Dr. Fernando Lima', 'CRMV-MG 67890', 'Ortopedia', 'fernando.lima@vet.com', '(31) 98765-6789', 3, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VETERINARIO('Dra. Patricia Rocha', 'CRMV-PR 11223', 'Oftalmologia', 'patricia.rocha@vet.com', '(41) 98765-1122', 4, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VETERINARIO('Dr. Marcos Andrade', 'CRMV-RS 33445', 'Cardiologia', 'marcos.andrade@vet.com', '(51) 98765-3344', 5, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VETERINARIO('Dra. Juliana Costa', 'CRMV-RS 33446', 'Clinica Geral', 'juliana.costa@vet.com', '(51) 98765-5566', 5, v_retorno);

    -- CONSULTAS
    PKG_CADASTRO.PRC_INSERE_CONSULTA(TO_TIMESTAMP('15/01/2024 10:30:00', 'DD/MM/YYYY HH24:MI:SS'), 'preventivo', 'concluida', 'Animal saudavel', 'Sem alteracoes', 'Manter rotina', 1, 1, v_retorno);
    PKG_CADASTRO.PRC_INSERE_CONSULTA(TO_TIMESTAMP('20/02/2024 14:15:00', 'DD/MM/YYYY HH24:MI:SS'), 'emergencia', 'concluida', 'Vomito e diarreia', 'Gastroenterite', 'Medicacao', 2, 2, v_retorno);
    PKG_CADASTRO.PRC_INSERE_CONSULTA(TO_TIMESTAMP('10/03/2024 09:00:00', 'DD/MM/YYYY HH24:MI:SS'), 'retorno', 'agendada', 'Pos-operatorio', 'Castracao', 'Repouso', 3, 3, v_retorno);
    PKG_CADASTRO.PRC_INSERE_CONSULTA(TO_TIMESTAMP('05/04/2024 11:45:00', 'DD/MM/YYYY HH24:MI:SS'), 'preventivo', 'concluida', 'Check-up', 'Saudavel', 'Nenhum', 4, 4, v_retorno);
    PKG_CADASTRO.PRC_INSERE_CONSULTA(TO_TIMESTAMP('18/05/2024 15:30:00', 'DD/MM/YYYY HH24:MI:SS'), 'continuidade', 'em andamento', 'Problema ocular', 'Conjuntivite', 'Colirio', 5, 5, v_retorno);
    PKG_CADASTRO.PRC_INSERE_CONSULTA(TO_TIMESTAMP('22/06/2024 08:20:00', 'DD/MM/YYYY HH24:MI:SS'), 'preventivo', 'concluida', 'Primeira consulta', 'Saudavel', 'Orientacoes', 6, 6, v_retorno);
    PKG_CADASTRO.PRC_INSERE_CONSULTA(TO_TIMESTAMP('01/07/2024 16:00:00', 'DD/MM/YYYY HH24:MI:SS'), 'emergencia', 'concluida', 'Corte na pata', 'Ferimento', 'Curativo', 1, 7, v_retorno);

    -- VACINAS
    PKG_CADASTRO.PRC_INSERE_VACINA('V8', TO_DATE('15/01/2024', 'DD/MM/YYYY'), TO_DATE('15/01/2025', 'DD/MM/YYYY'), 'Zoetis', 'L123ABC', 'Aplicacao anual', 1, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VACINA('V10', TO_DATE('20/02/2024', 'DD/MM/YYYY'), TO_DATE('20/02/2025', 'DD/MM/YYYY'), 'MSD', 'L456DEF', 'Aplicacao anual', 2, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VACINA('Antirrabica', TO_DATE('10/03/2024', 'DD/MM/YYYY'), TO_DATE('10/03/2025', 'DD/MM/YYYY'), 'Zoetis', 'L789GHI', 'Contra raiva', 3, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VACINA('Febre Aftosa', TO_DATE('05/04/2024', 'DD/MM/YYYY'), TO_DATE('05/04/2025', 'DD/MM/YYYY'), 'Boehringer', 'L012JKL', 'Anual', 4, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VACINA('V8', TO_DATE('18/05/2024', 'DD/MM/YYYY'), TO_DATE('18/05/2025', 'DD/MM/YYYY'), 'MSD', 'L345MNO', 'Anual', 5, v_retorno);
    PKG_CADASTRO.PRC_INSERE_VACINA('Reptil', TO_DATE('22/06/2024', 'DD/MM/YYYY'), TO_DATE('22/06/2025', 'DD/MM/YYYY'), 'VetBrand', 'L678PQR', 'Check-up', 6, v_retorno);

    -- MEDICAMENTOS
    PKG_CADASTRO.PRC_INSERE_MEDICAMENTO('Antibiotico', '1 comprimido', '12/12h', TO_DATE('15/01/2024', 'DD/MM/YYYY'), TO_DATE('25/01/2024', 'DD/MM/YYYY'), 'concluido', 'Infeccao', 1, 1, v_retorno);
    PKG_CADASTRO.PRC_INSERE_MEDICAMENTO('Anti-inflamatorio', '1 comprimido', '24/24h', TO_DATE('20/02/2024', 'DD/MM/YYYY'), TO_DATE('27/02/2024', 'DD/MM/YYYY'), 'concluido', 'Gastroenterite', 2, 2, v_retorno);
    PKG_CADASTRO.PRC_INSERE_MEDICAMENTO('Analgesico', '0.5 ml', '8/8h', TO_DATE('10/03/2024', 'DD/MM/YYYY'), TO_DATE('17/03/2024', 'DD/MM/YYYY'), 'concluido', 'Dor pos-op', 3, 3, v_retorno);
    PKG_CADASTRO.PRC_INSERE_MEDICAMENTO('Vitaminas', '2 gotas', '1x/dia', TO_DATE('05/04/2024', 'DD/MM/YYYY'), TO_DATE('05/05/2024', 'DD/MM/YYYY'), 'ativo', 'Suplementacao', 4, 4, v_retorno);
    PKG_CADASTRO.PRC_INSERE_MEDICAMENTO('Colirio', '2 gotas', '8/8h', TO_DATE('18/05/2024', 'DD/MM/YYYY'), TO_DATE('25/05/2024', 'DD/MM/YYYY'), 'ativo', 'Conjuntivite', 5, 5, v_retorno);
    PKG_CADASTRO.PRC_INSERE_MEDICAMENTO('Antiparasitario', '1 dose', 'Unica', TO_DATE('22/06/2024', 'DD/MM/YYYY'), NULL, 'concluido', 'Preventivo', 6, 6, v_retorno);

    -- EXAMES
    PKG_CADASTRO.PRC_INSERE_EXAME('Hemograma', TO_DATE('16/01/2024', 'DD/MM/YYYY'), 'Normal', NULL, 'Rotina', 1, 1, v_retorno);
    PKG_CADASTRO.PRC_INSERE_EXAME('Ultrassom', TO_DATE('21/02/2024', 'DD/MM/YYYY'), 'Gastrite', NULL, 'Confirmacao', 2, 2, v_retorno);
    PKG_CADASTRO.PRC_INSERE_EXAME('Raio-X', TO_DATE('11/03/2024', 'DD/MM/YYYY'), 'Cicatrizacao', NULL, 'Pos-op', 3, 3, v_retorno);
    PKG_CADASTRO.PRC_INSERE_EXAME('Check-up', TO_DATE('06/04/2024', 'DD/MM/YYYY'), 'Saudavel', NULL, 'Anual', 4, 4, v_retorno);
    PKG_CADASTRO.PRC_INSERE_EXAME('Teste Lacrimal', TO_DATE('19/05/2024', 'DD/MM/YYYY'), 'Reduzida', NULL, 'Conjuntivite', 5, 5, v_retorno);
    PKG_CADASTRO.PRC_INSERE_EXAME('Parasitologico', TO_DATE('23/06/2024', 'DD/MM/YYYY'), 'Negativo', NULL, 'Rotina', 6, 6, v_retorno);

    -- ALERTAS
    PKG_CADASTRO.PRC_INSERE_ALERTA('vacina proxima', 'V8 do Rex vence em 30 dias', TO_TIMESTAMP('15/12/2024 08:00:00', 'DD/MM/YYYY HH24:MI:SS'), 'N', NULL, 1, v_retorno);
    PKG_CADASTRO.PRC_INSERE_ALERTA('medicamento acabando', 'Antibiotico do Rex acabando', TO_TIMESTAMP('20/01/2024 10:00:00', 'DD/MM/YYYY HH24:MI:SS'), 'S', TO_TIMESTAMP('21/01/2024 14:30:00', 'DD/MM/YYYY HH24:MI:SS'), 1, v_retorno);
    PKG_CADASTRO.PRC_INSERE_ALERTA('retorno pendente', 'Luna tem retorno pendente', TO_TIMESTAMP('25/02/2024 09:00:00', 'DD/MM/YYYY HH24:MI:SS'), 'N', NULL, 2, v_retorno);
    PKG_CADASTRO.PRC_INSERE_ALERTA('check-up pendente', 'Mia com check-up pendente', TO_TIMESTAMP('01/04/2024 08:00:00', 'DD/MM/YYYY HH24:MI:SS'), 'N', NULL, 3, v_retorno);
    PKG_CADASTRO.PRC_INSERE_ALERTA('vacina proxima', 'Febre Aftosa da Nina vence em 15 dias', TO_TIMESTAMP('20/03/2025 09:00:00', 'DD/MM/YYYY HH24:MI:SS'), 'N', NULL, 4, v_retorno);
    PKG_CADASTRO.PRC_INSERE_ALERTA('medicamento acabando', 'Colirio do Billy acabando', TO_TIMESTAMP('22/05/2024 14:00:00', 'DD/MM/YYYY HH24:MI:SS'), 'N', NULL, 5, v_retorno);
    PKG_CADASTRO.PRC_INSERE_ALERTA('retorno pendente', 'Jade tem retorno pendente', TO_TIMESTAMP('30/06/2024 10:30:00', 'DD/MM/YYYY HH24:MI:SS'), 'N', NULL, 6, v_retorno);
    PKG_CADASTRO.PRC_INSERE_ALERTA('exame disponivel', 'Resultado do exame de Jade disponivel', TO_TIMESTAMP('25/06/2024 16:00:00', 'DD/MM/YYYY HH24:MI:SS'), 'N', NULL, 6, v_retorno);

    DBMS_OUTPUT.PUT_LINE('DADOS INSERIDOS COM SUCESSO!');
END;
/

-- 12. TESTES DAS FUNÇÕES E PROCEDIMENTOS
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- CPF nulo: ' || PKG_VALIDACAO.FUN_VALIDA_CPF(NULL));
    DBMS_OUTPUT.PUT_LINE('--- CPF tamanho invalido: ' || PKG_VALIDACAO.FUN_VALIDA_CPF('123'));
    DBMS_OUTPUT.PUT_LINE('--- CPF digito invalido: ' || PKG_VALIDACAO.FUN_VALIDA_CPF('11144477700'));
    DBMS_OUTPUT.PUT_LINE('--- CPF valido: ' || PKG_VALIDACAO.FUN_VALIDA_CPF('111.444.777-35'));
    IF PKG_VALIDACAO.FUN_VALIDA_NOME('Ana Beatriz') THEN DBMS_OUTPUT.PUT_LINE('--- Nome valido: TRUE'); ELSE DBMS_OUTPUT.PUT_LINE('--- Nome valido: FALSE'); END IF;
    IF PKG_VALIDACAO.FUN_VALIDA_NOME('Tutor123') THEN DBMS_OUTPUT.PUT_LINE('--- Nome com numero: TRUE'); ELSE DBMS_OUTPUT.PUT_LINE('--- Nome com numero: FALSE'); END IF;
END;
/

DECLARE
    v_json CLOB;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- JSON do pet 1 (primeiros 4000 chars) ---');
    v_json := PKG_JSON.FUN_MONTA_JSON_PET(1);
    DBMS_OUTPUT.PUT_LINE(DBMS_LOB.SUBSTR(v_json, 4000, 1));
    DBMS_OUTPUT.PUT_LINE('--- Tamanho do dataset JSON ---');
    v_json := PKG_JSON.FUN_MONTA_JSON_DATASET;
    DBMS_OUTPUT.PUT_LINE('Caracteres: ' || DBMS_LOB.GETLENGTH(v_json));
END;
/

DECLARE
    v_json CLOB;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- JSON pet inexistente ---');
    v_json := PKG_JSON.FUN_MONTA_JSON_PET(9999);
    DBMS_OUTPUT.PUT_LINE(DBMS_LOB.SUBSTR(v_json, 4000, 1));
END;
/

DECLARE
    v_retorno VARCHAR2(300);
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- CPF duplicado ---');
    PKG_CADASTRO.PRC_INSERE_TUTOR('Teste Duplicado', '11144477735', 'novo.teste@email.com', '(11) 90000-0000', SYSDATE, 'Endereco Teste', v_retorno);
    DBMS_OUTPUT.PUT_LINE(v_retorno);
END;
/

DECLARE
    v_retorno VARCHAR2(300);
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- CPF invalido ---');
    PKG_CADASTRO.PRC_INSERE_TUTOR('Teste CPF Invalido', '12345678900', 'teste.cpf@email.com', '(11) 90000-0001', SYSDATE, 'Endereco Teste', v_retorno);
    DBMS_OUTPUT.PUT_LINE(v_retorno);
END;
/

DECLARE
    v_retorno VARCHAR2(300);
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Nome invalido ---');
    PKG_CADASTRO.PRC_INSERE_TUTOR('Tutor123', '65432198712', 'teste.nome@email.com', '(11) 90000-0002', SYSDATE, 'Endereco Teste', v_retorno);
    DBMS_OUTPUT.PUT_LINE(v_retorno);
END;
/

DECLARE
    v_retorno VARCHAR2(300);
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- PET com tutor inexistente ---');
    PKG_CADASTRO.PRC_INSERE_PET('Rocky', 'Cao', 'SRD', SYSDATE, 15.0, 'M', 'N', 9999, v_retorno);
    DBMS_OUTPUT.PUT_LINE(v_retorno);
END;
/

EXEC PKG_RELATORIOS.PRC_RELATORIO_JSON_PET_TUTOR;
EXEC PKG_RELATORIOS.PRC_RELATORIO_PESO_POR_ESPECIE;

DECLARE
    v_id_toby PET.id_pet%TYPE;
BEGIN
    v_id_toby := SEQ_ID_PET.NEXTVAL;
    INSERT INTO PET (id_pet, nome, especie, raca, data_nascimento, peso, sexo, castrado, id_tutor)
    VALUES (v_id_toby, 'Toby', 'Cao', 'Beagle', TO_DATE('01/01/2023', 'DD/MM/YYYY'), 12.0, 'M', 'N', 3);
    UPDATE PET SET peso = 12.8 WHERE id_pet = v_id_toby;
    DELETE FROM PET WHERE id_pet = v_id_toby;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Demonstracao da trigger concluida.');
END;
/

COLUMN nome_usuario FORMAT A12
COLUMN tipo_operacao FORMAT A10
COLUMN data_hora FORMAT A19
COLUMN dados_anteriores FORMAT A45 WORD_WRAPPED
COLUMN dados_novos FORMAT A45 WORD_WRAPPED
SELECT id_auditoria, nome_usuario, tipo_operacao,
       TO_CHAR(data_hora, 'DD/MM/YYYY HH24:MI:SS') AS data_hora,
       dados_anteriores, dados_novos
FROM TB_AUDITORIA
ORDER BY id_auditoria;
CLEAR COLUMNS;

COLUMN nome_procedure FORMAT A35
COLUMN usuario FORMAT A12
COLUMN data_erro FORMAT A19
COLUMN mensagem_erro FORMAT A50 WORD_WRAPPED
SELECT nome_procedure, usuario, TO_CHAR(data_erro, 'DD/MM/YYYY HH24:MI:SS') AS data_erro, codigo_erro, mensagem_erro
FROM ERRO_LOG
ORDER BY id_log;
CLEAR COLUMNS;