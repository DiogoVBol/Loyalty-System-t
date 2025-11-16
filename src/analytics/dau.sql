
SELECT  substr(DtCriacao, 0, 11) AS DtDia,
        count(distinct IdCliente) AS DAU

FROM TRANSACOES

GROUP BY DtDia

ORDER BY DtDia DESC

 