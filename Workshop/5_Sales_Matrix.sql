-- ===============================================================
-- Author:          /Daniel Hernandez
-- Create date:     /December - 2019
-- Description:     /Dataset listing sales data month by month
--                  /classified by location
-- Access Level:    /Principal Workshop Manager, Vice and CEO
-- Return:      
--      1. Year
--      2. Workshop (Location)
--      3. Type of Value (Billing, Budget, Entrances, etc) 
--      4. Values for each month
-- Filters:
--      1. Year
-- ===============================================================
select 
    Ano
    ,'General' as bodega
    ,Tipo
    ,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
FROM
(
    select * from
    (
        select 
            'PV_Entradas' as Tipo
            ,ano
            ,mes
            ,conteo
        from
        v_taller_entradas_total_DH
    )ent

    union all
    select * from
    (
        select 
            'PV_Facturados' as Tipo
            ,ano
            ,mes
            ,conteo
        from
        v_taller_salidas_total_DH
    )ent

    union all
    select * from
    (
        select 
            'PV_Entregados' as Tipo
            ,ano
            ,mes
            ,conteo
        from
        v_taller_salidas_entreg_total_DH
    )ent

    union all
    select * from
    (
        select 
            'Facturación' as Tipo
            ,ano
            ,mes
            ,valor as conteo
        from
        v_demca_ventas_postventa_total
    )ent

    union all
    select * from
    (
        select 
            'Presupuesto' as Tipo
            ,ano
            ,mes
            ,sum(valor) as conteo
        from
        aux_presupuestos where SubArea = 'General'
        group by ano,mes
    )ent
)ZZ
PIVOT( SUM( Conteo ) FOR Mes IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS pt
where
    ano = (@Ano)

union all
select 
    Ano
    ,case when bodega = 3 then 'Serviexpress' else 'Pontevedra' end as bodega
    ,Tipo
    ,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
FROM
(
    select * from
    (
        select 
            'PV_Entradas' as Tipo
            ,bodega
            ,ano
            ,mes
            ,conteo
        from
        v_taller_entradas_total_DH
    )ent

    union all
    select * from
    (
        select 
            'PV_Facturados' as Tipo
            ,bodega
            ,ano
            ,mes
            ,conteo
        from
        v_taller_salidas_total_DH
    )ent

    union all
    select * from
    (
        select 
            'PV_Entregados' as Tipo
            ,bodega
            ,ano
            ,mes
            ,conteo
        from
        v_taller_salidas_entreg_total_DH
    )ent

    union all
    select * from
    (
        select 
            'Facturación' as Tipo
            ,bodega
            ,ano
            ,mes
            ,valor as conteo
        from
        v_demca_ventas_postventa_total
    )ent
	
	union all
    select * from
    (
        select 
            'Presupuesto' as Tipo
			,'3' as bodega
            ,ano
            ,mes
            ,sum(valor) as conteo
        from
        aux_presupuestos where SubArea = 'Serviexpress'
        group by ano,mes
    )ent

	union all
    select * from
    (
        select 
            'Presupuesto' as Tipo
			,'5' as bodega
            ,ano
            ,mes
            ,sum(valor) as conteo
        from
        aux_presupuestos where SubArea = 'Pontevedra'
        group by ano,mes
    )ent
)ZZ
PIVOT( SUM( Conteo ) FOR Mes IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS pt
where
    ano = (@Ano)
order by 
    ano,bodega,tipo

-- ===============================================================
-- Description:     /Dataset listing billing, budget and entrances
--                  /for each month, for graphics
-- Return:      
--      1. Year
--      2. Workshop (Location)
--      3. Month
--      4. Billing value 
--      5. Billing value (with cumulatives)
--      6. Some categories of Entrances
-- Filters:
--      1. Year
-- ===============================================================
select 
    Ano
    ,'General' as bodega
    ,mes as Nro_Mes
    ,case
        when mes = '1' then 'Enero'
        when mes = '2' then 'Febrero'
        when mes = '3' then 'Marzo'
        when mes = '4' then 'Abril'
        when mes = '5' then 'Mayo'
        when mes = '6' then 'Junio'
        when mes = '7' then 'Julio'
        when mes = '8' then 'Agosto'
        when mes = '9' then 'Septiembre'
        when mes = '10' then 'Octubre'
        when mes = '11' then 'Noviembre'
        when mes = '12' then 'Diciembre'
    end as Mes
    ,[Facturación]
    ,SUM([Facturación]) OVER(ORDER BY mes) as Fact_Acum
    ,[PV_Entradas]
    ,[PV_Facturados]
    ,[PV_Entregados]
FROM
(
    select * from
    (
        select 
            'PV_Entradas' as Tipo
            ,ano
            ,mes
            ,conteo
        from
        v_taller_entradas_total_DH
    )ent

    union all
    select * from
    (
        select 
            'PV_Facturados' as Tipo
            ,ano
            ,mes
            ,conteo
        from
        v_taller_salidas_total_DH
    )ent

    union all
    select * from
    (
        select 
            'PV_Entregados' as Tipo
            ,ano
            ,mes
            ,conteo
        from
        v_taller_salidas_entreg_total_DH
    )ent

    union all
    select * from
    (
        select 
            'Facturación' as Tipo
            ,ano
            ,mes
            ,valor as conteo
        from
        v_demca_ventas_postventa_total
    )ent
)ZZ
PIVOT( SUM( Conteo ) FOR Tipo IN ([Facturación],[PV_Entradas],[PV_Facturados],[PV_Entregados])) AS pt
where
    ano = (@Ano)

union all
select 
    Ano
    ,case when bodega = 3 then 'Serviexpress' else 'Pontevedra' end as bodega
    ,mes as Nro_Mes
    ,case
        when mes = '1' then 'Enero'
        when mes = '2' then 'Febrero'
        when mes = '3' then 'Marzo'
        when mes = '4' then 'Abril'
        when mes = '5' then 'Mayo'
        when mes = '6' then 'Junio'
        when mes = '7' then 'Julio'
        when mes = '8' then 'Agosto'
        when mes = '9' then 'Septiembre'
        when mes = '10' then 'Octubre'
        when mes = '11' then 'Noviembre'
        when mes = '12' then 'Diciembre'
    end as Mes
    ,[Facturación]
    ,SUM([Facturación]) OVER(ORDER BY mes) as Fact_Acum
    ,[PV_Entradas],[PV_Facturados],[PV_Entregados]
FROM
(
    select * from
    (
        select 
            'PV_Entradas' as Tipo
            ,bodega
            ,ano
            ,mes
            ,conteo
        from
        v_taller_entradas_total_DH
    )ent

    union all
    select * from
    (
        select 
            'PV_Facturados' as Tipo
            ,bodega
            ,ano
            ,mes
            ,conteo
        from
        v_taller_salidas_total_DH
    )ent

    union all
    select * from
    (
        select 
            'PV_Entregados' as Tipo
            ,bodega
            ,ano
            ,mes
            ,conteo
        from
        v_taller_salidas_entreg_total_DH
    )ent

    union all
    select * from
    (
        select 
            'Facturación' as Tipo
            ,bodega
            ,ano
            ,mes
            ,valor as conteo
        from
        v_demca_ventas_postventa_total
    )ent
)ZZ
PIVOT( SUM( Conteo ) FOR Tipo IN ([Facturación],[PV_Entradas],[PV_Facturados],[PV_Entregados])) AS pt
where
    ano = (@Ano)

union all
select 
    Ano
    ,'Presupuesto' as bodega
    ,cast(mes as int) as Nro_Mes
    ,case
        when mes = '1' then 'Enero'
        when mes = '2' then 'Febrero'
        when mes = '3' then 'Marzo'
        when mes = '4' then 'Abril'
        when mes = '5' then 'Mayo'
        when mes = '6' then 'Junio'
        when mes = '7' then 'Julio'
        when mes = '8' then 'Agosto'
        when mes = '9' then 'Septiembre'
        when mes = '10' then 'Octubre'
        when mes = '11' then 'Noviembre'
        when mes = '12' then 'Diciembre'
    end as Mes
    ,[Facturación]
    ,SUM([Facturación]) OVER(ORDER BY cast(mes as int)) as Fact_Acum
    ,[PV_Entradas],[PV_Facturados],[PV_Entregados]
FROM
(
    select * from
    (
        select 
            'Facturación' as Tipo
            ,ano
            ,mes
            ,sum(Valor) as conteo
        from
        aux_presupuestos where SubArea = 'General'
        group by ano,mes
    )ent
)ZZ
PIVOT( SUM( Conteo ) FOR Tipo IN ([Facturación],[PV_Entradas],[PV_Facturados],[PV_Entregados])) AS pt
where
    ano = (@Ano)
order by 
    ano,Nro_mes,bodega

-- ===============================================================
-- Description:     /Dataset listing billing and budget 
--                  /for each month, for graphics
-- Return:      
--      1. Year
--      2. Type (Location, categories and Totals)
--      3. Month (And number related)
--      4. Billing or Budget value 
-- Filters:
--      1. Year
-- ===============================================================
select 
    Ano
    ,case
        when bodega = '3' then 'Total' 
        else bodega 
    end as bodega
    ,mes as Nro_Mes
    ,case
        when mes = '1' then 'Enero'
        when mes = '2' then 'Febrero'
        when mes = '3' then 'Marzo'
        when mes = '4' then 'Abril'
        when mes = '5' then 'Mayo'
        when mes = '6' then 'Junio'
        when mes = '7' then 'Julio'
        when mes = '8' then 'Agosto'
        when mes = '9' then 'Septiembre'
        when mes = '10' then 'Octubre'
        when mes = '11' then 'Noviembre'
        when mes = '12' then 'Diciembre'
    end as Mes
    ,[Facturación]
FROM
(
    select * from
    (
        select 
            'Facturación' as Tipo
            ,cast(bodega as [varchar]) as bodega
            ,ano
            ,mes
            ,valor as conteo
        from
        v_demca_ventas_postventa_total
		where bodega = '3'
    )ent

	union all
	select * from
  
        select 
            'Facturación' as Tipo
			,'Presupuesto' as bodega
            ,ano
            ,mes
            ,sum(Valor) as conteo
        from
        aux_presupuestos
		where SubArea = 'Serviexpress'
        group by ano,mes
    )ent
)ZZ
PIVOT( SUM( Conteo ) FOR Tipo IN ([Facturación])) AS pt
where
    ano = (@Ano)
order by 
    ano
	,Nro_mes
	,case 
		when bodega = 'Presupuesto' then 1
		when bodega = '3' then 2
		when bodega = 'REPUESTOS' then 3
		when bodega = 'T.O.T' then 4
		when bodega = 'MANO DE OBRA' then 5
		else 6
	end 

    