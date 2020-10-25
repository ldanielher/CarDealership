-- ===============================================================
-- Author:          /Daniel Hernandez
-- Create date:     /January - 2020
-- Description:     /Dataset listing scheduled appointments of clients
-- Access Level:    /Public in Workshop entrance
-- Return:      
--      1. Data of the appointment (Id, time, channel, etc)
--      2. Client Vehicle data (Client, Vehicle, license plate)
--      3. Notes from Advisor
--      4. Arrival time and Status flag
-- Filters:
--      1. Workshop (Location)
-- ===============================================================
select 
    citas.id_cita
	,hora.Hora_Cita as Hora
    ,isnull(Marca,'') as Marca
	,isnull(Vehiculo,'') as Vehiculo
	,isnull(placa,'') as Placa
	,isnull(Cliente,'') as Cliente
	,isnull(Notas,'') as Notas 
	,isnull(Tipo_Cita,'') as Canal
	,isnull(hora.Hora_Llegada,'') as Llegada
    ,isnull(hora.Estado,'') as Estado
	,Bodega
from
(
    select 
        c.id_cita
        ,year(c.fecha_hora_ini) as Ano
        ,month(c.fecha_hora_ini) as Mes
        ,day(c.fecha_hora_ini) as Dia
        ,cast(cast(DATEPART(hh,c.fecha_hora_ini)as [varchar]) +case when DATEPART(n,c.fecha_hora_ini)= 0 then '00' else '30' end as int) as Hora
        ,tr.descripcion as Tipo_Cita
        ,isnull(dbo.demca_cita_operaciones(c.id_cita),isnull(c.notas,'')) as Notas
        ,v.des_modelo as Vehiculo
        ,v.placa
        ,c.Cliente
        ,case 
			when c.bodega in ('5') then 1
			when c.bodega in ('3') then 2
			when c.bodega in ('14') then 3
		end as Bodega
        ,case 
            when c.bodega in ('5','3') then 'CJD'
            when c.bodega in ('14') then 'Peugeot'

        end as Marca
    from v_tall_citas c 
    left join tall_citas c2 on c.id_cita = c2.id_cita 
    left join tall_citas_razon tr on c2.razon = tr.razon
    left join v_vh_vehiculos v on c.codigo_veh = v.codigo
    where 
        c.fecha_hora_ini >= cast(((@fecha)+' 00:00:00') as [datetime]) and c.fecha_hora_ini <= cast(((@fecha)+' 23:00:00') as [datetime]) --**///////Fecha
        and c.Estado <> 'Cancelada' 
)citas
left join
(
	select 
		id_cita
		,Hora_Cita
		,Hora_Llegada
		,datediff(MI,fecha_hora_ini,fecha_entrada) as dif
		,case	
			when Hora_Llegada is null and datediff(MI,fecha_hora_ini,getdate()) > 30 then 'INCUMPLIDA'
			when Hora_Llegada is null and datediff(MI,fecha_hora_ini,getdate()) <= 30 then 'PENDIENTE'
			when (datediff(MI,fecha_hora_ini,fecha_entrada)) > 5 then 'RETRASADA'
			when (datediff(MI,fecha_hora_ini,fecha_entrada) >= 0 and (datediff(MI,fecha_hora_ini,fecha_entrada)) <= 5)  then 'A TIEMPO'
			when (datediff(MI,fecha_hora_ini,fecha_entrada) < 0)  then 'ANTICIPADO'
		end as Estado
	from
	(
		select 
			c.id_cita
			,c.fecha_hora_ini
			,min(teo.entrada) as fecha_entrada
			,cast(DATEPART(hh,c.fecha_hora_ini)as [varchar])+':'+case when DATEPART(n,c.fecha_hora_ini)= 0 then '00' else '30' end as Hora_Cita
			,cast(DATEPART(hh,min(teo.entrada))as [varchar])+':'+case when cast(DATEPART(n,min(teo.entrada)) as int)< 10 then '0'+cast(DATEPART(n,min(teo.entrada))as [varchar]) else cast(DATEPART(n,min(teo.entrada))as [varchar]) end as Hora_Llegada
		from v_tall_citas c 
		left join tall_encabeza_orden teo on c.codigo_veh = teo.serie and c.fecha_hora_ini-1 < teo.entrada and c.fecha_hora_ini+30 > teo.entrada
		where 
			c.Estado <> 'Cancelada'
			AND (teo.anulada = 0 or teo.anulada is null)
		group by
			c.id_cita
			,c.fecha_hora_ini
	)c
)hora on citas.id_cita = hora.id_cita
where Bodega = (@bodega)
order by citas.Hora