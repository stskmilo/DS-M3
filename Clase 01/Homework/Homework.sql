CREATE DATABASE pablollc;
USE pablollc;
SHOW TABLES;

-- Se importa CSV cliente usando python
/*
import pandas as pd
from sqlalchemy import create_engine
import pymysql

clientes = pd.read_csv('Clientes.csv',delimiter=';',index_col=0)

sqlEngine = create_engine('mysql+pymysql://pruebas:pruebas123@127.0.0.1/pablollc', pool_recycle=3600)
dbConnection = sqlEngine.connect()
tableName = 'cliente'

try:
    frame = clientes.to_sql(tableName, dbConnection, if_exists='replace')
except ValueError as vx:
    print(vx)
except Exception as ex:   
    print(ex)
else:
    print("Table %s created successfully."%tableName);   
finally:
    dbConnection.close()
*/
ALTER TABLE cliente 
ADD PRIMARY KEY (ID);
ALTER TABLE cliente MODIFY ID INTEGER;
ALTER TABLE cliente DROP COLUMN col10; -- No me había dado cuenta de esta columna innecesaria

-- Se importa CSV compra usando el wizard
ALTER TABLE compra 
ADD PRIMARY KEY (IdCompra);

-- Se importa CSV gasto usando el wizard
ALTER TABLE gasto
ADD PRIMARY KEY (IdGasto);

-- Se importa CSV sucursal usando el wizard
-- El archivo CSV se tiene que cambiar de .CSV(MS-DOS) a .CSV para que detecte los acentos
ALTER TABLE sucursal RENAME COLUMN ï»¿ID TO ID;
ALTER TABLE sucursal
ADD PRIMARY KEY (ID);

-- Se importa CSV tiposdegasto usando el wizard
ALTER TABLE tipodegasto
ADD PRIMARY KEY (IdTipoGasto);

-- Se importa CSV venta usando el wizard
ALTER TABLE venta
ADD PRIMARY KEY (IdVenta);

-- Se abre archivo canaldeventa.xlsx, se guarda como csv y se importa usando el wizard
ALTER TABLE canaldeventa
ADD PRIMARY KEY (CODIGO);

-- El archivo productos.xlsx se importará de otra forma para practicar
-- Se crea la tabla producto
CREATE TABLE producto (
	IdProducto INT NOT NULL,
    Concepto VARCHAR(100),
    Tipo VARCHAR(20),
    Precio FLOAT,
    PRIMARY KEY(IdProducto)
);
-- Se guarda el xlsx en un csv y importa usando el wizard

-- El archivo proveedores se importará mediante python
/*
from sqlalchemy import create_engine
import pymysql

sqlEngine = create_engine('mysql+pymysql://pruebas:pruebas123@127.0.0.1/pablollc', pool_recycle=3600)
dbConnection = sqlEngine.connect()
tableName = 'proveedor'

try:
    frame = proveedores.to_sql(tableName, dbConnection, if_exists='replace')
except ValueError as vx:
    print(vx)
except Exception as ex:   
    print(ex)
else:
    print("Table %s created successfully."%tableName);   
finally:
    dbConnection.close()
*/
ALTER TABLE proveedor
ADD PRIMARY KEY (IDProveedor);
ALTER TABLE proveedor MODIFY IDProveedor INTEGER;

-- El archivo empleados también se importará usando python
/*
sqlEngine = create_engine('mysql+pymysql://pruebas:pruebas123@127.0.0.1/pablollc', pool_recycle=3600)
dbConnection = sqlEngine.connect()
tableName = 'empleado'

try:
    frame = empleados.to_sql(tableName, dbConnection, if_exists='replace')
except ValueError as vx:
    print(vx)
except Exception as ex:   
    print(ex)
else:
    print("Table %s created successfully."%tableName);   
finally:
    dbConnection.close()
*/
ALTER TABLE empleado MODIFY ID_empleado INT;

-- Ahora falta agregar las foreign keys para tener la BD estructurada
-- Tabla compra: FK IdProducto -> Producto IdProducto		FK IdProveedor -> Proveedor IDProveedor
ALTER TABLE compra
ADD FOREIGN KEY (IdProveedor) REFERENCES proveedor(IDProveedor);
ALTER TABLE compra
ADD FOREIGN KEY (IdProducto) REFERENCES producto(IdProducto);

-- Tabla empleado: FK Sucursal -> sucursal Sucursal
ALTER TABLE empleado
ADD FOREIGN KEY (Sucursal) REFERENCES sucursal(Sucursal);

-- Tabla gasto: FK IdSucursal -> sucursal(IdSucursal)		FK IdTipoGasto -> tipodegasto IdTipoGasto
ALTER TABLE gasto
ADD FOREIGN KEY(IdSucursal) REFERENCES sucursal(ID),
ADD FOREIGN KEY(IdTipoGasto) REFERENCES tipodegasto(IdTipoGasto);

-- Tabla venta: FK IdCanal -> canaldeventa(CODIGO)		FK IdCliente FK IdSucursal FK IdEmpleado FK IdProducto
ALTER TABLE venta
ADD FOREIGN KEY(IdCanal) REFERENCES canaldeventa(CODIGO),
ADD FOREIGN KEY(IdCliente) REFERENCES cliente(ID),
ADD FOREIGN KEY(IdSucursal) REFERENCES sucursal(ID),
ADD FOREIGN KEY(IdEmpleado) REFERENCES empleado(ID_empleado),
ADD FOREIGN KEY(IdProducto) REFERENCES producto(IdProducto);









