CREATE PROCEDURE dbo.salaryHistogram @numIntervalos INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Declaração de variáveis para os limites
    DECLARE @minSal NUMERIC(10,2); -- 8 inteiros e 2 decimais
    DECLARE @maxSal NUMERIC(10,2);
    DECLARE @amplitude NUMERIC(10,2); -- guarda o tamanho de cada faixa
    
    -- 2. Declaração da Tabela Temporária para armazenar o histograma
    DECLARE @HistogramaTable TABLE (
        valorMinimo INT,
        valorMaximo INT,
        total INT
    );

    -- 3. Buscar os valores globais na tabela instructor
    SELECT @minSal = MIN(salary), @maxSal = MAX(salary) 
    FROM dbo.instructor;

    -- 4. Calcular o tamanho de cada intervalo
    SET @amplitude = (@maxSal - @minSal) / @numIntervalos;

    -- 5. Loop para construir as faixas e contar os instrutores
    DECLARE @i INT = 0; -- contador que começa em 0
    DECLARE @vMinAtual INT; -- Cria um espaço na memória pra guardar o v inicial de cada faixa salarial
    DECLARE @vMaxAtual INT; -- '' valor final

    WHILE @i < @numIntervalos -- Roda enquanto contador @i for menor que @numIntervalos
    BEGIN -- Começo das instruções que serão repetidas
        -- Cálculo dos limites da faixa atual
        SET @vMinAtual = CAST(@minSal + (@i * @amplitude) AS INT); -- Defina (SET) o valor mínimo atual (@vMinAtual) como: pegue o salário inicial, adicione o número de 'pulos' (@i * @amplitude) que já demos e converta o resultado final para um número inteiro (INT).
        SET @vMaxAtual = CAST(@minSal + ((@i + 1) * @amplitude) AS INT); -- '' (@vMaxAtual) como: pegue o salário inicial, adicione o próximo 'pulo' (por isso o +1) e converta o resultado final para um número inteiro.
        
        -- Ajuste para não sobrepor valores (conforme o print)
        IF @i > 0 SET @vMinAtual = @vMinAtual + 1; -- Soma 1 real pra não sobrepor se não for a primeira vez que esse loop roda

        -- Inserir na tabela de resultados contando quantos instrutores caem aqui
        INSERT INTO @HistogramaTable (valorMinimo, valorMaximo, total) -- Prepara tabela na memória pra receber os dados recém calculados
        SELECT @vMinAtual, @vMaxAtual, COUNT(*) -- Pega os limites da fatia atual e conta quantos registros existem dentro desse espaço.
        FROM dbo.instructor -- Indica onde a contagem deve se feita
        WHERE salary BETWEEN @vMinAtual AND @vMaxAtual; -- Filtra salário entre (between) min e max

        SET @i = @i + 1; -- Soma 1 ao contador @i pra que o código entenda que deve passar para a próxima faixa 
    END -- Marca o fim do bloco de repetição

    -- 6. Exibir o resultado final ordenado
    SELECT * FROM @HistogramaTable ORDER BY valorMinimo; -- Resultados do min para o max
END;
GO

-- Execução
EXEC dbo.salaryHistogram 5;