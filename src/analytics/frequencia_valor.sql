
with tb_freq_valor as (

    SELECT      idCliente,
                COUNT(DISTINCT SUBSTR(DtCriacao,0,11)) AS QtdFrequencia,
                SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) As QtdePontos


    FROM transacoes

    WHERE DtCriacao < '2025-09-01'
    AND DtCriacao > date('2025-09-01', '-28 day')

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

SELECT *


FROM tb_cluster

