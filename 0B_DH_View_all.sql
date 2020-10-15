select 
    isnull(s.bodega,sto.bodega) as bodega
    ,vh.codigo
    ,vh.marca
    ,vh.plan_venta
    --,case when vhf.codigo is null then 0 else 1 end as Facturado
    ,cast(s.can_vta as int) as Factura
    ,cast(s.can_dev_com as int) as DevCompra
    ,cast(s.can_dev_vta as int) as DevVenta
    ,cast(s.can_otr_sal as int) as Salida
    ,cast(isnull(sto.stock,0) as int) as Stock
    ,(select top 1 d.fec from documentos_lin d where tipo in ('CU','CV') and d.codigo = vh.codigo and fec < DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,cast(cast(case when sto.stock=1 then year(getdate()) else s.ano end as [varchar])+'/'+cast(case when sto.stock=1 then month(getdate()) else s.mes end as [varchar])+'/15' as [date]))+1,0)) order by fec desc)
    ,(cast(s.ano as [varchar])+'/'+cast(s.mes as [varchar])) as Ult_Mov
from V_VH_VEHICULOS VH 
left join 
    REFERENCIAS_STO s ON ----------------- Datos de cada proceso del vehiculo (Facturado/Devuelto/Salida) *-* Varias lineas
        S.CODIGO = VH.CODIGO
        and (s.can_vta > 0 or s.can_dev_com > 0 or s.can_otr_sal > 0) 
left join 
    V_REFERENCIAS_STO_HOY sto on  -------- Stock actual del vehiculo
        vh.codigo = sto.codigo 
        and stock > 0
/*LEFT JOIN 
    VH_DOCUMENTOS_PED VDP ON 
        vh.CODIGO = VDP.CODIGO*/
where 
    vh.codigo in (select distinct codigo from documentos_lin where tipo in ('CU','CV')) --TODOS LOS VEHICULOS COMPRADOS
    --and vh.codigo in (select distinct codigo from documentos_lin where tipo in ('DCVU','DCV'))
order by s.bodega desc
--***************************************************************
SELECT 
    VH.MODELO
    ,VH.des_modelo
    ,VH.PLAN_VENTA
    ,VVE.FECHA_HORA_EVENTO AS FECHA_EVENTO
    ,CASE 
        WHEN VH.PLAN_VENTA = 2 AND VH.USADO_COMPRADO = 1 THEN 'USADO COMPRADO'
        WHEN VH.PLAN_VENTA = 2 AND VH.USADO_RETOMADO = 1 THEN 'USADO RETOMADO'
        WHEN VH.PLAN_VENTA = 2 AND VH.USADO_CONSIGNADO = 1 THEN 'USADO CONSIGNADO' 
        ELSE 'NUEVO' 
    END AS NUEVO_USADO
    ,VH.CODIGO AS VIN
    ,VH.DESCRIPCION
    ,VH.DES_COLOR AS COLOR
    ,VH.MODELO_ANO AS MODELO_ANO
    ,CASE 
        WHEN VH.ENTREGADO_CLIENTE IS NULL AND VH.ASIGNACION IS NULL and VH.grupo='D' THEN 'DEMOCAR'
        WHEN VH.VENDIDO IS NULL AND VH.ENTREGADO_CLIENTE IS NULL AND VH.ASIGNACION IS NULL AND VS.stock>0 THEN 'DISPONIBLE'
        WHEN VH.VENDIDO IS NULL AND VH.ENTREGADO_CLIENTE IS NULL AND VH.ASIGNACION IS NOT NULL THEN 'ASIGNADO'
        WHEN VH.VENDIDO = 1 AND VH.FECHA_VENTA IS NOT NULL AND VH.ENTREGADO_CLIENTE IS NULL THEN 'FACTURADO NO ENTREGADO' 
        WHEN VH.VENDIDO = 1 AND VH.FECHA_VENTA IS NOT NULL AND VH.ENTREGADO_CLIENTE IS NOT NULL THEN 'FACTURADO ENTREGADO'
        ELSE 'NA' 
    END AS ESTADO
    ,BUP.DESCRIPCION AS UBICACION
    ,VH.DES_MARCA AS MARCA
    ,VH.MOTOR
    ,VH.COSTO_UNITARIO AS COSTO
    ,VH.PORCENTAJE_IVA_COMPRA AS IVA
    ,vh.fecha_venta as fecha_ult_venta
    
    ,VDP.VENDEDOR
    ,vs.bodega
    ,vs.stock
    ,vh.asignacion
    ,VH.ENTREGADO_CLIENTE
    ,VH.VENDIDO
    ,case 
        when VH.PLAN_VENTA=VDP.plan_venta AND VH.Codigo<>'1C4AJCAB1ED764510' THEN VDP.NUMERO 
        ELSE VH.asignacion 
    END AS NEGOCIO
    ,VH.PLACA
    ,BUP.*
FROM V_REFERENCIAS_STO_HOY VS
INNER JOIN V_VH_VEHICULOS VH ON VS.CODIGO = VH.CODIGO
INNER JOIN VH_EVENTOS_VEHICULOS VVE ON VS.CODIGO = VVE.CODIGO
LEFT JOIN VH_DOCUMENTOS_PED VDP ON VS.CODIGO = VDP.CODIGO
LEFT JOIN referencias_fis rf ON RF.codigo=VS.codigo and rf.bodega = vs.bodega
LEFT JOIN BODEGAS_UBICACION BUP ON rf.UBICACION = BUP.UBICACION AND rf.bodega = BUP.bodega
/*LEFT JOIN 
(
    select distinct s.bodega,v.codigo from REFERENCIAS_STO s, v_vh_vehiculos v where s.can_vta <> 0 and s.codigo = v.codigo
)sto ON VS.BODEGA = STO.BODEGA and vs.codigo = sto.codigo*/
WHERE 
    VS.BODEGA in (6,9,17) 
    AND VVE.EVENTO in ('00') 

--*********************************************
select * from v_referencias_sto_hoy where codigo = '1C4RJFDJ1KC799864' order by ano,mes
select * from referencias_sto where codigo = '1C4AJCAB4ED696784' order by ano,mes

select * from auditoria where que like '%3C4PDCCBXJT511804%' order by fecha

select distinct tipo from documentos_lin where sw=4

select codigo from vh_eventos_vehiculos where evento = '45' group by codigo having count(codigo) > 1

select distinct v.codigo from documentos_lin d,v_vh_vehiculos v where d.tipo = 'G' and d.codigo = v.codigo