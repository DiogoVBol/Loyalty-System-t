--.tables

WITH tb_usuario_curso AS (
    SELECT idUsuario,
            descSlugCurso,
            COUNT(descSlugCursoEpisodio) as qtdeEps

    FROM cursos_episodios_completos

    WHERE dtCriacao < '{date}'

    GROUP BY idUsuario, descSlugCurso
),

tb_cursos_total_eps AS (

    SELECT
        descSlugCurso,
        COUNT(descEpisodio) as qtdeTotalEps

    FROM cursos_episodios

    GROUP BY descSlugCurso

),

tb_pct_cursos as (

    SELECT  t1.idUsuario,
            t1.descSlugCurso,
            1.0 * t1.qtdeEps / t2.qtdeTotalEps as pctCursoCompleto

    FROM tb_usuario_curso T1
    LEFT JOIN tb_cursos_total_eps T2
    ON T1.descSlugCurso = T2.descSlugCurso
),

tb_pct_cursos_pivo AS (

    SELECT  idUsuario,

            SUM(CASE WHEN pctCursoCompleto = 1 THEN 1 else 0 end) AS qtdeCursosCompleto,
            SUM(CASE WHEN pctCursoCompleto > 0 and  pctCursoCompleto < 1 THEN 1 else 0 end) AS qtdeCursosIncompletos,

            SUM(CASE WHEN descSlugCurso = 'carreira' THEN pctCursoCompleto else 0 END) AS carreira,
            SUM(CASE WHEN descSlugCurso = 'coleta-dados-2024' THEN pctCursoCompleto else 0 END) AS coletaDados2024,
            SUM(CASE WHEN descSlugCurso = 'ds-databricks-2024' THEN pctCursoCompleto else 0 END) AS dsDatabricks2024,
            SUM(CASE WHEN descSlugCurso = 'ds-pontos-2024' THEN pctCursoCompleto else 0 END) AS dsPontos2024,
            SUM(CASE WHEN descSlugCurso = 'estatistica-2024' THEN pctCursoCompleto else 0 END) AS estatistica2024,
            SUM(CASE WHEN descSlugCurso = 'estatistica-2025' THEN pctCursoCompleto else 0 END) AS estatistica2025,
            SUM(CASE WHEN descSlugCurso = 'github-2024' THEN pctCursoCompleto else 0 END) AS github2024,
            SUM(CASE WHEN descSlugCurso = 'github-2025' THEN pctCursoCompleto else 0 END) AS github2025,
            SUM(CASE WHEN descSlugCurso = 'ia-canal-2025' THEN pctCursoCompleto else 0 END) AS iaCanal2025,
            SUM(CASE WHEN descSlugCurso = 'lago-mago-2024' THEN pctCursoCompleto else 0 END) AS lagoMago2024,
            SUM(CASE WHEN descSlugCurso = 'machine-learning-2025' THEN pctCursoCompleto else 0 END) AS machineLearning2025,
            SUM(CASE WHEN descSlugCurso = 'matchmaking-trampar-de-casa-2024' THEN pctCursoCompleto else 0 END) AS matchmakingTramparDeCasa2024,
            SUM(CASE WHEN descSlugCurso = 'ml-2024' THEN pctCursoCompleto else 0 END) AS ml2024,
            SUM(CASE WHEN descSlugCurso = 'mlflow-2025' THEN pctCursoCompleto else 0 END) AS mlflow2025,
            SUM(CASE WHEN descSlugCurso = 'pandas-2024' THEN pctCursoCompleto else 0 END) AS pandas2024,
            SUM(CASE WHEN descSlugCurso = 'pandas-2025' THEN pctCursoCompleto else 0 END) AS pandas2025,
            SUM(CASE WHEN descSlugCurso = 'python-2024' THEN pctCursoCompleto else 0 END) AS python2024,
            SUM(CASE WHEN descSlugCurso = 'python-2025' THEN pctCursoCompleto else 0 END) AS python2025,
            SUM(CASE WHEN descSlugCurso = 'sql-2020' THEN pctCursoCompleto else 0 END) AS sql2020,
            SUM(CASE WHEN descSlugCurso = 'sql-2025' THEN pctCursoCompleto else 0 END) AS sql2025,
            SUM(CASE WHEN descSlugCurso = 'streamlit-2025' THEN pctCursoCompleto else 0 END) AS streamlit2025,
            SUM(CASE WHEN descSlugCurso = 'trampar-lakehouse-2024' THEN pctCursoCompleto else 0 END) AS tramparLakehouse2024,
            SUM(CASE WHEN descSlugCurso = 'tse-analytics-2024' THEN pctCursoCompleto else 0 END) AS tseAnalytics2024


    from tb_pct_cursos

    GROUP by idUsuario

),

tb_atividade AS (

        SELECT  idUsuario,
                max(dtCriacao) AS dtCriacao

        FROM habilidades_usuarios
        WHERE dtCriacao < '{date}'

        GROUP BY idUsuario

    UNION ALL

        SELECT  idUsuario,
                max(dtCriacao) AS dtCriacao

        FROM cursos_episodios_completos
        WHERE dtCriacao < '{date}'

        GROUP BY idUsuario

    UNION ALL

        SELECT  idUsuario,
                max(dtRecompensa) AS dtCriacao

        FROM recompensas_usuarios
        WHERE dtRecompensa < '{date}'

        GROUP BY idUsuario

),

tb_ultima_atividade AS (

SELECT idUsuario, MIN(julianday('{date}') - julianday(dtCriacao)) AS qtdeDiasUltiAtividade

FROM tb_atividade

GROUP BY idUsuario  
),


tb_join AS (

    SELECT T3.idTMWCliente as idCliente,

            T1.qtdeCursosCompleto,
            T1.qtdeCursosIncompletos,
            T1.carreira,
            T1.coletaDados2024,
            T1.dsDatabricks2024,
            T1.dsPontos2024,
            T1.estatistica2024,
            T1.estatistica2025,
            T1.github2024,
            T1.github2025,
            T1.iaCanal2025,
            T1.lagoMago2024,
            T1.machineLearning2025,
            T1.matchmakingTramparDeCasa2024,
            T1.ml2024,
            T1.mlflow2025,
            T1.pandas2024,
            T1.pandas2025,
            T1.python2024,
            T1.python2025,
            T1.sql2020,
            T1.sql2025,
            T1.streamlit2025,
            T1.tramparLakehouse2024,
            T1.tseAnalytics2024,

            T2.qtdeDiasUltiAtividade
            

    FROM tb_pct_cursos_pivo T1
    LEFT JOIN tb_ultima_atividade T2
    ON T1.idUsuario = T2.idUsuario

    INNER JOIN usuarios_tmw AS T3
    ON T3.idUsuario = t1.idUsuario

)

SELECT date('{date}', '-1 DAY') as dtRef, *
FROM tb_join