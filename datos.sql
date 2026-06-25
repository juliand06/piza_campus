INSERT INTO clientes (nombre, telefono) VALUES ('Julian R', '3001234567');
INSERT INTO ingredientes (nombre) VALUES ('Masa'), ('Queso'), ('Pepperoni');
INSERT INTO productos (nombre, tipo, precio, es_elaborado) VALUES 
('Pizza Pepperoni', 'pizza', 25000.00, TRUE), 
('Gaseosa', 'bebida', 4000.00, FALSE);

INSERT INTO producto_ingrediente (producto_id, ingrediente_id) VALUES (1, 1), (1, 2), (1, 3);


INSERT INTO adiciones (nombre, precio) VALUES ('Borde de Queso', 5000.00);
INSERT INTO combos (nombre, precio) VALUES ('Combo Estudiante (1 Pizza + 1 Gaseosa)', 26000.00);
INSERT INTO combo_producto (combo_id, producto_id, cantidad) VALUES (1, 1, 1), (1, 2, 1);

INSERT INTO pedidos (cliente_id, tipo_entrega) VALUES (1, 'local');
INSERT INTO detalles_pedido (pedido_id, combo_id, cantidad, precio_unitario) VALUES (1, 1, 1, 26000.00);
INSERT INTO detalles_pedido (pedido_id, producto_id, cantidad, precio_unitario) VALUES (1, 1, 1, 25000.00);
INSERT INTO pedido_adiciones (detalle_pedido_id, adicion_id, cantidad, precio_unitario) VALUES (2, 1, 1, 5000.00);
	