WITH tb_life_cycle_atual AS (

    SELECT  IdCliente,
            QtdFrequencia,
            descLifeCycle as descLifeCycleAtual

    FROM life_cycle

    WHERE dtRef = date('{date}', '-1 day')
),

tb_life_cycle_d28 AS (


SELECT  IdCliente, 
        descLifeCycle as descLifeCycleD38

FROM life_cycle

WHERE dtRef = date('{date}', '-29 day')

),tb_share_ciclos AS (

SELECT  IdCliente, 

        1.0 * SUM(CASE WHEN descLifeCycle = '01-CURIOSO' THEN 1 ELSE 0 END) / COUNT(*) AS pctCurioso,
        1.0 * SUM(CASE WHEN descLifeCycle = '02-FIEL' THEN 1 ELSE 0 END) / COUNT(*) AS pctFiel,
        1.0 * SUM(CASE WHEN descLifeCycle = '03-TURISTA' THEN 1 ELSE 0 END) / COUNT(*) AS pctTurista,
        1.0 * SUM(CASE WHEN descLifeCycle = '04-DESENCANTADA' THEN 1 ELSE 0 END) / COUNT(*) AS pctDesencantada,
        1.0 * SUM(CASE WHEN descLifeCycle = '05-ZUMBI' THEN 1 ELSE 0 END) / COUNT(*) AS pctZumbi,
        1.0 * SUM(CASE WHEN descLifeCycle = '02-RECONQUISTADO' THEN 1 ELSE 0 END) / COUNT(*) AS pctReconquistado,
        1.0 * SUM(CASE WHEN descLifeCycle = '02-REBORN' THEN 1 ELSE 0 END) / COUNT(*) AS pctReborn

FROM life_cycle

WHERE dtRef < '{date}'

GROUP BY IdCliente
),


tb_avg_ciclo AS (


SELECT descLifeCycleAtual, AVG(QtdFrequencia) as avgFreqGrupo

FROM tb_life_cycle_atual

GROUP BY descLifeCycleAtual

),

tb_join AS (

SELECT t1.*, t2.descLifeCycleD38,
T3.pctFiel,
T3.pctTurista,
T3.pctCurioso,
T3.pctDesencantada,
T3.pctZumbi,
T3.pctReconquistado,
T3.pctReborn,
t4.avgFreqGrupo,
1.0 * t1.QtdFrequencia / t4.avgFreqGrupo ratioFreqGrupo

FROM tb_life_cycle_atual t1
LEFT JOIN tb_life_cycle_d28 t2
ON T1.IdCliente = T2.IdCliente

LEFT JOIN tb_share_ciclos AS T3
ON T1.IdCliente = T3.IdCliente

LEFT JOIN tb_avg_ciclo AS t4
on t1.descLifeCycleAtual = t4.descLifeCycleAtual
)

SELECT date('{date}', '-1 DAY') as dtRef, * 

FROM tb_join