-- 💻 LABORATORIO SESIÓN 7: EL INTERROGATORIO (SQL en VS Code)
-- ═══════════════════════════════════════════════════════════════
-- Guía de Referencia: 02_Guia_S07_Antigravity.md
-- Base de Datos: Novamarket_S07.db (500 registros)
-- ═══════════════════════════════════════════════════════════════

-- ══ BLOQUE A — Exploración Inicial ═════════════════════════════

-- A1: Ver las primeras 10 transacciones de 'FactVentas'.
-- Éxito: 10 filas.
SELECT * FROM FactVentas LIMIT 10;


-- A2: Contar el total de registros en 'FactVentas'.
-- Éxito: El resultado debe ser 500.
SELECT COUNT(*) AS Total_Registros FROM FactVentas;


-- A3: Ver el diccionario de productos en 'DimProducto'.
-- Éxito: 4 filas.
SELECT * FROM DimProducto;


-- ══ BLOQUE B — Columnas y Cálculos ═════════════════════════════

-- B1: Mostrar TransaccionID, FechaID, Cantidad y Precio_Venta de 'FactVentas'.
-- Éxito: Verás solo las 4 columnas seleccionadas.
SELECT TransaccionID, FechaID, Cantidad, Precio_Venta FROM FactVentas;


-- B2: Calcular Venta_Bruta y Venta_Neta (redondeada a 2 decimales) en 'FactVentas'.
-- TIP: ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) AS Venta_Neta
SELECT 
    *, 
    (Precio_Venta * Cantidad) AS Venta_Bruta, 
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) AS Venta_Neta 
FROM FactVentas;


-- ══ BLOQUE C — Filtros WHERE (La Precisión) ═════════════════════

-- C1: Ventas realizadas en Leticia (CiudadID = 6).
-- Éxito: 76 filas.
SELECT * FROM FactVentas WHERE CiudadID = 6;


-- C2: Ventas con descuento superior al 15% (Descuento_Pct > 0.15).
-- Éxito: 46 filas.
SELECT * FROM FactVentas WHERE Descuento_Pct > 0.15;


-- C3: Ventas de Leticia CON descuento (Usa AND).
-- Éxito: 38 filas.
SELECT * FROM FactVentas WHERE CiudadID = 6 AND Descuento_Pct > 0;


-- C4: Ventas en ciudades del Caribe (Barranquilla=4, Cartagena=5).
-- Usa el operador IN: WHERE CiudadID IN (4, 5)
-- Éxito: 154 filas.
SELECT * FROM FactVentas WHERE CiudadID IN (4, 5);


-- C5: Ventas realizadas en Noviembre de 2023.
-- Usa BETWEEN: WHERE FechaID BETWEEN 20231101 AND 20231130
-- Éxito: 155 filas.
SELECT * FROM FactVentas WHERE FechaID BETWEEN 20231101 AND 20231130;


-- C6: Buscar categorías que empiecen por 'S' en 'DimProducto'.
-- Usa LIKE: WHERE Categoria LIKE 'S%'
-- Éxito: 2 filas.
SELECT * FROM DimProducto WHERE Categoria LIKE 'S%';


-- C7: ¿Hay fechas sin nombre de mes en 'DimFecha'?
-- Usa IS NULL: WHERE NombreMes IS NULL
-- Éxito: 0 filas.
-- Nota: Si la tabla DimFecha no existe, esta consulta fallará.
-- SELECT * FROM DimFecha WHERE NombreMes IS NULL;


-- ══ BLOQUE D — Orden y Límites ═════════════════════════════════

-- D1: Las 10 transacciones con mayor Costo_Envio (Ordenar DESC).
-- Éxito: El costo más alto arriba.
SELECT * FROM FactVentas ORDER BY Costo_Envio DESC LIMIT 10;


-- D2: Las 10 ventas con peor margen (Venta_Neta - Costo_Envio).
-- Ordenar ASC para ver los valores más negativos arriba.
SELECT 
    *, 
    (ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) - Costo_Envio) AS Margen_Neto 
FROM FactVentas 
ORDER BY Margen_Neto ASC 
LIMIT 10;


-- D3: Las 5 ventas de Leticia con mayor costo de envío.
SELECT * FROM FactVentas WHERE CiudadID = 6 ORDER BY Costo_Envio DESC LIMIT 5;


-- ══ BLOQUE E — Desafíos Autónomos (ENTREGABLES) ════════════════

-- E1: (Fácil) ¿Cuántas ventas hubo en Septiembre de 2023?
-- FechaID entre 20230901 y 20230930.
-- Éxito: 153 filas.
SELECT COUNT(*) AS Ventas_Septiembre FROM FactVentas WHERE FechaID BETWEEN 20230901 AND 20230930;


-- E2: (Medio) Muestra las 10 transacciones con mayor Descuento_Pct que NO sean de Leticia.
-- Columnas: TransaccionID, CiudadID, Descuento_Pct.
SELECT TransaccionID, CiudadID, Descuento_Pct FROM FactVentas WHERE CiudadID != 6 ORDER BY Descuento_Pct DESC LIMIT 10;


-- E3: (Difícil) ¿Cuántas ventas de Noviembre tuvieron descuento > 20% Y envío > 500?
-- Éxito: 6 filas.
SELECT COUNT(*) AS Ventas_Noviembre_Especiales FROM FactVentas WHERE FechaID BETWEEN 20231101 AND 20231130 AND Descuento_Pct > 0.20 AND Costo_Envio > 500;


-- ═══════════════════════════════════════════════════════════════
-- Fin del Laboratorio 07