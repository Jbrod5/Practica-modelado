-- Jorge Anibal Bravo Rodríguez 20213182

DROP DATABASE IF EXISTS tiendas_database; 
CREATE DATABASE tiendas_database; 
USE tiendas_database; 


CREATE TABLE PROVEEDOR(
    id INT NOT NULL AUTO_INCREMENT,
    telefono INT NOT NULL,
    direccion VARCHAR(45),
    habilitado TINYINT(1),

    PRIMARY KEY (id)
);

CREATE TABLE PROVEEDORES(
    -- funciona como un array de proveedores, todos los que respondan al mismo id proveen un producto, por eso no hay constraint de id 
    id INT NOT NULL, 
    id_proveedor INT NOT NULL,    

    CONSTRAINT PROVEEDOR UNIQUE (id, id_proveedor),
    CONSTRAINT FK_PROVEEDORES_TO_PROVEEDOR FOREIGN KEY (id_proveedor) REFERENCES PROVEEDOR(id)
);

CREATE TABLE PRODUCTO(
    codigo INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(45) NOT NULL,
    costo INT NOT NULL,
    precio INT NOT NULL,
    existencias INT NOT NULL,
    multiplos INT NOT NULL,
    habilitado TINYINT(1),
    id_proveedores INT NOT NULL,

    PRIMARY KEY (codigo),
    CONSTRAINT FK_PRODUCTO_TO_PROVEEDORES FOREIGN KEY (id_proveedores) REFERENCES PROVEEDORES(id)
);



CREATE TABLE TIENDA(
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(45) NOT NULL,
    direccion VARCHAR(45) NOT NULL,
    tipo VARCHAR(20) NOT NULL,

    PRIMARY KEY(id)
);

CREATE TABLE TIENDA_SUPERVISADA(
    id_tienda INT NOT NULL,
    aprobado_por_supervisor TINYINT(1),
    puede_pedir TINYINT(1),

    PRIMARY KEY (id_tienda),
    CONSTRAINT FK_TDSUPERVISADA_TO_TIENDA FOREIGN KEY (id_tienda) REFERENCES TIENDA(id)

);

CREATE TABLE EXISTENCIAS_DANADAS(
    id INT NOT NULL AUTO_INCREMENT,
    costo_dano INT NOT NULL, 
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT FK_EXISDAN_TO_PRODUCTO FOREIGN KEY (id_producto) REFERENCES PRODUCTO(codigo)
);

CREATE TABLE EXISTENCIAS_TIENDA(
    id INT NOT NULL AUTO_INCREMENT,
    codigo_producto INT NOT NULL,
    id_tienda INT NOT NULL,
    direccion VARCHAR(45) NOT NULL, -- obtiene la direccion desde el id_tienda
    cantidad INT NOT NULL,
    habilitado TINYINT(1),

    PRIMARY KEY (id),
    CONSTRAINT FK_EXISTIEN_TO_PRODUCTO FOREIGN KEY (codigo_producto) REFERENCES PRODUCTO(codigo),
    CONSTRAINT FK_EXISTIEN_TO_TIENDAID FOREIGN KEY (id_tienda) REFERENCES TIENDA (id),
    
    --    CONSTRAINT FK_EXISTIEN_TO_TIENDADIR FOREIGN KEY (direccion) REFERENCES TIENDA (direccion),

    CONSTRAINT TIENDAUNIQUE UNIQUE(codigo_producto, id_tienda)
);


CREATE TABLE PRODUCTO_A_PEDIR(
    id INT NOT NULL,  -- funciona como un array de productos, todos los que respondan al mismo id proveen un producto, por eso no hay constraint de id
    id_producto INT NOT NULL, 
    cantidad INT NOT NULL, 

    CONSTRAINT UNIQUEID_PROD UNIQUE(id, id_producto),
    CONSTRAINT FK_PRODPED_TO_PRODUCTO FOREIGN KEY (id_producto) REFERENCES PRODUCTO(codigo)
);


CREATE TABLE PEDIDOS(
    id INT NOT NULL AUTO_INCREMENT,
    id_tienda INT NOT NULL, 
    direccion VARCHAR(45) NOT NULL,
    id_producto_a_pedir INT NOT NULL, -- referencia a una serie de tuplas con el mismo id 
    fecha DATETIME NOT NULL,
    estado VARCHAR(25) NOT NULL,
    motivo_rechazo VARCHAR (80) NOT NULL,

    PRIMARY KEY(id),
    CONSTRAINT FK_PEDIDOS_TO_TIENDAID FOREIGN KEY (id_tienda) REFERENCES TIENDA(id)
     -- CONSTRAINT FK_PEDIDOS_TO_TIENDADIR FOREIGN KEY(direccion) REFERENCES TIENDA(direccion)
    
);

CREATE TABLE USUARIO(
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    correo VARCHAR(50) NOT NULL,
    tipo VARCHAR(15) NOT NULL,
    habilitado TINYINT(1),

    PRIMARY KEY(id)
);

CREATE TABLE TIENDA_ASIGNADA(
    id INT NOT NULL AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_tienda_asignada INT NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT FK_TIENDAASIG_TO_USUARIO FOREIGN KEY(id_usuario) REFERENCES USUARIO(id),
    CONSTRAINT FK_TIENDAASIG_TO_TIENDA FOREIGN KEY(id_tienda_asignada) REFERENCES TIENDA_SUPERVISADA(id_tienda),
    CONSTRAINT UNIQUE_TIEND_US UNIQUE (id_usuario, id_tienda_asignada)
);

CREATE TABLE USUARIO_BODEGA_CENTRAL(
    id INT NOT NULL,
    id_tienda_asignada INT NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT FK_USBOD_TO_USUARIO FOREIGN KEY(id) REFERENCES USUARIO(id),
    CONSTRAINT FK_USBOD_TO_TIENDAASIG FOREIGN KEY (id_tienda_asignada) REFERENCES TIENDA_ASIGNADA(id),
    CONSTRAINT UNIQUE_US_TD UNIQUE(id, id_tienda_asignada)
);


CREATE TABLE MODIFICACION_USUARIO(
    id_usuario_ejecutor INT NOT NULL,
    id_usuario_modificado INT NOT NULL,
    descripcion_modificacion VARCHAR(45),
    fecha_hora DATETIME,

    CONSTRAINT FK_MODUS_TO_USEJ FOREIGN KEY(id_usuario_ejecutor) REFERENCES USUARIO(id),
    CONSTRAINT FK_MODUS_TO_USMOD FOREIGN KEY(id_usuario_modificado) REFERENCES USUARIO(id)

);



CREATE TABLE PAQUETE_DE_PRODUCTOS(
    id INT NOT NULL, 
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,

    CONSTRAINT FK_PAQPROD_TO_PRODUCTO FOREIGN KEY(id_producto) REFERENCES PRODUCTO(codigo)
);




CREATE TABLE ENVIO(
    id INT NOT NULL AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_pedido INT NOT NULL,
    id_tienda INT NOT NULL,
    direccion VARCHAR(45) NOT NULL, -- obtenida desde id_tienda
    id_paquete_productos INT NOT NULL,
    fecha_entregado DATETIME, 
    estado VARCHAR(25) NOT NULL,


    PRIMARY KEY (id),
    
    CONSTRAINT FK_ENVIO_TO_USUARIO FOREIGN KEY (id_usuario) REFERENCES USUARIO(id),
    CONSTRAINT FK_ENVIO_TO_PEDIDOS FOREIGN KEY (id_pedido) REFERENCES PEDIDOS (id)
    -- CONSTRAINT FK_ENVIO_TO_TIENDA FOREIGN KEY (direccion) REFERENCES TIENDA (direccion),
    -- CONSTRAINT FK_ENVIO_TO_PAQPROD FOREIGN KEY (id_paquete_productos) REFERENCES PAQUETE_DE_PRODUCTOS(id)   Busca el id ya que es un array

);

CREATE TABLE MOTIVO_INCIDENDIA(
    id INT NOT NULL,
    motivo VARCHAR (45)
);

CREATE TABLE DETALLE_PRODUCTOS(
    id INT NOT NULL, -- Es un array de detalles, responden a un conjunto de detalles con el mismo id
    id_producto INT NOT NULL,
    cantidad_afectada INT NOT NULL,

    CONSTRAINT UNIQUE_INC_PROD UNIQUE (id, id_producto)
);

CREATE TABLE INCIDENCIA(
    id INT NOT NULL AUTO_INCREMENT,
    id_envio INT NOT NULL,
    id_tienda INT NOT NULL,
    fecha DATETIME,
    estado VARCHAR(25) NOT NULL,
    motivo_incidencia INT NOT NULL, 
    detalle_incidencia VARCHAR (55) NOT NULL,
    id_detalle_productos INT NOT NULL,
    motivo_rechazo VARCHAR (45) NOT NULL,

    PRIMARY KEY (id),
    CONSTRAINT FK_INCIDENCIA_TO_ENVIO FOREIGN KEY (id_envio) REFERENCES ENVIO(id),
    CONSTRAINT FK_INCIDENCIA_TO_TIENDA FOREIGN KEY (id_tienda) REFERENCES TIENDA(id)
     -- CONSTRAINT FK_INCIDENCIA_TO_MOTIVOINCIDENCIA FOREIGN KEY (motivo_incidencia) REFERENCES MOTIVO_INCIDENDIA(id) No es necesario, es un array
);

CREATE TABLE DEVOLUCION(
    id INT NOT NULL AUTO_INCREMENT,
    id_incidencia INT NOT NULL,
    detalle_devolucion VARCHAR(55) NOT NULL,
    estado VARCHAR (25),

    PRIMARY KEY (id),
    CONSTRAINT FK_DEVOLUCION_TO_INCIDENCIA FOREIGN KEY (id_incidencia) REFERENCES INCIDENCIA(id)
);


CREATE TABLE PERSONAS_A_NOTIFICAR(
    id INT NOT NULL, -- es un array de personas que responden al mismo id
    id_usuario INT NOT NULL,

    CONSTRAINT FK_PERNOT_TO_USUARIOS FOREIGN KEY (id_usuario) REFERENCES USUARIO(id)
);

CREATE TABLE NOTIFICACION(
    id INT NOT NULL AUTO_INCREMENT,
    cuerpo_notificacion VARCHAR (55),
    personas_a_notificar INT NOT NULL,

    PRIMARY KEY (id)
    -- CONSTRAINT FK_NOTIFICACION_TO_PERSONASNOTIFICAR FOREIGN KEY (personas_a_notificar) REFERENCES PERSONAS_A_NOTIFICAR(id) No es necesario, es un array
);

CREATE TABLE PARAMETRO(
    codigo INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(25),
    valor VARCHAR(15),

    PRIMARY KEY (codigo)
);