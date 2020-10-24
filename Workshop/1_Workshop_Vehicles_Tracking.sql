-- ===============================================================
-- Author:          /Daniel Hernandez
-- Create date:     /November - 2019
-- Description:     /Dataset listing active orders in workshop
-- Access Level:    /Advisors, Workshop Manager, Vice and CEO
-- Return:      
--      1. Explicit data of the vehicle (Brand, Model, VIN, etc)
--      2. Order data (Client, Checklist, Responses, etc)
--      3. Employees involved (Advisor, Techinicians) 
--      4. Flags (Ready for delivery, With delay)
-- Filters:
--      None
-- ===============================================================
select 
    zz.*
    ,case
        WHEN listo = 1 then 1
        when retraso = 1 then 2
        else 3
    end as orden_estado
from
(
    select
        vh.des_modelo as Vehiculo
        ,vh.ano as Ano
        ,vh.des_color as Color
        ,vh.placa
        ,vh.serie as VIN
        ,v.bodega
        ,v.numero as Nro_Orden
        ,v.fecha as Fecha_entrada
        ,v.Tipo_Orden
        ,v.vendedor as Asesor_Servicio
        ,cast(v.vlr_rptos+v.vlr_MO+v.vlr_TOT as money) as Valor_Orden
        ,case when dbo.RespuestaOrden(v.numero,v.bodega) = 'Totalmente respondida' then 1 else 0 end as Listo
        ,case when datediff(day,v.fecha,getdate())>30 then 1 else 0 end as Retraso
        ,v.nota as Facturacion
        ,dbo.RespuestaOrden(v.numero,v.bodega) as Lista_Chequeo
        ,dbo.demca_tall_lista_chequeo2(v.numero,v.bodega) as Items_Chequeo
        ,dbo.demca_tall_lista_chequeo_resp(v.numero,v.bodega) as Items_Chequeo_Resp
        ,dbo.demca_tall_lista_operarios(v.numero,v.bodega) as Operarios
        ,(ri1.descripcion + ' ' + isnull(ri2.descripcion,'')) as Razon_Ingreso
        ,teo.notas
        ,teo.notas2
        ,datediff(dd,v.fecha,getdate()) as Dias
    from v_demca_taller_orden_sin_entrega v 
    left join v_vh_vehiculos vh on v.serie = vh.codigo
    left join tall_encabeza_orden teo on v.bodega = teo.bodega and v.numero = teo.numero
    left join tall_razon_ingreso ri1 on teo.razon = ri1.razon
    left join tall_razon_ingreso ri2 on teo.razon2 = ri2.razon
)zz