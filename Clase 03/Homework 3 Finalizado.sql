/* 1
Aplicar alguna técnica de detección de Outliers en la tabla ventas, sobre los campos Precio y Cantidad. 
Realizar diversas consultas para verificar la importancia de haber detectado Outliers. 
Por ejemplo ventas por sucursal en un período teniendo en cuenta outliers y descartándolos.
*/

-- Se usará Regla de las Tres Sigmas para detectar los Outliers
-- mínimo = Promedio – 3 * Desviación Estándar
-- máximo = Promedio + 3 * Desviación Estándar
USE henry_m3;

-- Consulta sobre ventas, tomando en cuenta outliers de precio
SELECT @promedio_precio := AVG(precio) FROM venta;
SELECT @desvest_precio := STDDEV(Precio) FROM venta;
SELECT AVG(Precio) Promedio, MAX(Precio) Maximo, MIN(Precio) Minimo, COUNT(*) Total 
FROM venta
WHERE Precio > (@promedio_precio - 3*@desvest_precio) AND Precio < (@promedio_precio + 3*@desvest_precio)
UNION
SELECT AVG(Precio) Promedio, MAX(Precio) Maximo, MIN(Precio) Minimo, COUNT(*) Total 
FROM venta;
-- Es notable la diferencia en la consulta con los outliers y sin los outliers

-- Consulta sobre ventas, tomando en cuenta los outliers de cantidad
SELECT @promedio_cantidad := AVG(Cantidad) FROM venta;
SELECT @desvest_cantidad := STDDEV(Cantidad) FROM venta;
SELECT AVG(Cantidad) Promedio, MAX(Cantidad) Maximo, MIN(Cantidad) Minimo, COUNT(*) Total 
FROM venta
WHERE Cantidad > (@promedio_cantidad - 3*@desvest_cantidad) AND Cantidad < (@promedio_cantidad + 3*@desvest_cantidad)
UNION
SELECT AVG(Cantidad) Promedio, MAX(Cantidad) Maximo, MIN(Cantidad) Minimo, COUNT(*) Total 
FROM venta;

-- Consulta sobre venta tomando en cuenta outliers de Precio y Cantidad
SELECT @promedio_cantidad := AVG(Cantidad) FROM venta;
SELECT @desvest_cantidad := STDDEV(Cantidad) FROM venta;
SELECT @promedio_precio := AVG(precio) FROM venta;
SELECT @desvest_precio := STDDEV(Precio) FROM venta;
SELECT AVG(Cantidad) Promedio_Cantidad, AVG(Precio) Promedio_Precio,  MAX(Cantidad) Maximo_Cantidad, MAX(Precio) Maximo_Precio, MIN(Cantidad) Min_Cantidad, MIN(Precio) Min_Precio, COUNT(*) Total 
FROM venta
WHERE 
	Cantidad > (@promedio_cantidad - 3*@desvest_cantidad) AND Cantidad < (@promedio_cantidad + 3*@desvest_cantidad)
	AND Precio > (@promedio_precio - 3*@desvest_precio) AND Precio < (@promedio_precio + 3*@desvest_precio)
UNION
SELECT AVG(Cantidad) Promedio_Cantidad, AVG(Precio) Promedio_Precio,  MAX(Cantidad) Maximo_Cantidad, MAX(Precio) Maximo_Precio, MIN(Cantidad) Min_Cantidad, MIN(Precio) Min_Precio, COUNT(*) Total 
FROM venta;

SELECT * FROM venta WHERE Cantidad = 0;


/* 2
Es necesario armar un proceso, mediante el cual podamos integrar todas las fuentes, 
aplicar las transformaciones o reglas de negocio necesarias a los datos y 
generar el modelo final que va a ser consumido desde los reportes. 
 proceso debe ser claro y autodocumentado. 
 ¿Se puede armar un esquema, donde sea posible detectar con mayor facilidad futuros errores en los datos?
*/



/* 3
Elaborar 3 KPIs del negocio. 
Tener en cuenta que deben ser métricas fácilmente graficables, 
por lo tanto debemos asegurarnos de contar con los datos adecuados. 
¿Necesito tener el claro las métricas que voy a utilizar? 
¿La métrica necesaria debe tener algún filtro en especial? 
La Meta que se definió ¿se calcula con la misma métrica?
*/
		-- Beneficio Mensual: Venta - Compra - Gasto, por mes
DROP TEMPORARY TABLE IF EXISTS movimientos;
CREATE TEMPORARY TABLE movimientos (
Anio INTEGER,
Mes INTEGER,
Total DECIMAL(15,2),
Tipo CHAR
);
-- VENTAS POR MES
INSERT INTO movimientos
SELECT YEAR(Fecha) AS Anio, MONTH(Fecha) AS Mes, SUM(Precio) AS Total, 'V' Tipo
FROM venta
GROUP BY Anio, Mes
ORDER BY Anio, Mes;
-- COMPRAS POR MES
INSERT INTO movimientos
SELECT YEAR(Fecha) AS Anio, MONTH(Fecha) AS Mes, -SUM(Precio) AS Total, 'C' Tipo
FROM compra
GROUP BY Anio, Mes
ORDER BY Anio, Mes;
-- GASTOS POR MES
INSERT INTO movimientos
SELECT YEAR(Fecha) AS Anio, MONTH(Fecha) AS Mes, -SUM(Monto) AS Total, 'G' Tipo
FROM gasto
GROUP BY Anio, Mes
ORDER BY Anio, Mes;
-- BENEFICIO X MES
SELECT 
	Anio, 
    Mes, 
    SUM(Total) Total
FROM movimientos
GROUP BY 1,2
ORDER BY 1,2;

