-- ===============================================================
-- Author:          /Daniel Hernandez
-- Create date:     /December - 2019
-- Description:     /Dataset listing sales data of last years
-- Access Level:    /Principal Workshop Manager, Vice and CEO
-- Return:      
--      1. Year
--      2. Workshop (Location)
--      3. Actual and previous year Billing values 
--      4. Actual and previous year Cost values 
--      5. Actual and previous year Profit values 
--      6. Actual and previous year Inflation values 
-- Filters:
--      None
-- ===============================================================
select 
	ventas.Ano
	,ventas.bodega
	,ventas.Facturación
	,isnull(ventas.Facturacion_ant,0) as Facturacion_ant
	,costos.Costos
	,isnull(costos.Costos_ant,0) as Costos_ant
	,(ventas.Facturación-costos.Costos) as Utilidad
	,isnull(ventas.Facturacion_ant-costos.Costos_ant,0) as Utilidad_ant
	,ind.IPC
	,ind_ant.IPC as IPC_ant
from
(
	select 
		act.ano as Ano
		,act.bodega
		,act.Facturación
		,ant.Facturación as Facturacion_ant
	from
	(
		select 
			Ano
			,'General' as bodega
			,Sum(conteo) as Facturación
		FROM
		(
			select 
				ano as ano
				,valor as conteo
			from
			v_demca_ventas_postventa_total
		)ZZ
		group by 
			Ano
	)act
	left join
	(
		select 
			Ano
			,'General' as bodega
			,Sum(conteo) as Facturación
		FROM
		(
			select 
				ano as ano
				,valor as conteo
			from
			v_demca_ventas_postventa_total
		)ZZ
		group by 
			Ano
	)ant 
	on ant.ano = (act.ano-1) 

	union all
	select 
		act.ano as Ano
		,act.bodega
		,act.Facturación
		,ant.Facturación as Facturacion_ant
	from
	(
		select 
			Ano
			,bodega
			,Sum(conteo) as Facturación
		FROM
		(
			select 
				ano as ano
				,case when bodega = 3 then 'Serviexpress' else 'Pontevedra' end as bodega
				,valor as conteo
			from
			v_demca_ventas_postventa_total
		)ZZ
		group by 
			Ano,bodega
	)act
	left join
	(
		select 
			Ano
			,bodega
			,Sum(conteo) as Facturación
		FROM
		(
			select 
				ano as ano
				,case when bodega = 3 then 'Serviexpress' else 'Pontevedra' end as bodega
				,valor as conteo
			from
			v_demca_ventas_postventa_total
		)ZZ
		group by 
			Ano,bodega
	)ant 
	on ant.ano = (act.ano-1) and ant.bodega = act.bodega
)ventas
left join
(
	select 
		act.ano as Ano
		,act.bodega
		,act.Costos
		,ant.Costos as Costos_ant
	from
	(
		select 
			Ano
			,'General' as bodega
			,Sum(conteo) as Costos
		FROM
		(
			select 
				ano as ano
				,-valor as conteo
			from
			v_demca_costos_postventa_total
		)ZZ
		group by 
			Ano
	)act
	left join
	(
		select 
			Ano
			,'General' as bodega
			,Sum(conteo) as Costos
		FROM
		(
			select 
				ano as ano
				,-valor as conteo
			from
			v_demca_costos_postventa_total
		)ZZ
		group by 
			Ano
	)ant 
	on ant.ano = (act.ano-1) 

	union all
	select 
		act.ano as Ano
		,act.bodega
		,act.Costos
		,ant.Costos as Costos_ant
	from
	(
		select 
			Ano
			,bodega
			,Sum(conteo) as Costos
		FROM
		(
			select 
				ano as ano
				,case when bodega = 3 then 'Serviexpress' else 'Pontevedra' end as bodega
				,-valor as conteo
			from
			v_demca_costos_postventa_total
		)ZZ
		group by 
			Ano,bodega
	)act
	left join
	(
		select 
			Ano
			,bodega
			,Sum(conteo) as Costos
		FROM
		(
			select 
				ano as ano
				,case when bodega = 3 then 'Serviexpress' else 'Pontevedra' end as bodega
				,-valor as conteo
			from
			v_demca_costos_postventa_total
		)ZZ
		group by 
			Ano,bodega
	)ant 
	on ant.ano = (act.ano-1) and ant.bodega = act.bodega

)costos on ventas.Ano = costos.Ano and ventas.bodega = costos.bodega
left join aux_indicadores ind on ventas.Ano = ind.ano
left join aux_indicadores ind_ant on ventas.Ano-1 = ind_ant.ano
order by ventas.ano,ventas.bodega

-- ===============================================================
-- Description:     /Dataset listing Sales behavior for each year
--                  /ready for values and percentages graphic
-- Return:      
--      1. Year
--      2. Workshop (Location)
--      3. Billing value
--      4. Cost value
--      5. Difference between Billing and Cost value
--      6. Billing proyection for Inflation (IPC)
-- Filters:
--      None
-- ===============================================================
select 
	ventas.Ano
	,ventas.bodega
	,ventas.Facturación
	,costos.Costos
	,(ventas.Facturación-costos.Costos) as Diferencia
	,(ventas.Facturación*(100-ind.IPC)/100) as Facturacion_IPC
from
(
	select 
		Ano
		,'General' as bodega
		,Sum(conteo) as Facturación
	FROM
	(
		select 
			ano as ano
			,valor as conteo
		from
		v_demca_ventas_postventa_total
	)ZZ
	group by 
		Ano
)ventas
left join
(
	select 
		Ano
		,'General' as bodega
		,Sum(conteo) as Costos
	FROM
	(
		select 
			ano as ano
			,-valor as conteo
		from
		v_demca_costos_postventa_total
	)ZZ
	group by 
		Ano
)costos on ventas.Ano = costos.Ano and ventas.bodega = costos.bodega
left join aux_indicadores ind on ind.Ano = ventas.ano
order by ventas.ano,ventas.bodega	

