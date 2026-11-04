# ClyvoVet - Sprint 4

Projeto desenvolvido para a Sprint 4 da disciplina **Mastering Relational and Non-Relational Database** (FIAP - 2TDSPW).

## 📌 Sobre o Projeto
O ClyvoVet é uma plataforma voltada para o gerenciamento do histórico de saúde de animais de estimação. Esta sprint consolidou a integração entre bancos de dados relacionais (Oracle) e não relacionais (MongoDB), além do desenvolvimento de uma API backend em C# (.NET) para conectar a aplicação ao banco de dados.

## 👥 Integrantes
* Gustavo Barrios de Araújo - RM563358
* Matheus Almeida Ribeiro - RM562980
* Phietro Solon Oliveira - RM563842

## 🛠️ Tecnologias Utilizadas
* **Banco Relacional:** Oracle Database (PL/SQL), com empacotamento de rotinas em 6 *Packages* (PKG_VALIDACAO, PKG_LOG, PKG_CADASTRO, PKG_JSON, PKG_RELATORIOS, PKG_AUDITORIA).
* **Banco NoSQL:** MongoDB (modelagem híbrida com *embedding* para Pets e *referencing* para Clínicas e Veterinários).
* **Backend:** C# / .NET Web API, utilizando ADO.NET (`Oracle.ManagedDataAccess.Core`), sem Entity Framework.
* **Documentação:** Arquivo PDF com modelagem, prints de execução e explicações.

## 📂 Estrutura do Repositório
* `database/`: Contém o script SQL completo do Oracle, os arquivos JSON exportados e o script de importação/consultas do MongoDB.
* `ClyvoVet.Db.Api/`: Código-fonte da API em C#.
* `docs/`: Documentação técnica final em PDF (`2TDSPW_2026_Proj_BD.pdf`).

## 🚀 Como Executar

### 1. Banco Relacional (Oracle)
1. Abra o Oracle SQL Developer.
2. Execute o script `database/2TDSPW_2026_CodigoSql_Integrantes.sql`.

### 2. Banco NoSQL (MongoDB)
1. Importe os arquivos JSON (`Dataset`, `Clinicas`, `Veterinarios`) para o MongoDB Compass.
2. Execute as consultas de agregação presentes no arquivo `database/2TDSPW_2026_Mongo.js`.

### 3. API Backend (C#)
1. Navegue até a pasta `ClyvoVet.Db.Api`.
2. Renomeie o arquivo `appsettings.Example.json` para `appsettings.json` e insira suas credenciais do Oracle (RM e senha).
3. No terminal, execute: `dotnet run`
4. Acesse o Swagger no navegador (ex: `http://localhost:5261/swagger`) para testar os endpoints.

## 🎥 Vídeo Demonstrativo
https://youtu.be/z2-HYtXBvJs
