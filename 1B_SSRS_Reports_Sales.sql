SELECT * FROM
(
SELECT 
	d.tipo
    ,year(d.fecha) as ano
    ,month(d.fecha) as mes
	,D.Fecha
	,T.NOMBRES AS Vendedor
	,CASE 
		WHEN T.NIT IN (79145114) THEN 'VENTAS GERENCIA' 
		WHEN d.tipo = 'VU' then 'USADOS' 
		WHEN d.tipo = 'VP' then 'PEUGEOT'
		WHEN D.modelo = '*' THEN 'AV 116' 
	 	ELSE 'AV 19'  
	END Vitrina
	,VH.modelo
	,VH.DESCRIPCION AS Vehiculo
	,vh.des_color as Color
	,vh.modelo_ano as Año
	,cast(D.VALOR_TOTAL as money) as Valor_total
	,ISNULL(TP.NOMBRES,'') AS Prenda
FROM DOCUMENTOS D
INNER JOIN DOCUMENTOS_LIN L ON D.TIPO = L.TIPO AND D.NUMERO = L.NUMERO
INNER JOIN TERCEROS T ON D.VENDEDOR = T.NIT
INNER JOIN V_VH_VEHICULOS VH ON L.CODIGO = VH.CODIGO
LEFT JOIN VH_DOCUMENTOS_PED VDP ON VDP.NUMERO=D.DOCUMENTO
LEFT JOIN TERCEROS TP ON TP.NIT=VDP.NIT_PRENDA
WHERE 
	D.TIPO in ('V','VP','VU')
	AND D.ANULADO = 0
	AND year(D.FECHA) = 2019 and month(D.FECHA) = 9
	--AND year(D.FECHA) = (@Ano) and month(D.FECHA) = (@Mes)

UNION ALL
SELECT 
	d.tipo
    ,year(d.fecha) as ano
    ,month(d.fecha) as mes
	,D.Fecha
	,T.NOMBRES AS Vendedor
	,'ACTIVO FIJO' AS Vitrina
	,'' AS MODELO
	,D.NOTAS AS Vehiculo
	,'' as Color
	,'' as Año
	,cast(D.VALOR_TOTAL as money) as Valor_total
	,'' AS Prenda
FROM DOCUMENTOS D
LEFT JOIN DOCUMENTOS_LIN L ON D.TIPO = L.TIPO AND D.NUMERO = L.NUMERO
LEFT JOIN TERCEROS T ON D.VENDEDOR = T.NIT
WHERE 
	D.TIPO = 'G' and l.codigo = 'ACTIVO FIJO'
	AND D.ANULADO = 0
	--AND year(D.FECHA) = (@Ano) and month(D.FECHA) = (@Mes)
	AND year(D.FECHA) = 2019 and month(D.FECHA) = 9
)ZZ
ORDER BY 
	CASE 
		WHEN tipo = 'V' THEN 1
		WHEN tipo = 'VP' THEN 2
		WHEN tipo = 'VU' THEN 3
		WHEN tipo = 'G' THEN 4
	END
	,fecha

--******
select 
    tipo
    ,mes
    ,avg(cantidad) as cantidad
    ,avg(valor_total) as promedio
from
(
    SELECT 
        d.tipo
        ,year(D.Fecha) as ano
        ,month(d.fecha) as mes
        ,cast(sum(D.VALOR_TOTAL) as money) as Valor_total
        ,count(d.tipo) as Cantidad
    FROM DOCUMENTOS D
    WHERE 
        D.TIPO in ('V','VU','VP')
        AND D.ANULADO = 0
        --AND year(D.FECHA) = 2019 --and month(D.FECHA) = month(getdate())
    GROUP by 
        d.tipo
        ,year(D.Fecha) 
        ,month(d.fecha)
	
	UNION ALL
	SELECT 
        d.tipo
        ,year(D.Fecha) as ano
        ,month(d.fecha) as mes
        ,cast(sum(D.VALOR_TOTAL) as money) as Valor_total
        ,count(d.tipo) as Cantidad
    FROM DOCUMENTOS D
	LEFT JOIN DOCUMENTOS_LIN L ON D.TIPO = L.TIPO AND D.NUMERO = L.NUMERO
    WHERE 
		D.TIPO = 'G' and l.codigo = 'ACTIVO FIJO'
        AND D.ANULADO = 0
    GROUP by 
        d.tipo
        ,year(D.Fecha) 
        ,month(d.fecha)
    
    
)x
where 
    mes = 9--month(getdate())
    and x.ano in (year(getdate())-3,year(getdate())-2,year(getdate())-1)
group by tipo,mes
ORDER BY tipo,mes

