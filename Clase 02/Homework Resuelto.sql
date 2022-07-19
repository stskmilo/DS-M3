-- 1.- ¿Qué tan actualizada está la información? 
-- ¿La forma en que se actualiza ó mantiene esa información se puede mejorar?
SELECT * FROM henry_m3.compra order by Fecha desc;
SELECT * FROM henry_m3.venta order by fecha desc;
-- Última fecha de compra y venta es de diciembre 2020. Puede mejorar.

-- 2.- ¿Los datos están completos en todas las tablas?
-- Hay valores NULL

-- 3.- ¿Se conocen las fuentes de los datos?
-- Si. Descrito en Homework anterior

-- 4.- Al integrar éstos datos, es prudente que haya una normalización respecto de nombrar las tablas y sus campos.
-- Es importante revisar la consistencia de los datos: 
-- ¿Se pueden relacionar todas las tablas al modelo? 
-- Si, se pueden relacionar las tablas entre si a través de sus distintos IDs
-- ¿Cuáles son las tablas de hechos y las tablas dimensionales o maestros? 
-- Tabla Venta, Compra y Gasto parecen ser las tablas transaccionales
-- ¿Podemos hacer esa separación en los datos que tenemos (tablas de hecho y dimensiones)? 
-- ¿Hay claves duplicadas? 
-- Si, se puede ver que hay 17 IDs de empleados duplicados

SELECT * FROM empleado 
GROUP BY IDEmpleado
HAVING COUNT(IDEmpleado) > 1;
ALTER TABLE empleado CHANGE IDEmpleado IDEmpleado_Old INTEGER;
ALTER TABLE empleado ADD IDEmpleado INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE `henry_m3`.`empleado` 
CHANGE COLUMN `IDEmpleado` `IDEmpleado` INT NOT NULL AUTO_INCREMENT FIRST;
-- Se conserva el id antiguo por precaución

-- ¿Cuáles son variables cualitativas y cuáles son cuantitativas? 
-- ¿Qué acciones podemos aplicar sobre las mismas?

-- 6.- Normalizar los nombres de los campos y colocar el tipo de dato adecuado para cada uno en cada una de las tablas. 
-- Descartar columnas que consideres que no tienen relevancia.
-- Tabla cliente. Se renombre ID a IDCliente y se elimina columna col10
ALTER TABLE henry_m3.cliente DROP COLUMN col10;
ALTER TABLE henry_m3.cliente CHANGE ID IDCliente INT;
-- Tabla empleado. Se renombre Salario2 a Salario y se cambia tipo de dato de Salario
ALTER TABLE henry_m3.empleado CHANGE Salario2 Salario varchar(30);
UPDATE empleado SET Salario = REPLACE(Salario,',','.');
ALTER TABLE empleado MODIFY COLUMN Salario DECIMAL(10,2);
-- Tabla venta. Se cambia tipo de dato de Precio y Cantidad
-- Para modificar el tipo de dato se tuvo que crear una tabla nueva temporal, 
-- pasar los datos a esta tabla como float, convertirlos a decimal, luego pasarlos a la tabla
-- original y finalmente cambiar el tipo de dato. Haciéndolo directo causaba error.
ALTER TABLE venta ADD COLUMN Precio_Nuevo DECIMAL(10,2);
UPDATE venta SET Precio_Nuevo = CAST(Precio AS FLOAT);
UPDATE venta SET Precio = CAST(Precio_Nuevo AS DECIMAL(10,2));
ALTER TABLE venta MODIFY COLUMN Precio DECIMAL(10,2);
ALTER TABLE venta DROP COLUMN Precio_Nuevo;

-- La columna Cantidad tiene strings vacíos (31 registros)
SELECT * FROM venta WHERE cantidad = '';

-- Se cambia el valor de Cantidad para estos registros
SET SQL_SAFE_UPDATES = 0;
UPDATE venta
LEFT JOIN producto
ON venta.IDProducto = producto.IDProducto
SET Cantidad = Precio/(producto.Precio2)
WHERE venta.Cantidad = '';

-- Se eliminan los productos llamados producto
DELETE FROM producto
WHERE concepto LIKE 'Producto%';
-- Se cambia el nombre de la columna Precio2 de producto a Precio y se cambia el tipo de dato a DECIMAL(10,2)
ALTER TABLE producto CHANGE Precio2 Precio DECIMAL(10,2);

-- Se cambia el tipo de dato de Edad en tabla cliente
ALTER TABLE cliente MODIFY COLUMN Edad INTEGER;

-- 7.- Buscar valores faltantes y campos inconsistentes en las tablas 
-- sucursal, proveedor, empleado y cliente. 
-- De encontrarlos, deberás corregirlos o desestimarlos. 
-- Propone y realiza una acción correctiva sobre ese problema.
-- sucursal está bien
-- empleado está bien
-- proveedor: se elimina proveedor 8, ya que es duplicado de 'Fletes y Logistica', se renombre Proveedor1
DELETE FROM proveedor WHERE IDProveedor = 8;
UPDATE proveedor SET Nombre = 'Proveedor 1' WHERE IDProveedor = 1;
-- En la tabla cliente se ven campos vacíos

-- 8.- Chequear la consistencia de los campos precio y cantidad de la tabla de ventas.
-- Ya realizado anteriormente

-- 9.- Utilizar la funcion provista 'UC_Words' para modificar a letra capital 
-- los campos que contengan descripciones para todas las tablas.UC_Words
UPDATE cliente SET Nombre_y_Apellido = UC_Words(Nombre_y_Apellido);
UPDATE cliente SET Domicilio = UC_Words(Domicilio);
UPDATE cliente SET Localidad = UC_Words(Localidad);
UPDATE producto SET Concepto = UC_Words(Concepto);
UPDATE producto SET Tipo = UC_Words(Tipo);
UPDATE proveedor SET Nombre = UC_Words(Nombre);
UPDATE proveedor SET Domicilio = UC_Words(Domicilio);
UPDATE proveedor SET Ciudad = UC_Words(Ciudad);
UPDATE proveedor SET Provincia = UC_Words(Provincia);
UPDATE proveedor SET Pais = UC_Words(Pais);
UPDATE proveedor SET Departamento = UC_Words(Departamento);

-- 10.- Chequear que no haya claves duplicadas, y de encontrarla en alguna de las tablas, proponer una solución
-- En la tabla de empleados había y se solucionó creando una nueva clave, conservando la anterior
SELECT * FROM empleado
WHERE IDEmpleado_Old IN(
SELECT IDEmpleado_Old FROM henry_m3.empleado
GROUP BY IDEmpleado_Old HAVING count(*) > 1)
ORDER BY IDEmpleado_Old ASC;

-- 11.- Generar dos nuevas tablas a partir de la tabla 'empleado' que contengan las entidades Cargo y Sector
CREATE TABLE cargo(
Tipo VARCHAR(50)
);
INSERT INTO cargo
SELECT DISTINCT Cargo FROM empleado;

CREATE TABLE sector(
Area VARCHAR(50)
);
INSERT INTO sector
SELECT DISTINCT Sector FROM empleado;

-- 12.- Generar una nueva tabla a partir de la tabla 'producto' que contenga la entidad Tipo de Producto
CREATE TABLE tipo_producto(
Tipo VARCHAR(50)
);
INSERT INTO tipo_producto
SELECT DISTINCT Tipo FROM producto;

-- 13.- Es necesario contar con una tabla de localidades del país con el fin de evaluar la apertura 
-- de una nueva sucursal y mejorar nuestros datos. 
-- A partir de los datos en las tablas cliente, sucursal y proveedor hay que generar una tabla definitiva 
-- de Localidades y Provincias. Utilizando la nueva tabla de Localidades controlar y corregir (Normalizar) 
-- los campos Localidad y Provincia de las tablas cliente, sucursal y proveedor.
DROP TABLE ubicacion;
CREATE TABLE ubicacion(
localidad VARCHAR(100),
provincia VARCHAR(50)
);
-- cliente: localidad provincia
-- sucursal: localidad provincia
-- proveedor: provincia
INSERT INTO ubicacion
SELECT Localidad, Provincia
FROM cliente WHERE Localidad != '' OR Provincia != ''
UNION
SELECT Localidad, Provincia
FROM sucursal WHERE Localidad != '' OR Provincia != ''
UNION
SELECT Ciudad, Provincia
FROM proveedor WHERE Ciudad != '' OR Provincia != '';

-- 14.- Es necesario discretizar el campo edad en la tabla cliente.
SELECT DISTINCT edad FROM cliente order by edad asc;
-- Las edades van de 15 a 65, hay 51 edades posibles, sin embargo, se elige un rango personalizado
-- Rangos: 0: [-17]; 1: [18-35]; 2: [36-53]; 3: [54-71]; 4: [71+]
ALTER TABLE cliente ADD COLUMN edad_disc INTEGER;
UPDATE cliente
SET edad_disc = CASE 
	WHEN edad <= 17 THEN 0
    WHEN edad >=18 and edad <=35 THEN 1
    WHEN edad >=36 and edad <=53 THEN 2
    WHEN edad >=54 and edad <=71 THEN 3
    WHEN edad >71 THEN 4
    END;