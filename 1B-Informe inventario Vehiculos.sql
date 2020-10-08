SELECT  
    v.Bodega
    ,v.Modelo
    ,V.Descripcion
    ,V.Plan_Venta
    ,V.fecha_ent as Disponible_desde
    ,V.Tipo_Vehiculo
    ,V.VIN
    ,V.Color
    ,V.Modelo_ano
    ,V.Estado
    ,V.Ubicacion
    ,V.Marca
    ,V.Nro_Motor
    ,V.Costo
    ,cast(isnull(scos.Valor_SubCos,0) as money) as SUBECOSTO
    ,cast(isnull(bcos.Valor_BajCos,0) as money) as BAJACOSTO
    ,V.COSTO+cast(isnull(scos.Valor_SubCos,0) as money)-cast(isnull(bcos.Valor_BajCos,0) as money) as COSTO_TOTAL
    ,V.IVA
    ,(select t.nombres from vh_documentos_ped vhp, terceros t where vhp.vendedor=t.nit and vhp.numero=v.negocio ) as Asesor
    ,V.Negocio
    ,V.Placa
FROM v_vehiculos_master_mov_DH V
left join v_vh_vehiculos_reservados vr on v.vin = vr.codigo 
left join 
(
    select 
        codigo
        ,sum(costo_unitario) as Valor_SubCos
    from documentos_lin where sw in (14) 
    group by codigo
)scos on v.VIN = scos.codigo
left join 
(
    select 
        codigo
        ,sum(costo_unitario) as Valor_BajCos
    from documentos_lin where sw in (13) 
    group by codigo
)bcos on v.VIN = bcos.codigo
WHERE 
    V.PLAN_VENTA = 1 
    and V.ESTADO not in ('NA','FACTURADO ENTREGADO','SALIO DEL INVENTARIO','FACTURADO CON DEVOLUCION','ACTIVO FIJO')
    AND V.MARCA  = 'PEUGEOT'
    and v.bodega in ('6','17')
    and vr.codigo is null
ORDER BY V.fecha_ent


--******************************************
SELECT 
    V.fecha_ent as Disponible_desde
    ,v.Bodega
    ,v.Cod_Modelo
    ,V.VIN
    ,V.Descripcion
    ,V.Modelo_ano
    ,V.Color
    ,V.Estado
    ,V.Negocio
    ,(select t.nombres from vh_documentos_ped vhp, terceros t where vhp.vendedor=t.nit and vhp.numero=v.negocio ) as Asesor
    ,V.Placa
    ,V.Ubicacion
FROM v_vehiculos_master_mov_DH V
left join v_vh_vehiculos_reservados vr on v.vin = vr.codigo 
WHERE 
    V.PLAN_VENTA = 1 
    AND V.ESTADO not in ('NA','FACTURADO ENTREGADO','SALIO DEL INVENTARIO','FACTURADO CON DEVOLUCION','ACTIVO FIJO')
    AND V.MARCA  <> 'PEUGEOT'
    and v.bodega = '6'
    and vr.codigo is null
ORDER BY V.fecha_ent