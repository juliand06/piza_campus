-- Consulta 1
SELECT p.nombre AS producto, SUM(consolidado.total_cantidad) AS total_vendido
FROM (
    SELECT producto_id, cantidad AS total_cantidad FROM detalles_pedido WHERE producto_id IS NOT NULL
    UNION ALL
    SELECT cp.producto_id, (dp.cantidad * cp.cantidad) AS total_cantidad
    FROM detalles_pedido dp JOIN combo_producto cp ON dp.combo_id = cp.combo_id WHERE dp.combo_id IS NOT NULL
) AS consolidado
JOIN productos p ON consolidado.producto_id = p.id
GROUP BY p.id, p.nombre
ORDER BY total_vendido DESC;

-- Consulta 2
SELECT DISTINCT c.id_cliente, c.nombre, c.telefono, p.fecha_hora, p.total
FROM clientes c
JOIN pedidos p ON c.id_cliente = p.id_cliente
WHERE p.fecha_hora BETWEEN '2026-07-01 00:00:00' AND '2026-07-05 23:59:59'
ORDER BY p.fecha_hora DESC;

-- Consulta 3
SELECT tipo_entrega, COUNT(id) AS cantidad_pedidos 
FROM pedidos 
GROUP BY tipo_entrega;

-- Consulta 4
SELECT 
    pz.nombre AS nombre_pizza,
    pz.tamano,
    COUNT(dp.id_detalle) AS veces_pedida,
    SUM(dp.cantidad) AS total_unidades_vendidas
FROM pizzas pz
JOIN detalle_pedido dp ON pz.id_pizza = dp.id_pizza
JOIN pedidos p ON dp.id_pedido = p.id_pedido
WHERE p.estado != 'cancelado'
GROUP BY pz.id_pizza, pz.nombre, pz.tamano
ORDER BY total_unidades_vendidas DESC;

-- Consulta 5
SELECT p.tipo AS categoria, SUM(consolidado.total_cantidad) AS total_vendido
FROM (
    SELECT producto_id, cantidad AS total_cantidad FROM detalles_pedido WHERE producto_id IS NOT NULL
    UNION ALL
    SELECT cp.producto_id, (dp.cantidad * cp.cantidad) AS total_cantidad
    FROM detalles_pedido dp JOIN combo_producto cp ON dp.combo_id = cp.combo_id WHERE dp.combo_id IS NOT NULL
) AS consolidado
JOIN productos p ON consolidado.producto_id = p.id
GROUP BY p.tipo
ORDER BY total_vendido DESC;

-- Consulta 6
SELECT 
    r.nombre AS repartidor,
    r.zona_asignada,
    p.id_pedido,
    c.nombre AS cliente,
    c.direccion,
    d.hora_salida,
    d.hora_entrega
FROM repartidores r
JOIN domicilios d ON r.id_repartidor = d.id_repartidor
JOIN pedidos p ON d.id_pedido = p.id_pedido
JOIN clientes c ON p.id_cliente = c.id_cliente
ORDER BY r.nombre, d.hora_salida DESC;

-- Consulta 7
SELECT DAYNAME(fecha) AS dia_semana, SUM(total) AS ventas_totales 
FROM pedidos 
GROUP BY dia_semana 
ORDER BY ventas_totales DESC;

-- Consulta 8
SELECT 
    r.zona_asignada AS zona,
    COUNT(d.id_domicilio) AS total_domicilios,
    ROUND(AVG(d.distancia_km), 2) AS distancia_promedio_km,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)), 1) AS tiempo_promedio_entrega_min
FROM repartidores r
JOIN domicilios d ON r.id_repartidor = d.id_repartidor
WHERE d.hora_entrega IS NOT NULL
GROUP BY r.zona_asignada;

-- Consulta 9
SELECT DISTINCT p.id AS numero_pedido, p.fecha
FROM pedidos p
JOIN detalles_pedido dp ON p.id = dp.pedido_id
JOIN combo_producto cp ON dp.combo_id = cp.combo_id
JOIN productos pr ON cp.producto_id = pr.id
WHERE pr.tipo = 'bebida';

-- Consulta 10
SELECT 
    c.nombre AS cliente,
    c.telefono,
    COUNT(p.id_pedido) AS total_pedidos,
    SUM(p.total) AS total_gastado
FROM clientes c
JOIN pedidos p ON c.id_cliente = p.id_cliente
WHERE p.estado != 'cancelado'
GROUP BY c.id_cliente, c.nombre, c.telefono
HAVING total_gastado > 50000
ORDER BY total_gastado DESC;

-- Consulta 11
SELECT SUM(dp.cantidad * dp.precio_unitario) AS ingresos_no_elaborados
FROM detalles_pedido dp
JOIN productos pr ON dp.producto_id = pr.id
WHERE pr.es_elaborado = FALSE;

-- Consulta 12
SELECT id_pizza, nombre, tamano, precio_base, tipo
FROM pizzas
WHERE nombre LIKE '%Pepperoni%' OR nombre LIKE '%Especial%';

-- Consulta 13
SELECT SUM(dp.cantidad) AS combos_vendidos
FROM detalles_pedido dp
JOIN pedidos p ON dp.pedido_id = p.id
WHERE dp.combo_id IS NOT NULL 
  AND p.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

-- Consulta 14
SELECT c.id_cliente, c.nombre, c.telefono, c.correo_electronico
FROM clientes c
WHERE (
    SELECT COUNT(*) 
    FROM pedidos p 
    WHERE p.id_cliente = c.id_cliente 
      AND MONTH(p.fecha_hora) = 7 
      AND YEAR(p.fecha_hora) = 2026
      AND p.estado != 'cancelado'
) > 5;
-- Consulta 15
SELECT SUM(dp.cantidad) AS productos_personalizados 
FROM detalles_pedido dp 
WHERE id IN (SELECT DISTINCT detalle_pedido_id FROM pedido_adiciones);

-- Consulta 16
SELECT pedido_id, COUNT(DISTINCT IFNULL(producto_id, combo_id)) AS items_diferentes
FROM detalles_pedido
GROUP BY pedido_id
HAVING items_diferentes > 3;

-- Consulta 17
SELECT SUM(total) / COUNT(DISTINCT DATE(fecha)) AS promedio_ingresos_diarios 
FROM pedidos;

-- Consulta 18
SELECT c.nombre, 
       COUNT(DISTINCT p.id) AS total_pedidos,
       COUNT(DISTINCT CASE WHEN pr.tipo = 'pizza' AND pa.id IS NOT NULL THEN p.id END) AS pedidos_pizza_personalizada
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
LEFT JOIN detalles_pedido dp ON p.id = dp.pedido_id
LEFT JOIN productos pr ON dp.producto_id = pr.id
LEFT JOIN pedido_adiciones pa ON dp.id = pa.detalle_pedido_id
GROUP BY c.id, c.nombre
HAVING (pedidos_pizza_personalizada / total_pedidos) > 0.5;

-- Consulta 19
SELECT 
    IFNULL(ROUND((SUM(CASE WHEN pr.es_elaborado = FALSE THEN dp.cantidad * dp.precio_unitario ELSE 0 END) / 
    SUM(dp.cantidad * dp.precio_unitario)) * 100, 2), 0.00) AS porcentaje_no_elaborados
FROM detalles_pedido dp
LEFT JOIN productos pr ON dp.producto_id = pr.id
WHERE dp.producto_id IS NOT NULL;

-- Consulta 20
SELECT DAYNAME(fecha) AS dia_semana, COUNT(*) AS cantidad_pedidos
FROM pedidos
WHERE tipo_entrega = 'recoger'
GROUP BY dia_semana
ORDER BY cantidad_pedidos DESC
LIMIT 1;