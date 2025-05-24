CREATE DATABASE Sorveteria;
GO

USE Sorveteria;
GO

-- Criação das tabelas
CREATE TABLE Funcionario (
	EmpCodigo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	EmpNome VARCHAR(200) NOT NULL,
	EmpTelefone VARCHAR(15) NOT NULL,
	EmpCpf VARCHAR(11) NOT NULL,
	EmpDataNascimento DATETIME NOT NULL
);
GO

CREATE TABLE Sorvete (
	ProCodigo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ProSabor VARCHAR(200) NOT NULL,
	ProCodigoBarras VARCHAR(20) NOT NULL
);
GO

CREATE TABLE Producao_S (
	ProducaoID INT IDENTITY(1,1) PRIMARY KEY,
	EmpCodigoFuncionario INT,
	DataProducao DATE NOT NULL,
	Quantidade INT NOT NULL,
	FOREIGN KEY (EmpCodigoFuncionario) REFERENCES Funcionario(EmpCodigo)
);
GO

CREATE TABLE ProducaoProduto(
	CodigoSorvete INT,
	CodigoProducao_S INT,
	FOREIGN KEY (CodigoSorvete) REFERENCES Sorvete(ProCodigo),
	FOREIGN KEY (CodigoProducao_S) REFERENCES Producao_S(ProducaoID)
);
GO

-- Inserção de funcionários
INSERT INTO Funcionario(EmpNome, EmpTelefone, EmpCpf, EmpDataNascimento)
VALUES 
('Sasha Souza', '11981345678', '12345678909', CONVERT(DATETIME, '18/06/2003', 103)),
('Carlos Silva', '21998764321', '98465432100' , CONVERT(DATETIME, '13/02/2001', 103));
GO

-- Inserção de sorvetes
INSERT INTO Sorvete(ProSabor, ProCodigoBarras)
VALUES 
('Morango', '000123'),
('Chocolate', '000789');
GO

-- Inserção de produção (use os IDs corretos dos funcionários e sorvetes se necessário)
INSERT INTO Producao_S (EmpCodigoFuncionario, DataProducao, Quantidade)
VALUES 
-- Sasha
(1, '2025-01-20', 15), 
(1, '2025-02-03', 16),
(1, '2025-03-10', 17),
(1, '2025-04-03', 5),
(1, '2025-05-03', 3),
(1, '2025-06-03', 11),
(1, '2025-07-03', 15),
(1, '2025-08-03', 14),
(1, '2025-09-03', 19),
(1, '2025-10-03', 13),
(1, '2025-11-03', 2),
(1, '2025-12-03', 7),
-- Carlos
(2, '2025-01-03', 4),
(2, '2025-02-03', 8),
(2, '2025-03-03', 5),
(2, '2025-04-03', 10),
(2, '2025-05-03', 20),
(2, '2025-06-03', 18),
(2, '2025-07-03', 6),
(2, '2025-08-03', 16),
(2, '2025-09-03', 12),
(2, '2025-10-03', 7),
(2, '2025-11-03', 25),
(2, '2025-12-18', 3);
GO

-- Relacionamento com sorvetes
-- Você pode ajustar os IDs abaixo para os IDs reais das tabelas se forem diferentes
INSERT INTO ProducaoProduto (CodigoSorvete, CodigoProducao_S)
VALUES
-- Morango, Sasha (SorveteID = 1)
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6),
(1, 7), (1, 8), (1, 9), (1, 10), (1, 11), (1, 12),
-- Chocolate, Carlos (SorveteID = 2)
(2, 13), (2, 14), (2, 15), (2, 16), (2, 17), (2, 18),
(2, 19), (2, 20), (2, 21), (2, 22), (2, 23), (2, 24);
GO

-- Criação da tabela de relatório
CREATE TABLE RelatorioMensalSorvete (
	ProCodigo INT,
	Ano INT,
	Janeiro INT,
	Fevereiro INT,
	Marco INT,
	Abril INT,
	Maio INT,
	Junho INT,
	Julho INT,
	Agosto INT,
	Setembro INT,
	Outubro INT,
	Novembro INT,
	Dezembro INT,
	Total INT,
	PRIMARY KEY (ProCodigo, Ano),
	FOREIGN KEY (ProCodigo) REFERENCES Sorvete(ProCodigo)
);
GO

-- Criação da função (ISOLADA)
GO
CREATE FUNCTION fnQuantidadesPorMes (
	@ProCodigo INT,
	@Ano INT
)
RETURNS TABLE
AS
RETURN (
	SELECT 
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
	FROM Producao_S P
	JOIN ProducaoProduto PP ON P.ProducaoID = PP.CodigoProducao_S
	WHERE PP.CodigoSorvete = @ProCodigo AND YEAR(P.DataProducao) = @Ano
);
GO

-- Criação da stored procedure (ISOLADA)
GO
CREATE PROCEDURE spGerarRelatorioProduto
	@ProCodigo INT,
	@Ano INT
AS
BEGIN
	IF EXISTS (
		SELECT 1 FROM RelatorioMensalSorvete 
		WHERE ProCodigo = @ProCodigo AND Ano = @Ano
	)
	BEGIN
		PRINT 'Esse relatório já existe. Não será executado.';
		RETURN;
	END

	INSERT INTO RelatorioMensalSorvete (
		ProCodigo, Ano, Janeiro, Fevereiro, Marco, Abril, Maio, Junho,
		Julho, Agosto, Setembro, Outubro, Novembro, Dezembro, Total
	)
	SELECT 
		@ProCodigo, 
		@Ano, 
		Janeiro, Fevereiro, Marco, Abril, Maio, Junho,
		Julho, Agosto, Setembro, Outubro, Novembro, Dezembro, Total
	FROM fnQuantidadesPorMes(@ProCodigo, @Ano);
	
	PRINT 'Relatório gerado com sucesso!';
END;
GO

-- Execução da procedure
EXEC spGerarRelatorioProduto @ProCodigo = 1, @Ano = 2025;
EXEC spGerarRelatorioProduto @ProCodigo = 2, @Ano = 2025;
GO

-- Resultado
SELECT * FROM RelatorioMensalSorvete;
