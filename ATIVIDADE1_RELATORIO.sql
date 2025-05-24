CREATE DATABASE Fabrica;
GO

USE Fabrica;
GO

-- CRIAÇÃO DAS TABELAS

CREATE TABLE Empregado (
	EmpCodigo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	EmpNome VARCHAR(200) NOT NULL,
	EmpTelefone VARCHAR(15) NOT NULL,
	EmpEmail VARCHAR(100) NOT NULL,
	EmpCpf VARCHAR(11) NOT NULL,
	EmpDataNascimento DATETIME NOT NULL
);

CREATE TABLE Produto (
	ProCodigo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ProNome VARCHAR(200) NOT NULL,
	ProCodigoBarras VARCHAR(20) NOT NULL
);

CREATE TABLE Producao (
	ProducaoID INT IDENTITY(1,1) PRIMARY KEY,
	EmpCodigoEmpregado INT,
	DataProducao DATE NOT NULL,
	Quantidade INT NOT NULL,
	FOREIGN KEY (EmpCodigoEmpregado) REFERENCES Empregado(EmpCodigo)
);

CREATE TABLE ProducaoProduto (
	CodigoProduto INT,
	CodigoProducao INT,
	FOREIGN KEY (CodigoProduto) REFERENCES Produto(ProCodigo),
	FOREIGN KEY (CodigoProducao) REFERENCES Producao(ProducaoID)
);

-- DADOS - Empregados
INSERT INTO Empregado (EmpNome, EmpTelefone, EmpEmail, EmpCpf, EmpDataNascimento)
VALUES 
('Maria Eduarda', '11987456215', 'maria@gmail.com', '12943269562', CONVERT(DATETIME, '24/02/2005', 103)),
('Yan Almeida S', '11987536425', 'yan@email.com', '13694558452', CONVERT(DATETIME, '05/05/2006', 103));

-- DADOS - Produtos
INSERT INTO Produto (ProNome, ProCodigoBarras)
VALUES 
('Blusa Amarela', '000123456'),
('Calça Azul', '0000654321');

-- DADOS - Produção
INSERT INTO Producao (EmpCodigoEmpregado, DataProducao, Quantidade)
VALUES 
-- Maria (IDs 1 a 12)
(1, '2025-01-20', 50), 
(1, '2025-02-03', 16),
(1, '2025-03-10', 60),
(1, '2025-04-03', 5),
(1, '2025-05-03', 3),
(1, '2025-06-03', 10),
(1, '2025-07-03', 18),
(1, '2025-08-03', 12),
(1, '2025-09-03', 13),
(1, '2025-10-03', 17),
(1, '2025-11-03', 5),
(1, '2025-12-03', 8),
-- Yan (IDs 13 a 24)
(2, '2025-01-03', 16),
(2, '2025-02-03', 18),
(2, '2025-03-03', 50),
(2, '2025-04-03', 81),
(2, '2025-05-03', 6),
(2, '2025-06-03', 5),
(2, '2025-07-03', 32),
(2, '2025-08-03', 41),
(2, '2025-09-03', 7),
(2, '2025-10-03', 16),
(2, '2025-11-03', 18),
(2, '2025-12-18', 51);

-- DADOS - ProducaoProduto
INSERT INTO ProducaoProduto (CodigoProduto, CodigoProducao)
VALUES
-- Produções de blusa amarela feitas por Maria (ProducaoID 1 a 12)
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11),
(1, 12),
-- Produções de calça azul feitas por Yan (ProducaoID 13 a 24)
(2, 13),
(2, 14),
(2, 15),
(2, 16),
(2, 17),
(2, 18),
(2, 19),
(2, 20),
(2, 21),
(2, 22),
(2, 23),
(2, 24);

-- CONSULTAS DE VERIFICAÇÃO
SELECT * FROM Empregado;
SELECT * FROM Produto;
SELECT * FROM Producao;
SELECT * FROM ProducaoProduto;

-- CRIAÇÃO DA FUNÇÃO DE RELATÓRIO
GO
CREATE FUNCTION fnRelatorioEmpregado (@Ano INT)
RETURNS TABLE
AS
RETURN(
	SELECT 
		E.EmpNome,
		YEAR(P.DataProducao) AS Ano,
		SUM(CASE WHEN MONTH(P.DataProducao) = 1 THEN P.Quantidade ELSE 0 END) AS Janeiro,
		SUM(CASE WHEN MONTH(P.DataProducao) = 2 THEN P.Quantidade ELSE 0 END) AS Fevereiro,
		SUM(CASE WHEN MONTH(P.DataProducao) = 3 THEN P.Quantidade ELSE 0 END) AS Marco,
		SUM(CASE WHEN MONTH(P.DataProducao) = 4 THEN P.Quantidade ELSE 0 END) AS Abril,
		SUM(CASE WHEN MONTH(P.DataProducao) = 5 THEN P.Quantidade ELSE 0 END) AS Maio,
		SUM(CASE WHEN MONTH(P.DataProducao) = 6 THEN P.Quantidade ELSE 0 END) AS Junho,
		SUM(CASE WHEN MONTH(P.DataProducao) = 7 THEN P.Quantidade ELSE 0 END) AS Julho,
		SUM(CASE WHEN MONTH(P.DataProducao) = 8 THEN P.Quantidade ELSE 0 END) AS Agosto,
		SUM(CASE WHEN MONTH(P.DataProducao) = 9 THEN P.Quantidade ELSE 0 END) AS Setembro,
		SUM(CASE WHEN MONTH(P.DataProducao) = 10 THEN P.Quantidade ELSE 0 END) AS Outubro,
		SUM(CASE WHEN MONTH(P.DataProducao) = 11 THEN P.Quantidade ELSE 0 END) AS Novembro,
		SUM(CASE WHEN MONTH(P.DataProducao) = 12 THEN P.Quantidade ELSE 0 END) AS Dezembro,
		SUM(P.Quantidade) AS Total
	FROM Producao P
	INNER JOIN Empregado E ON P.EmpCodigoEmpregado = E.EmpCodigo
	WHERE YEAR(P.DataProducao) = @Ano
	GROUP BY E.EmpNome, YEAR(P.DataProducao)
);
GO

-- USANDO A FUNÇÃO PARA GERAR RELATÓRIO DE 2025
SELECT * FROM fnRelatorioEmpregado(2025);
