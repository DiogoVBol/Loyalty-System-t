

WITH tb_transacao AS (

    SELECT  *, substr(DtCriacao,0,11) AS dtDia, CAST(substr(DtCriacao,12,2) AS INT) AS dtHora

    FROM transacoes

    WHERE DtCriacao < '{date}'

), 

tb_agg_transacao AS (

    SELECT  idCliente, 

            MAX(julianday('{date}') - julianday(DtCriacao)) AS idadeDias,

            -- Quantidade de dias que teve alguma ação
            COUNT(DISTINCT dtDia) AS qtdeAtivacaoVida,
            COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-7 day') THEN dtDia END) AS qtdeAtivacaoD7,
            COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-14 day') THEN dtDia END) AS qtdeAtivacaoD14,
            COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-28 day') THEN dtDia END) AS qtdeAtivacaoD28,
            COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-56 day') THEN dtDia END) AS qtdeAtivacaoD56,
            
            -- Quantidade de transações
            COUNT(DISTINCT IdTransacao) AS qtdeTransacaoVida,
            COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-7 day') THEN IdTransacao END) AS qtdeTransacaoD7,
            COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-14 day') THEN IdTransacao END) AS qtdeTransacaoD14,
            COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-28 day') THEN IdTransacao END) AS qtdeTransacaoD28,
            COUNT(DISTINCT CASE WHEN dtDia >= date('{date}', '-56 day') THEN IdTransacao END) AS qtdeTransacaoD56,

            -- Valor dos pontos (Saldo)
            SUM(QtdePontos) AS saldoVida,
            SUM(CASE WHEN dtDia >= date('{date}', '-7 day') THEN QtdePontos ELSE 0 END) AS saldoD7,
            SUM(CASE WHEN dtDia >= date('{date}', '-14 day') THEN QtdePontos ELSE 0 END) AS saldoD14,
            SUM(CASE WHEN dtDia >= date('{date}', '-28 day') THEN QtdePontos ELSE 0 END) AS saldoD28,
            SUM(CASE WHEN dtDia >= date('{date}', '-56 day') THEN QtdePontos ELSE 0 END) AS saldoD56,
            -- Valor dos pontos (Negativo)
            SUM(CASE WHEN QtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,
            SUM(CASE WHEN dtDia >= date('{date}', '-7 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS qtdePontosNegD7,
            SUM(CASE WHEN dtDia >= date('{date}', '-14 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS qtdePontosNegD14,
            SUM(CASE WHEN dtDia >= date('{date}', '-28 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS qtdePontosNegD28,
            SUM(CASE WHEN dtDia >= date('{date}', '-56 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS qtdePontosNegD56,
            -- Valor dos pontos (Positivos)
            SUM(CASE WHEN QtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
            SUM(CASE WHEN dtDia >= date('{date}', '-7 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPosD7,
            SUM(CASE WHEN dtDia >= date('{date}', '-14 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPosD14,
            SUM(CASE WHEN dtDia >= date('{date}', '-28 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPosD28,
            SUM(CASE WHEN dtDia >= date('{date}', '-56 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPosD56,

            COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) AS qtdeTransacaoManha,
            COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) AS qtdeTransacaoTarde,
            COUNT(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END) AS qtdeTransacaoNoite,

            1.0 * COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END)/ COUNT(IdTransacao) AS pctTransacaoManha,
            1.0 * COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END)/ COUNT(IdTransacao) AS pctTransacaoTarde,
            1.0 * COUNT(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END)/ COUNT(IdTransacao) AS pctTransacaoNoite


    FROM tb_transacao

    GROUP BY IdCliente

), 

tb_agg_calc AS (

    SELECT  *,

            -- Quantidade de transações por dia
            COALESCE(1.0 * qtdeTransacaoVida / qtdeAtivacaoVida,0) AS QtdeTransacoesDiaVida,
            COALESCE(1.0 * qtdeTransacaoD7 / qtdeAtivacaoD7,0) AS QtdeTransacoesDiaD7,
            COALESCE(1.0 * qtdeTransacaoD14 / qtdeAtivacaoD14,0) AS QtdeTransacoesDiaD14,
            COALESCE(1.0 * qtdeTransacaoD28 / qtdeAtivacaoD28,0) AS QtdeTransacoesDiaD28,
            COALESCE(1.0 * qtdeTransacaoD56 / qtdeAtivacaoD56,0) AS QtdeTransacoesDiaD56,

            -- Percentual de ativação do MAU
            COALESCE(1.0 * qtdeAtivacaoD28 / 28,0) AS pctAtivacaoMAU


    FROM tb_agg_transacao

), 

tb_horas_dias AS (

    SELECT idCliente,
        dtDia,
        24 * (MAX(julianday(dtCriacao)) - MIN(julianday(dtCriacao))) AS duracao


    FROM tb_transacao

    GROUP BY idCliente, dtDia

),

tb_hora_cliente AS (

    SELECT  IdCliente,
            -- Horas assistidas (D7, D14, D28, D56)
            sum(duracao) AS qtdeHorasVida,
            SUM(CASE WHEN dtDia >= date('{date}', '-7 day') THEN duracao ELSE 0 END) qtdeHorasD7,
            SUM(CASE WHEN dtDia >= date('{date}', '-14 day') THEN duracao ELSE 0 END) qtdeHorasD14,
            SUM(CASE WHEN dtDia >= date('{date}', '-28 day') THEN duracao ELSE 0 END) qtdeHorasD28,
            SUM(CASE WHEN dtDia >= date('{date}', '-56 day') THEN duracao ELSE 0 END) qtdeHorasD56

    FROM tb_horas_dias

    GROUP BY idCliente

),

tb_lag_dia AS (

    SELECT  IdCliente,
            dtDia,
            LAG(dtDia, 1) OVER (PARTITION BY idCliente ORDER BY dtDia) as lagDia


    FROM tb_horas_dias

),

tb_intervalo AS (

    SELECT idCliente, 
        -- Média entre os dias de ativação (Tem que ser NULL pois se for 0 significa que o cara volta sempre!)
        -- No modelo iremos colocar o limite maximo que encontrar na base (o cara n voltou até tal dia)
        avg(julianday(dtDia) - julianday(lagDia)) AS avgIntervaloDiasVida,
        avg(CASE WHEN dtDia >= date('{date}', '-28 day') THEN julianday(dtDia) - julianday(lagDia) END) AS avgIntervaloDiasD28
        

    FROM tb_lag_dia
    
    GROUP BY idCliente

),

tb_share_produtos AS (

    SELECT idCliente,

    1.0 *COUNT(CASE WHEN DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeChatMessage,
    1.0 *COUNT(CASE WHEN DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeAirflowLover,
    1.0 *COUNT(CASE WHEN DescNomeProduto = 'R Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeRLover,
    1.0 *COUNT(CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeResgatarPonei,
    1.0 *COUNT(CASE WHEN DescNomeProduto = 'Lista de presença' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeListadePresenca,
    1.0 *COUNT(CASE WHEN DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdePresencaStreak,
    1.0 *COUNT(CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeTrocaStreamElements,
    1.0 *COUNT(CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeReembolsoStreamElements,
    1.0 *COUNT(CASE WHEN DescCategoriaProduto = 'rpg' THEN T1.IdTransacao END) / count(t1.IdTransacao) AS qtdeRPG,
    1.0 *COUNT(CASE WHEN DescCategoriaProduto = 'churn_model' THEN T1.IdTransacao END) / count(t1.IdTransacao) AS qtdeChurnModel
            


    FROM tb_transacao AS T1
    LEFT JOIN transacao_produto AS T2
    ON T1.IdTransacao = T2.IdTransacao

    LEFT JOIN produtos AS T3
    ON T2.IdProduto = t3.IdProduto

    GROUP BY idCliente
) ,

tb_join AS (

    SELECT  t1.*,
            t2.qtdeHorasVida,
            t2.qtdeHorasD7,
            t2.qtdeHorasD14,
            t2.qtdeHorasD28,
            t2.qtdeHorasD56,
            t3.avgIntervaloDiasVida,
            t3.avgIntervaloDiasD28,
            qtdeChatMessage,
            T4.qtdeAirflowLover,
            T4.qtdeRLover,
            T4.qtdeResgatarPonei,
            T4.qtdeListadePresenca,
            T4.qtdePresencaStreak,
            T4.qtdeTrocaStreamElements,
            T4.qtdeReembolsoStreamElements,
            T4.qtdeRPG,
            T4.qtdeChurnModel

    FROM tb_agg_calc AS t1
    LEFT JOIN tb_hora_cliente AS t2
    ON T1.IdCliente = T2.IdCliente
    LEFT JOIN tb_intervalo AS T3
    ON T1.IdCliente = T3.IdCliente
    LEFT JOIN tb_share_produtos AS T4
    ON t4.idCliente = t1.idCliente
)

SELECT date('{date}', '-1 DAY') as dtRef, * 

FROM tb_join