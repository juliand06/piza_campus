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

SELECT c.nombre AS combo, SUM(dp.cantidad * dp.precio_unitario) AS ingresos_totales 
FROM detalles_pedido dp 
JOIN combos c ON dp.combo_id = c.id 
GROUP BY c.id, c.nombre
ORDER BY ingresos_totales DESC;

SELECT tipo_entrega, COUNT(id) AS cantidad_pedidos 
FROM pedidos 
GROUP BY tipo_entrega;

SELECT a.nombre AS adicion, SUM(pa.cantidad) AS total_solicitadas 
FROM pedido_adiciones pa 
JOIN adiciones a ON pa.adicion_id = a.id 
GROUP BY a.id, a.nombre 
ORDER BY total_solicitadas DESC;

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

SELECT c.nombre AS cliente, 
       IFNULL(SUM(v.cantidad_pizzas) / COUNT(DISTINCT p.id), 0) AS promedio_pizzas_por_pedido
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
LEFT JOIN (
    SELECT dp.pedido_id, SUM(dp.cantidad) AS cantidad_pizzas
    FROM detalles_pedido dp
    JOIN productos pr ON dp.producto_id = pr.id
    WHERE pr.tipo = 'pizza'
    GROUP BY dp.pedido_id
) v ON p.id = v.pedido_id
GROUP BY c.id, c.nombre;

SELECT DAYNAME(fecha) AS dia_semana, SUM(total) AS ventas_totales 
FROM pedidos 
GROUP BY dia_semana 
ORDER BY ventas_totales DESC;

SELECT SUM(dp.cantidad) AS panzarottis_con_extra_queso
FROM detalles_pedido dp
JOIN productos pr ON dp.producto_id = pr.id
JOIN pedido_adiciones pa ON dp.id = pa.detalle_pedido_id
JOIN adiciones a ON pa.adicion_id = a.id
WHERE pr.tipo = 'panzarotti' AND a.nombre LIKE '%queso%';

SELECT DISTINCT p.id AS numero_pedido, p.fecha
FROM pedidos p
JOIN detalles_pedido dp ON p.id = dp.pedido_id
JOIN combo_producto cp ON dp.combo_id = cp.combo_id
JOIN productos pr ON cp.producto_id = pr.id
WHERE pr.tipo = 'bebida';

SELECT c.nombre, COUNT(p.id) AS total_pedidos
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY c.id, c.nombre
HAVING total_pedidos > 5;

SELECT SUM(dp.cantidad * dp.precio_unitario) AS ingresos_no_elaborados
FROM detalles_pedido dp
JOIN productos pr ON dp.producto_id = pr.id
WHERE pr.es_elaborado = FALSE;

SELECT 
    IFNULL((SELECT SUM(cantidad) FROM pedido_adiciones), 0) / 
    (SELECT COUNT(*) FROM pedidos) AS promedio_adiciones_por_pedido;

SELECT SUM(dp.cantidad) AS combos_vendidos
FROM detalles_pedido dp
JOIN pedidos p ON dp.pedido_id = p.id
WHERE dp.combo_id IS NOT NULL 
  AND p.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

SELECT c.nombre AS cliente
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre
HAVING COUNT(DISTINCT p.tipo_entrega) = 2;

SELECT SUM(dp.cantidad) AS productos_personalizados 
FROM detalles_pedido dp 
WHERE id IN (SELECT DISTINCT detalle_pedido_id FROM pedido_adiciones);

SELECT pedido_id, COUNT(DISTINCT IFNULL(producto_id, combo_id)) AS items_diferentes
FROM detalles_pedido
GROUP BY pedido_id
HAVING items_diferentes > 3;

SELECT SUM(total) / COUNT(DISTINCT DATE(fecha)) AS promedio_ingresos_diarios 
FROM pedidos;

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

SELECT 
    IFNULL(ROUND((SUM(CASE WHEN pr.es_elaborado = FALSE THEN dp.cantidad * dp.precio_unitario ELSE 0 END) / 
    SUM(dp.cantidad * dp.precio_unitario)) * 100, 2), 0.00) AS porcentaje_no_elaborados
FROM detalles_pedido dp
LEFT JOIN productos pr ON dp.producto_id = pr.id
WHERE dp.producto_id IS NOT NULL;

SELECT DAYNAME(fecha) AS dia_semana, COUNT(*) AS cantidad_pedidos
FROM pedidos
WHERE tipo_entrega = 'recoger'
GROUP BY dia_semana
ORDER BY cantidad_pedidos DESC
LIMIT 1;