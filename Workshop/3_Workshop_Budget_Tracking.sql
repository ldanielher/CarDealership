-- ===============================================================
-- Author:          /Daniel Hernandez
-- Create date:     /November - 2019
-- Description:     /Dataset listing billing of each month day
-- Access Level:    /Workshop Managers, Vice and CEO
-- Return:      
--      1. Each day of the month and each business day
--      2. Entrances and exits of vehicles (And cumulatives)
--      3. Each category of billing accounts (And cumulatives)
--      4. Total billing of the day (And cumulatives)
-- Filters:
--      1. Year - Month
-- ===============================================================
SELECT 
    ano
    ,mes
    ,dia
    ,cast([ENTRADAS] as int) AS Entradas
    ,SUM(cast([ENTRADAS] as int)) OVER(ORDER BY dia) as Ent_Acum
    ,cast([SALIDAS] as int) AS Salidas
    ,SUM(cast([SALIDAS] as int)) OVER(ORDER BY dia) as Sal_Acum
    ,[CLIENTE] AS Cliente
    ,SUM([CLIENTE]) OVER(ORDER BY dia) as Cliente_Acum
    ,[ASEGURADORA] AS Aseguradora
    ,SUM([ASEGURADORA]) OVER(ORDER BY dia) as Aseg_Acum
    ,[GARANTIA] AS Garantia
    ,SUM([GARANTIA]) OVER(ORDER BY dia) as Garant_Acum
    ,[INTERNO] AS Interno
    ,SUM([INTERNO]) OVER(ORDER BY dia) as Int_Acum
    ,isnull([CLIENTE],0)+isnull([ASEGURADORA],0)+isnull([GARANTIA],0)+isnull([INTERNO],0) AS Total
    ,SUM(isnull([CLIENTE],0)+isnull([ASEGURADORA],0)+isnull([GARANTIA],0)+isnull([INTERNO],0)) OVER(ORDER BY dia) as Total_Acum
    ,cast([DIA HABIL] as int) AS Dia_Habil
FROM 
(
    select 
        tt.tipo_trabajo as tipo
        ,v.ano
        ,v.mes
        ,day(tt.fecha) as dia
        ,cast(sum(v.valor) as money) as Valor
    from v_demca_ventas_postventa v
    join 
    (
        select DISTINCT ---***** Clasificación de Cargos a cada documento
            d.tipo
            ,d.numero
            ,d.fecha
            ,case 
                when d.nit=800039439 then 'INTERNO'
                when d.nit in (900241676,900896197) then 'GARANTIA' 
                when d.nit in (860037707,860026182,860002184,860524654,860039988,860002400,860028415
                                ,891700037,860002180,890903407,860009578,860004875,800181749,890304806) then 'ASEGURADORA'
                when aseg.tipo is not null then 'ASEGURADORA' 
                else 'CLIENTE' 
            end as tipo_trabajo
        from documentos d
        left join tipo_transacciones doc on d.tipo = doc.tipo
        left join ( select distinct tipo_deducible as tipo,numero_deducible as numero from tall_encabeza_orden ) aseg on d.tipo = aseg.tipo and d.numero = aseg.numero
        where d.sw in (0,1,2,21,23,31,32) and doc.bodega in (0,1,2,3,4,5,6,14,16,17)
    )tt on v.tipo = tt.tipo and v.numero = tt.numero 
    where ano = (@Ano) and mes = (@Mes)
    group by tt.tipo_trabajo,v.ano,v.mes,day(tt.fecha)

    union all
    select 
        'ENTRADAS' as tipo
        ,ano
        ,mes
        ,dia
        ,sum(conteo) as Valor
    from 
    v_taller_entradas_total_dh
    group by dia,ano,mes

    union all
    select 
        'SALIDAS' as tipo
        ,ano
        ,mes
        ,dia
        ,sum(conteo) as Valor
    from 
    v_taller_salidas_total_dh
    group by dia,ano,mes

    union all
    select 
        'DIA HABIL'
        ,YEAR(fecha) as ano
        ,MONTH(fecha) as mes
        ,DAY(fecha) as dia 
        ,ROW_NUMBER() OVER(PARTITION by YEAR(fecha),MONTH(fecha) ORDER BY DAY(fecha) asc) AS Valor
    from y_calendario 
    where (domingo <> 1 AND festivo <> 1)
)ZZ
PIVOT( SUM( Valor ) FOR TIPO IN ([CLIENTE],[ASEGURADORA],[GARANTIA],[INTERNO],[ENTRADAS],[SALIDAS],[DIA HABIL])) AS pt
where ano = (@Ano) and mes = (@Mes)
group by ano,mes,dia,[CLIENTE],[ASEGURADORA],[GARANTIA],[INTERNO],[ENTRADAS],[SALIDAS],[DIA HABIL]
order by ano,mes,dia

-- ===============================================================
-- Description:     /Dataset listing Budget for each month
--                  /from an auxiliar table filled with it
-- Return:      
--      1. Year - Month
--      2. Budget amount
-- Filters:
--      None
-- ===============================================================
select 
    Ano
    ,Mes
    ,sum(Valor) as Valor
from aux_presupuestos
where 
    Area = 'Taller'
    and SubArea = 'General '
    and Grupo1 = 'Facturacion Mensual'
group by 
    Ano
    ,Mes

-- ===============================================================
-- Description:     /Calculates how many times multiply the 
--                  /diary amount of the month budget according 
--                  /to the "Year - Month" filter
-- Return:      
--      1. Multiplier
-- Filters:
--      1. Year - Month
-- ===============================================================
select 
    case
        when YEAR(fecha)<year(getdate()) then dha.ult_dh
        when YEAR(fecha)=year(getdate()) and MONTH(fecha)<MONTH(getdate()) then dha.ult_dh
        when year(getdate()) = YEAR(fecha) and MONTH(getdate()) = MONTH(fecha) then dh.Valor
        else 0
    end as multiplicador
from y_calendario y
left join 
(
    select * from
    (
        select 
            YEAR(fecha) as ano
            ,MONTH(fecha) as mes
            ,DAY(fecha) as dia 
            ,ROW_NUMBER() OVER(PARTITION by YEAR(fecha),MONTH(fecha) ORDER BY DAY(fecha) asc) AS Valor

        from y_calendario 
        where 
            (domingo <> 1 AND festivo <> 1)
    )z
    where dia = day(getdate()) and mes = month(getdate()) 
)dh on year(y.fecha) = dh.ano
left join 
(
    select 
        ano
        ,mes
        ,max(valor) ult_dh
    from
    (
        select 
            YEAR(fecha) as ano
            ,MONTH(fecha) as mes
            ,DAY(fecha) as dia 
            ,ROW_NUMBER() OVER(PARTITION by YEAR(fecha),MONTH(fecha) ORDER BY DAY(fecha) asc) AS Valor
        from y_calendario 
        where 
            (domingo <> 1 AND festivo <> 1)
    )z 
    group by z.ano,z.mes
)dha on year(y.fecha) = dha.ano and month(y.fecha) = dha.mes
where 
    YEAR(fecha) = (@Ano) and MONTH(fecha) = (@Mes)
    and day(fecha) = day(getdate())