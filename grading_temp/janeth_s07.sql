
-- 💻 LABORATORIO SESIÓN 7: EL INTERROGATORIO (SQL en VS Code)
-- ═══════════════════════════════════════════════════════════════
-- Guía de Referencia: 02_Guia_S07_Antigravity.md
-- Base de Datos: Novamarket_S07.db (500 registros)
-- ═══════════════════════════════════════════════════════════════

-- ══ BLOQUE A — Exploración Inicial ═════════════════════════════

-- A1: Ver las primeras 10 transacciones de 'FactVentas'.
-- Éxito: 10 filas.


-- A2: Contar el total de registros en 'FactVentas'.
-- Éxito: El resultado debe ser 500.


-- A3: Ver el diccionario de productos en 'DimProducto'.
-- Éxito: 4 filas.


-- ══ BLOQUE B — Columnas y Cálculos ═════════════════════════════

-- B1: Mostrar TransaccionID, FechaID, Cantidad y Precio_Venta de 'FactVentas'.
-- Éxito: Verás solo las 4 columnas seleccionadas.


-- B2: Calcular Venta_Bruta y Venta_Neta (redondeada a 2 decimales) en 'FactVentas'.
-- TIP: ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) AS Venta_Neta


-- ══ BLOQUE C — Filtros WHERE (La Precisión) ═════════════════════

-- C1: Ventas realizadas en Leticia (CiudadID = 6).
-- Éxito: 76 filas.


-- C2: Ventas con descuento superior al 15% (Descuento_Pct > 0.15).
-- Éxito: 46 filas.


-- C3: Ventas de Leticia CON descuento (Usa AND).
-- Éxito: 38 filas.


-- C4: Ventas en ciudades del Caribe (Barranquilla=4, Cartagena=5).
-- Usa el operador IN: WHERE CiudadID IN (4, 5)
-- Éxito: 154 filas.


-- C5: Ventas realizadas en Noviembre de 2023.
-- Usa BETWEEN: WHERE FechaID BETWEEN 20231101 AND 20231130
-- Éxito: 155 filas.


-- C6: Buscar categorías que empiecen por 'S' en 'DimProducto'.
-- Usa LIKE: WHERE Categoria LIKE 'S%'
-- Éxito: 2 filas.


-- C7: ¿Hay fechas sin nombre de mes en 'DimFecha'?
-- Usa IS NULL: WHERE NombreMes IS NULL
-- Éxito: 0 filas.


-- ══ BLOQUE D — Orden y Límites ═════════════════════════════════

-- D1: Las 10 transacciones con mayor Costo_Envio (Ordenar DESC).
-- Éxito: El costo más alto arriba.


-- D2: Las 10 ventas con peor margen (Venta_Neta - Costo_Envio).
-- Ordenar ASC para ver los valores más negativos arriba.


-- D3: Las 5 ventas de Leticia con mayor costo de envío.


-- ══ BLOQUE E — Desafíos Autónomos (ENTREGABLES) ════════════════

-- E1: (Fácil) ¿Cuántas ventas hubo en Septiembre de 2023?
-- FechaID entre 20230901 y 20230930.
-- Éxito: 153 filas.


-- E2: (Medio) Muestra las 10 transacciones con mayor Descuento_Pct que NO sean de Leticia.
-- Columnas: TransaccionID, CiudadID, Descuento_Pct.


-- E3: (Difícil) ¿Cuántas ventas de Noviembre tuvieron descuento > 20% Y envío > 500?
-- Éxito: 6 filas.


-- ═══════════════════════════════════════════════════════════════
-- Fin del Laboratorio 07
SELECT 'DimProducto' AS Tabla, COUNT(*) AS Registros FROM DimProducto
UNION ALL SELECT 'DimCiudad',  COUNT(*) FROM DimCiudad
UNION ALL SELECT 'DimFecha',   COUNT(*) FROM DimFecha
UNION ALL SELECT 'FactVentas', COUNT(*) FROM FactVentas;


SELECT * FROM FactVentas LIMIT 10;
SELECT COUNT(*) AS Total_Transacciones FROM FactVentas;

SELECT CiudadID, COUNT(*) AS Transacciones
FROM FactVentas
GROUP BY CiudadID
ORDER BY Transacciones DESC;


SELECT
    Nombre AS Producto,
    Categoria,
    Precio_Unitario,
    Costo_Unitario,
    (Precio_Unitario - Costo_Unitario) AS Margen_Bruto,
    ROUND((Precio_Unitario - Costo_Unitario)
          / Precio_Unitario * 100, 1) AS Margen_Pct
FROM DimProducto
ORDER BY Margen_Pct DESC;

PRAGMA table_info(DimProducto);
PRAGMA table_info(DimCiudad);
SELECT * FROM DimProducto;
PRAGMA table_info(FactVentas);


-- Productos disponibles
SELECT ProductoID, Producto, Categoria
FROM DimProducto
ORDER BY Categoria;
sql-- Ciudades disponibles
SELECT CiudadID, Ciudad, Region
FROM DimCiudad
ORDER BY CiudadID;



SELECT 
    CiudadID,
    ROUND(AVG(Costo_Envio), 2) AS Costo_Envio_Promedio,
    MIN(Costo_Envio) AS Costo_Minimo,
    MAX(Costo_Envio) AS Costo_Maximo
FROM FactVentas
WHERE CiudadID = 6;



SELECT
    TransaccionID,
    CiudadID,
    Cantidad,
    Precio_Venta,
    Descuento_Pct,
    (Precio_Venta * Cantidad)                               AS Venta_Bruta,
    (Precio_Venta * Cantidad * Descuento_Pct)               AS Descuento_Monto,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) AS Venta_Neta
FROM FactVentas
LIMIT 20;

SELECT COUNT(*) AS Transacciones_Leticia
FROM FactVentas
WHERE CiudadID = 6;

SELECT
    TransaccionID, FechaID, CiudadID, Descuento_Pct,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) AS Venta_Neta
FROM FactVentas
WHERE Descuento_Pct > 0.15
ORDER BY Descuento_Pct DESC;


SELECT TransaccionID, CiudadID, Costo_Envio
FROM FactVentas
WHERE CiudadID IN (4, 5)
ORDER BY CiudadID, Costo_Envio DESC
LIMIT 15;

SELECT COUNT(*) AS Ventas_Noviembre
FROM FactVentas
WHERE FechaID BETWEEN 20231101 AND 20231130;

SELECT COUNT(*) AS Dias_Con_Evento
FROM DimFecha
WHERE Evento_Especial IS NOT NULL;


SELECT FechaID, Fecha, Evento_Especial
FROM DimFecha
WHERE Evento_Especial IS NOT NULL;


SELECT TransaccionID, CiudadID, Costo_Envio, Precio_Venta, Cantidad
FROM FactVentas
ORDER BY Costo_Envio DESC
LIMIT 10;


SELECT
    TransaccionID,
    CiudadID,
    Precio_Venta,
    Cantidad,
    Descuento_Pct,
    Costo_Envio,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct) - Costo_Envio, 2)
        AS Margen_Aproximado
FROM FactVentas
ORDER BY Margen_Aproximado ASC
LIMIT 10;

— Combinando todo: las 5 ventas de Leticia con mayor costo
SELECT
    TransaccionID,
    FechaID,
    ProductoID,
    Cantidad,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) AS Venta_Neta,
    Costo_Envio,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct) - Costo_Envio, 2)
        AS Margen_Aproximado
FROM FactVentas
WHERE CiudadID = 6
ORDER BY Costo_Envio DESC
LIMIT 5;


SELECT COUNT(*) AS total_ventas
FROM  FactVentas
WHERE FechaID BETWEEN 20230901 AND 20230930;