---**** ORIGINAL ******

CREATE VIEW [dbo].[v_vehiculos_master_mov_DH] AS
select 
    VH.CODIGO AS VIN
    ,VH.DES_MARCA AS Marca
    ,VH.MODELO as Cod_Modelo
    ,VH.des_modelo as Modelo
    ,VH.MODELO_ANO AS Modelo_ano
    ,VH.DESCRIPCION as Descripcion
    ,VH.DES_COLOR AS Color
    ,VH.MOTOR   as Nro_Motor
    ,isnull(sto.bodega,dent.bodega) as Bodega
    ,BUP.DESCRIPCION AS Ubicacion
    ,cast(isnull(sto.stock,0) as int) as Stock
    ,VH.PLAN_VENTA as Plan_Venta
    ,CASE 
        WHEN VH.PLAN_VENTA = 2 AND VH.USADO_COMPRADO = 1 THEN 'USADO COMPRADO'
        WHEN VH.PLAN_VENTA = 2 AND VH.USADO_RETOMADO = 1 THEN 'USADO RETOMADO'
        WHEN VH.PLAN_VENTA = 2 AND VH.USADO_CONSIGNADO = 1 THEN 'USADO CONSIGNADO' 
        ELSE 'NUEVO' 
    END AS Tipo_Vehiculo
    ,CASE 
        WHEN 
        VH.grupo='D' --------------------------------------/ Grupo del vehiculo es 'D' = Activo fijo
        THEN 
        case
            when dsal.sw = '11' ---------------------------/ Sw del documento de salida es 11 (Salidas Inv)
            then 'ACTIVO FIJO' 
            else 
                CASE WHEN   dsal.nit = 'XXXXXXXXX' ------------------------/ El doc de salida tiene un Nit especifico
                            and vhd.numero_ent is null --------------------/ No tiene devolucion (Casos en que se devuelve el vehiculo y el siguiente mov es el que debe quedar)
                THEN 'ACTIVO FIJO'
                ELSE 'FACTURADO CON DEVOLUCION'
                END
            
        END                
        --THEN 'ACTIVO FIJO' --*********************************** Es Activo Fijo
        WHEN vhd.numero_ent is not null THEN 'FACTURADO CON DEVOLUCION' --** Si el VH tiene Devolución en el sgte Mov (Dev NO es NULL)
        WHEN dsal.sw in ('4','11') THEN 'SALIO DEL INVENTARIO' --*********** Si el doc de salida del VH es un doc de salida (sw = 11)
        WHEN 
            isnull(dsal.sw,0) not in ('1') --------------------/ No se facturó (Doc de salida sw NO es = 1)
            AND ev.fecha_hora_evento IS NULL ------------------/ No se entregó (Evento de entrega NULL)
            AND hn.numero IS NULL -----------------------------/ No se asignó  (No tiene hoja de negocio)
            AND cast(isnull(sto.stock,0) as int)>0 ------------/ Tiene stock 
        THEN 'DISPONIBLE' --************************************ Disponible 
        WHEN 
            isnull(dsal.sw,0) not in ('1') --------------------/ No se facturó (Doc de salida NO es sw = 1)
            AND ev.fecha_hora_evento IS NULL ------------------/ No se entregó (Evento de entrega NULL)
            AND hn.numero IS NOT NULL -------------------------/ Se asignó  (Tiene hoja de negocio asociada)
            AND cast(isnull(sto.stock,0) as int)>0 ------------/ Tiene stock 
        THEN 'ASIGNADO' --************************************** Asignado
        WHEN 
            isnull(dsal.sw,0) in ('1') ------------------------/ Se facturó (Doc de salida sw = 1)
            --AND ev.fecha_hora_evento IS NULL ----------------/ No se entregó (Evento de entrega es NULL)
            AND ev.fecha_hora_evento IS NULL ------------------/ No se entregó (Evento de entrega es NULL)
        THEN 'FACTURADO NO ENTREGADO' --************************ Fact no entregado
        WHEN 
            isnull(dsal.sw,0) in ('1') ------------------------/ Se facturó (Doc de salida sw = 1)
            AND ev.fecha_hora_evento IS NOT NULL --------------/ Se entregó (Evento de entrega <> NULL)
        THEN 'FACTURADO ENTREGADO' --*************************** Facturado entregado
        ELSE 'NA' 
    END AS Estado
    ,hn.NUMERO AS Negocio
    ,VH.PLACA as Placa
    ,hn.VENDEDOR as Nit_Vendedor
    ,ev.fecha_hora_evento as Fecha_entrega
    ,VH.COSTO_UNITARIO AS Costo
    ,VH.PORCENTAJE_IVA_COMPRA AS IVA
    ,dent.bodega as bodega_ent
    ,dent.fecha_hora as fecha_ent
    ,vhm.tipo_ent
    ,vhm.numero_ent
    ,dsal.bodega as bodega_sal
    ,dsal.fecha_hora fecha_sal
    ,vhm.tipo_sal
    ,vhm.numero_sal
    ,vhd.tipo_ent as tipo_dev
    ,vhd.numero_ent as numero_dev
from v_vehiculos_mov_DH vhm
LEFT JOIN documentos dent on dent.tipo = vhm.tipo_ent and dent.numero = vhm.numero_ent --**** Documento de Entrada del movimiento
LEFT JOIN documentos dsal on dsal.tipo = vhm.tipo_sal and dsal.numero = vhm.numero_sal --**** Documento de Salida del movimiento
left join V_VH_VEHICULOS VH on vhm.codigo = vh.codigo --- Datos del vehiculo 
left join V_REFERENCIAS_STO_HOY sto on  ------------------- Stock actual del vehiculo
            vhm.codigo = sto.codigo 
            and stock > 0
LEFT JOIN 
    (
        select  ------------------------------------------- Lineas de Hoja de Negocio
            p.codigo
            ,p.fecha
            ,p.numero
            ,p.vendedor
            ,p.plan_venta
        from VH_DOCUMENTOS_PED p
)hn on vhm.codigo = hn.codigo and hn.fecha = (select top 1 p.fecha from VH_DOCUMENTOS_PED p where codigo = vhm.codigo and fecha <= isnull(dsal.fecha_hora,getdate()) order by fecha desc)
LEFT JOIN 
    (
        select  ------------------------------------------- Entrega de vehiculo
            codigo
            ,id_evento
            ,fecha_hora_evento
        from vh_eventos_vehiculos 
        where evento in ('75','76','77')
)ev on vhm.codigo = ev.codigo and ev.id_evento = (select top 1 id_evento FROM vh_eventos_vehiculos where codigo = vhm.codigo and evento in ('75','76','77') and cast(fecha_hora_evento as [date]) >= cast(dent.fecha_hora as [date]) order by fecha_hora_evento asc)
LEFT JOIN 
    (
        select  ------------------------------------------- Vehiculos que fueron devueltos (SW = 2 en el siguiente movimiento)
            codigo,nro_mov,tipo_ent,numero_ent
        FROM v_vehiculos_mov_DH vm 
        left join documentos d on d.tipo = vm.tipo_ent and d.numero = vm.numero_ent
        where d.sw = '2'        
)vhd on vhm.codigo = vhd.codigo and vhm.nro_mov = vhd.nro_mov-1
LEFT JOIN referencias_fis rf ON 
            rf.codigo = vhm.codigo 
            and rf.bodega = dent.bodega
LEFT JOIN 
    BODEGAS_UBICACION BUP ON 
        rf.UBICACION = BUP.UBICACION 
        AND rf.bodega = BUP.bodega
--order by vhm.codigo,dent.fecha_hora



GO
