-- fiel = recencia <7 e recencia anterior < 15
-- turista =  7 <= recencia <= 14
-- desencantado = recencia <= 28
-- zumbi = recencia >= 28
-- reconquistado = recencia < 7 e 14 <= recencia anterior <= 28
-- Reborn = recencia < 7 e recencia anterior > 28
-- curiosa = idade < 7



WITH tb_daily AS (

    SELECT  DISTINCT

            IdCliente,
            substr(DtCriacao,0,11) as dtDia

    FROM transacoes

    WHERE DtCriacao < '{date}'
),

tb_idade AS (

    SELECT  IdCliente,
            MIN(dtDia) AS dtPrimeiraTransacao,
            CAST(max(julianday('{date}') - julianday(dtDia))AS INT) AS qtdeDiasPrimeiraTransacao,
            MAX(dtDia) AS dtUltimaTrasacao,
            CAST(min(julianday('{date}') - julianday(dtDia))AS INT) AS qtdeDiasUltimaTransacao

    FROM tb_daily

    GROUP BY idCliente
), 

tb_rn as (

    SELECT *,
            row_number() over (PARTITION BY idCliente ORDER BY dtDia DESC) as rnDia

    FROM tb_daily
), 

tb_penultima_ativacao as (

    SELECT *, 
    CAST(julianday('{date}') - julianday(dtDia) AS INT) as qtdeDiasPenultimaTransacao

    FROM tb_rn

    WHERE rnDia = 2
), 

tb_lifecycle AS (

    SELECT  T1.IdCliente,
            --T1.dtPrimeiraTransacao,
            T1.qtdeDiasPrimeiraTransacao,
            --T1.dtUltimaTrasacao,
            T1.qtdeDiasUltimaTransacao,
            T2.dtDia as dtDiaPenultimaTransacao,
            T2.qtdeDiasPenultimaTransacao,
            CASE
                WHEN qtdeDiasPrimeiraTransacao <= 7 THEN '01-CURIOSO'
                WHEN qtdeDiasUltimaTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltimaTransacao <= 14  THEN '02-FIEL'
                WHEN qtdeDiasUltimaTransacao BETWEEN 8 AND 14 THEN '03-TURISTA'
                WHEN qtdeDiasUltimaTransacao BETWEEN 15 AND 28 THEN '04-DESENCANTADA'
                WHEN qtdeDiasUltimaTransacao > 28 THEN '05-ZUMBI'
                WHEN qtdeDiasUltimaTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltimaTransacao BETWEEN 15 AND 28 THEN '02-RECONQUISTADO'
                WHEN qtdeDiasUltimaTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltimaTransacao > 28 THEN '02-REBORN'

            END AS descLifeCycle


    FROM tb_idade AS T1
    LEFT JOIN  tb_penultima_ativacao AS T2
    ON T1.IdCliente = T2.IdCliente

),

tb_freq_valor as (

    SELECT      idCliente,
                COUNT(DISTINCT SUBSTR(DtCriacao,0,11)) AS QtdFrequencia,
                SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) As QtdePontos


    FROM transacoes

    WHERE DtCriacao < '{date}'
    AND DtCriacao > date('{date}', '-28 day')

    GROUP BY IdCliente

    ORDER BY QtdFrequencia desc
),

tb_cluster AS (
    SELECT *,

            CASE WHEN QtdFrequencia <= 10 AND QtdePontos >= 1500 THEN '12-HYPER'
                WHEN QtdFrequencia > 10 AND QtdePontos >= 1500 THEN '22-EFICIENTE'
                WHEN QtdFrequencia <= 10 AND QtdePontos >= 750 THEN '11-INDECISO'
                WHEN QtdFrequencia > 10 AND QtdePontos >= 750 THEN '21-ESFORÇADO'
                WHEN QtdFrequencia < 5 THEN '00-LUKER'
                WHEN QtdFrequencia <= 10 THEN '01-PREGUIÇOSO'
                WHEN QtdFrequencia > 10 THEN '20-POTENCIAL'
            END AS Cluster

    FROM tb_freq_valor
)


SELECT date('{date}', '-1 day') as dtRef,
t1.*, t2.QtdFrequencia, t2.QtdePontos, t2.cluster

FROM tb_lifecycle AS t1

LEFT JOIN tb_cluster AS t2
ON t1.idCliente = t2.idCliente


