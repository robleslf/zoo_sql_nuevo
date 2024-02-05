-- BASE DE DATOS DE NUESTRO ZOOLÓGICO

-- Crear Base de Datos de "Nuestro Zoológico"
CREATE DATABASE NUESTRO_ZOOLOGICO CHARACTER SET UTF8MB4 COLLATE utf8mb4_spanish_ci;

-- Usar la Base de Datos NUESTRO_ZOOLOGICO
USE NUESTRO_ZOOLOGICO;

-- Tabla ANIMAL, donde se registran los animales del zoológico
CREATE TABLE ANIMAL (
    codigo_animal INT AUTO_INCREMENT COMMENT "Identificador único de cada animal",
    especie VARCHAR(50) NOT NULL COMMENT "Nombre científico de la especie a la que pertenece el animal.",
    nombre VARCHAR(60) NOT NULL COMMENT "Nombre del animal.",
    genero ENUM("Macho","Hembra","Hermafrodita") NOT NULL COMMENT "Género del animal.",
    fecha_de_ingreso DATETIME NOT NULL COMMENT "Fecha y hora en la que se realizó el registro de entrada del animal al zoológico.",
    fecha_de_nacimiento DATETIME NULL COMMENT "Fecha y hora en la que nació el animal.",  
    fecha_de_fallecimiento DATETIME NULL COMMENT "Fecha y hora en la que el animal se fue de este mundo.",
    CONSTRAINT ANIMAL_PK
        PRIMARY KEY (codigo_animal),
    CONSTRAINT fecha_de_ingreso_posterior_a_fecha_de_nacimiento
        CHECK (fecha_de_ingreso > fecha_de_nacimiento),
    CONSTRAINT fecha_de_ingreso_anterior_a_fecha_de_fallecimiento
        CHECK (fecha_de_ingreso < fecha_de_fallecimiento),
    CONSTRAINT fecha_de_nacimiento_anterior_a_fecha_de_fallecimiento
        CHECK (fecha_de_nacimiento < fecha_de_fallecimiento)
);


-- Índice de especies del zoo; para agilizar la búsqueda de las diferentes especies de nuestro zoo, se ha creado el siguiente índice:
CREATE INDEX INDICE_DE_ESPECIES ON ANIMAL (codigo_animal, nombre, especie);

-- Tabla ZONA, donde se registran las diferentes zonas y espacios del zoo
CREATE TABLE ZONA (
	codigo_zona INT AUTO_INCREMENT,
    superficie DECIMAL(8,2) NOT NULL COMMENT "Superficie de la zona en metros cuadrados, siendo la superficie mínima 10 metros cuadrados y la máxima 999999,99 metros cuadrados.",
    tipo ENUM ("pradera", "sabana", "río", "mar", "jungla", "árida", "montaña", "otra") NOT NULL COMMENT "Define el tipo de hábitat en el que está basada esta zona.",
    descripcion VARCHAR(500) NOT NULL COMMENT "Pequeña descripción de la zona, que incluye qué elementos hay en ella, temperaturas medias, si es cubierta o cerrada...",
    CONSTRAINT ZONA_PK
        PRIMARY KEY (codigo_zona),
    CONSTRAINT superficie_mayor_a_diez_metros_cuadrados
		CHECK (superficie > 10.00)
);



-- Tabla VIVE; aquí se registran los diferentes lugares donde ha vivido o vive un animal a lo largo del tiempo
CREATE TABLE VIVE (
	codigo_animal INT COMMENT "Clave foránea que identifica el animal en la tabla ANIMAL que está viviendo en la zona",
    codigo_zona INT COMMENT "Campo que identifica la zona de la tabla ZONA en la que vive el animal.",
    fecha_entrada DATETIME NOT NULL COMMENT "Fecha del registro en la que el animal entró a vivir a esa zona.",
    fecha_salida DATETIME NULL COMMENT "Fecha del registro en la que el animal dejó de vivir en esa zona.",
	CONSTRAINT VIVE_PK
		PRIMARY KEY (codigo_animal, codigo_zona, fecha_entrada),
	CONSTRAINT VIVE_FK_ANIMAL
		FOREIGN KEY (codigo_animal) REFERENCES ANIMAL(codigo_animal)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
	CONSTRAINT VIVE_FK_ZONA
		FOREIGN KEY (codigo_zona) REFERENCES ZONA(codigo_zona)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT,
  /* CONSTRAINT VIVE_fecha_entrada_posterior_ANIMAL_fecha_ingreso
    CHECK (fecha_entrada >= ANIMAL.fecha_de_ingreso), */
    CONSTRAINT VIVE_fecha_salida_posterio_a_fecha_entrada
        CHECK (fecha_salida > fecha_entrada)
);


-- Tabla EMPLEADO, donde se lleva el registro del personal del zoo
CREATE TABLE EMPLEADO(
    codigo_empleado INT AUTO_INCREMENT COMMENT "Clave primaria de la tabla.",
    nombre VARCHAR(60) NOT NULL COMMENT "Nombre del empleado.",
    apellido_1 VARCHAR(60) NOT NULL COMMENT "Primer apellido del empleado.",
    apellido_2 VARCHAR(60) NULL COMMENT "Segundo apellido del empleado en caso de que lo tenga.",
    direccion VARCHAR(200) NOT NULL COMMENT "Dirección donde reside el empleado. Ha de ir el tipo de vía, nombre de esta, portal y piso y letra si tiene.",
    DNI CHAR(9) NOT NULL UNIQUE COMMENT "Documento Nacional de Identidad del empleado",
    nº_SS CHAR(12) NOT NULL UNIQUE COMMENT "Número de la Seguridad Social del empleado. Van los 12 dígitos seguidos sin guiones ni separación.",
    codigo_empleado_administrador INT NULL COMMENT "Código del empleado de esta misma tabla bajo el que está supervisado el empleado.",
    CONSTRAINT TELEFONO_EMPLEADO_PK
      PRIMARY KEY (codigo_empleado),
    CONSTRAINT EMPLEADO_DNI_formato_correcto
        CHECK (DNI REGEXP '^[A-Z]{8}[0-9]$')
);


-- Tabla MANTENIMIENTO, para registrar a los empleados que tienen este rol
CREATE TABLE MANTENIMIENTO (
	codigo_empleado INT NOT NULL COMMENT "Identifica qué empleado de la tabla EMPLEADO tiene la categoría de personal de mantenimiento.",
    CONSTRAINT MANTENIMIENTO_PK
		PRIMARY KEY (codigo_empleado),
	CONSTRAINT MANTENIMIENTO_FK_EMPLEADO
		FOREIGN KEY (codigo_empleado) REFERENCES EMPLEADO(codigo_empleado)
			ON UPDATE CASCADE
            ON DELETE CASCADE
);


-- Tabla ADMINISTRADOR, para registrar a los empleados que tienen este rol
CREATE TABLE ADMINISTRADOR (
	codigo_empleado INT NOT NULL COMMENT "Identifica qué empleado de la tabla EMPLEADO tiene la categoría de administrador.",
    CONSTRAINT ADMINISTRADOR_PK
		PRIMARY KEY (codigo_empleado),
	CONSTRAINT ADMINISTRADOR_FK_EMPLEADO
		FOREIGN KEY (codigo_empleado) REFERENCES EMPLEADO(codigo_empleado)
			ON UPDATE CASCADE
            ON DELETE CASCADE
);



-- Se añade ahora la clave foránea a EMPLEADO para vincularla con ADMINISTRADOR
ALTER TABLE EMPLEADO
    ADD CONSTRAINT EMPLEADO_FK_ADMINISTRADOR
    	FOREIGN KEY (codigo_empleado_ADMINISTRADOR) REFERENCES ADMINISTRADOR(codigo_empleado);


-- La tabla VETERINARIO, para registrar a los empleados que tienen este rol
CREATE TABLE VETERINARIO (
	codigo_empleado INT NOT NULL COMMENT "Identifica qué empleado de la tabla EMPLEADO tiene la categoría de veterinario.",
    CONSTRAINT VETERINARIO_PK
		PRIMARY KEY (codigo_empleado),
	CONSTRAINT VETERINARIO_FK_EMPLEADO
		FOREIGN KEY (codigo_empleado) REFERENCES EMPLEADO(codigo_empleado)
			ON UPDATE CASCADE
            ON DELETE CASCADE
);

-- Tabla FORMA_VETERINARIO, aquí quedan registrados los periodos de formación de los nuevos veterinarios, por qué veterinario fueron formados y en qué periodo de tiempo
CREATE TABLE FORMA_VETERINARIO (
	codigo_empleado_veterinario_formador INT COMMENT "Identifica el veterinario formador en la tabla VETERINARIO.",
    codigo_empleado_veterinario_principiante INT COMMENT "Identifica en la tabla VETERINARIO al veterinario que recibe la formación",
    fecha_inicio_formacion DATE NOT NULL COMMENT "Fecha en la que comenzó o comenzará la formación del veterinario.",
    fecha_final_formacion DATE NOT NULL COMMENT "Fecha en la que finalizó o finalizará la formación del veterinario.",
    CONSTRAINT FORMA_VETERINARIO_PK
		PRIMARY KEY (codigo_empleado_veterinario_formador, codigo_empleado_veterinario_principiante),
	CONSTRAINT FORMA_VETERINARIO_FORMADOR_FK_VETERINARIO
		FOREIGN KEY (codigo_empleado_veterinario_formador) REFERENCES VETERINARIO(codigo_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
	CONSTRAINT FORMA_VETERINARIO_PRINCIPIANTE_FK_VETERINARIO
		FOREIGN KEY (codigo_empleado_veterinario_principiante) REFERENCES VETERINARIO(codigo_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT FORMA_VETERINARIO_fechas_inicio_y_final_formacion_correctas
        CHECK (fecha_inicio_formacion < fecha_final_formacion AND fecha_final_formacion <= fecha_inicio_formacion + INTERVAL '1' MONTH)
);


-- Táboa CUIDADOR, para registrar a los empleados que tienen este rol
CREATE TABLE CUIDADOR (
	codigo_empleado INT NOT NULL COMMENT "Identifica qué empleado de la tabla EMPLEADO tiene la categoría de cuidador.",
    CONSTRAINT CUIDADOR_PK
		PRIMARY KEY (codigo_empleado),
	CONSTRAINT CUIDADOR_FK_EMPLEADO
		FOREIGN KEY (codigo_empleado) REFERENCES EMPLEADO(codigo_empleado)
			ON UPDATE CASCADE
            ON DELETE CASCADE
);

-- Tabla CAJERO, para registrar a los empleados que tienen este rol
CREATE TABLE CAJERO (
	codigo_empleado INT NOT NULL COMMENT "Identifica qué empleado de la tabla EMPLEADO tiene la categoría de cajero.",
    CONSTRAINT CAJERO_PK
		PRIMARY KEY (codigo_empleado),
	CONSTRAINT CAJERO_FK_EMPLEADO
		FOREIGN KEY (codigo_empleado) REFERENCES EMPLEADO(codigo_empleado)
			ON UPDATE CASCADE
            ON DELETE CASCADE
);


-- Tabla FORMA_CUIDADOR, donde se lleva el registro de los periodos de formación de los cuidadores a cargo de otros cuidadores.
CREATE TABLE FORMA_CUIDADOR (
	codigo_empleado_cuidador_formador INT COMMENT "Identifica el veterinario formador en la tabla VETERINARIO.",
    codigo_empleado_cuidador_principiante INT COMMENT "Identifica en la tabla VETERINARIO al veterinario que recibe la formación",
    fecha_inicio_formacion DATE NOT NULL COMMENT "Fecha en la que comenzó o comenzará la formación del veterinario.",
    fecha_final_formacion DATE NOT NULL COMMENT "Fecha en la que finalizó o finalizará la formación del veterinario.",
    CONSTRAINT FORMA_CUIDADOR_PK
		PRIMARY KEY (codigo_empleado_cuidador_formador, codigo_empleado_cuidador_principiante),
	CONSTRAINT FORMA_CUIDADOR_FORMADOR_FK_CUIDADOR
		FOREIGN KEY (codigo_empleado_cuidador_formador) REFERENCES CUIDADOR(codigo_empleado)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
	CONSTRAINT FORMA_CUIDADOR_PRINCIPIANTE_FK_CUIDADOR
		FOREIGN KEY (codigo_empleado_cuidador_principiante) REFERENCES CUIDADOR(codigo_empleado)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT FORMA_CUIDADOR_fechas_inicio_y_final_formacion_correctas
        CHECK (fecha_inicio_formacion < fecha_final_formacion AND fecha_final_formacion <= fecha_inicio_formacion + INTERVAL '1' MONTH)
);

-- Tabla MANTIENE, lkleva el registro de qué empleado de mantenimiento se encargó de una zona durante un periodo de tiempo
CREATE TABLE MANTIENE (
	codigo_zona INT COMMENT "Clave foránea que identifica cuál es la zona de la tabla ZONA.",
    codigo_empleado_mantenimiento INT COMMENT "Clave foránea que identifica cuál es el empleado de la tabla MANTENIMIENTO que se ocupa de mantener la zona.",
    fecha_inicio DATETIME NOT NULL COMMENT "Fecha y hora en la que el empleado de mantenimiento comenzó a ocuparse de esta zona.", 
    fecha_fin DATETIME NOT NULL COMMENT "Fecha y hora en la que el empleado de mantenimiento dejó de ocuparse de esta zona.",
    CONSTRAINT MANTIENE_PK
		PRIMARY KEY (codigo_zona, codigo_empleado_mantenimiento),
	CONSTRAINT MANTIENE_FK_ZONA
		FOREIGN KEY (codigo_zona) REFERENCES ZONA(codigo_zona)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT,
	CONSTRAINT MANTIENE_FK_MANTENIMIENTO
		FOREIGN KEY (codigo_empleado_mantenimiento) REFERENCES MANTENIMIENTO(codigo_empleado)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT,
    CONSTRAINT MANTIENE_fechas_inicio_y_fin_correctas
        CHECK (fecha_inicio < fecha_fin)
);


-- Tabla AFECCION, registro de las diferentes afecciones que padecen los animales del zoo
CREATE TABLE AFECCION (
    nombre VARCHAR(60) COMMENT "Nombre de la afección",
    gravedad ENUM("Leve","Grave","Muy Grave") COMMENT "Indica la gravedad de la afección.",
    tipo ENUM("Enfermedad vírica", "Enfermedad bacteriana", "Traumatismo", "Transtorno", "Otro") COMMENT "Debe escogerse el tipo de afección entre las diferentes opciones.",
    CONSTRAINT AFECCION_PK
        PRIMARY KEY (nombre)
);

-- Tabla TRATAMIENTO, para registrar qué animal lo recibe, qué veterinario lo ordenó, tiempo de duración, medicamento y dosis de este, frecuencia, observaciones...
CREATE TABLE TRATAMIENTO (
	cod_tratamiento INT AUTO_INCREMENT COMMENT "Clave primaria del tratamiento.",
    nombre_afeccion VARCHAR(60) COMMENT "Nombre de la afección, clave foránea que identifica la afección en AFECCIÓN.",
	medicamento  VARCHAR(60) NOT NULL COMMENT "Nombre del medicamento.",
	dosis INT NOT NULL COMMENT "Dosis a aplicar del medicamento medida en mg.",
	frecuencia INT NOT NULL COMMENT "El número indica cada cuántas horas debe aplicarse el tratamiento.",
	observaciones VARCHAR(250) NULL COMMENT "Campo opcional para anotar observaciones de un tratamiento.",
	fecha_inicio DATETIME NOT NULL COMMENT "Fecha y hora a la que comenzó el tratamiento.",
	fecha_fin DATETIME NOT NULL COMMENT "Fecha y hora a la que finalizó o finalizará el tratamiento.",
	codigo_animal INT NOT NULL COMMENT "Clave foránea que identifica el animal de la tabla ANIMAL que recibe el tratamiento.",
	cod_empleado_veterinario INT NOT NULL COMMENT "Clave foránea que identifica el veterinario de la tabla VETERINARIO que diagnosticó el tratamiento.",
    CONSTRAINT TRATAMIENTO_PK
        PRIMARY KEY (cod_tratamiento),
	CONSTRAINT TRATAMIENTO_FK_ANIMAL
		FOREIGN KEY (codigo_animal) REFERENCES ANIMAL(codigo_animal)
			ON UPDATE RESTRICT
			ON DELETE RESTRICT,
	CONSTRAINT TRATAMIENTO_FK_VETERINARIO
		FOREIGN KEY (cod_empleado_veterinario) REFERENCES VETERINARIO(codigo_empleado)
			ON UPDATE RESTRICT
            ON DELETE RESTRICT,
    CONSTRAINT TRATAMIENTO_hora_entre_8_y_20
      CHECK (HOUR(fecha_inicio) BETWEEN 8 AND 20)
);

-- Índice de registro de medicamentos de los animales; es necesario saber bajo los efectos de qué medicamentos han estado o están los diferentes animales del zoo de una manera rápida para tenerlo en cuenta a la hora de realizar sus dietas, cuidados o demás tratamientos:
CREATE INDEX INDICE_DE_MEDICAMENTOS ON TRATAMIENTO (codigo_animal, medicamento, fecha_inicio, fecha_fin);



-- Tabla DIAGNOSTICA, registro de los diferentes diagnosticos de afecciones de animales del zoo por los veterinarios de este
CREATE TABLE DIAGNOSTICA (
    codigo_animal INT COMMENT "Clave foránea que identifica el animal en la tabla ANIMAL que es diagnosticado.",
    nombre_afeccion VARCHAR(60) COMMENT "Clave foránea que identifica la afección en la tabla AFECCION que ha sido diagnosticada",
    fecha DATETIME COMMENT "Fecha y hora en la que el animal fue diagnosticado.",
    codigo_empleado_veterinario INT COMMENT "Clave foránea que identifica al veterinario en la tabla VETERINARIO que ha diagnosticado la afección.",
    CONSTRAINT DIAGNOSTICA_PK
        PRIMARY KEY (codigo_animal, nombre_afeccion, fecha, codigo_empleado_veterinario),
    CONSTRAINT DIAGNOSTICA_FK_ANIMAL
        FOREIGN KEY (codigo_animal) REFERENCES ANIMAL(codigo_animal)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT DIAGNOSTICA_FK_AFECCION
        FOREIGN KEY (nombre_afeccion) REFERENCES AFECCION(nombre)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT DIAGNOSTICA_FK_VETERINARIO
        FOREIGN KEY (codigo_empleado_veterinario) REFERENCES VETERINARIO(codigo_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT 
);



-- Tablaa SINTOMAS, guarda los múltiples síntomas que están presentes en una misma afección
CREATE TABLE SINTOMAS(
    nombre_afeccion VARCHAR(60) COMMENT "Clave foránea que identifica el nombre de la afección de la tabla AFECCION.",
    sintoma VARCHAR(60) COMMENT "Nombre del sintoma que corresponde a la afección",
    CONSTRAINT SINTOMAS_PK
        PRIMARY KEY (nombre_afeccion, sintoma),
    CONSTRAINT SINTOMAS_FK_AFECCION
        FOREIGN KEY (nombre_afeccion) REFERENCES AFECCION(nombre)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
);

-- Tabla VACUNA, registro de las diferentes vacunas administradas a los animales del zoo
CREATE TABLE VACUNA(
    codigo_animal INT COMMENT "Clave foránea que identifica al animal en la tabla ANIMAL que recibió la vacuna.",
    codigo_empleado_veterinario INT COMMENT "Clave foránea que identifica al veterinario de la tabla VETERINARIO que se encargó de vacunar al animal.",
    CONSTRAINT VACUNA_PK
        PRIMARY KEY (codigo_animal, codigo_empleado_veterinario),
    CONSTRAINT VACUNA_FK_ANIMAL
        FOREIGN KEY (codigo_animal) REFERENCES ANIMAL(codigo_animal)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT,
    CONSTRAINT VACUNA_FK_VETERINARIO
        FOREIGN KEY (codigo_empleado_veterinario) REFERENCES VETERINARIO(codigo_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT
);

-- Tabla DIETA, registro de las diferentes dietas preparadas por los veterinarios del zoo
CREATE TABLE DIETA (
    cod_dieta INT AUTO_INCREMENT COMMENT "Identificador de cada dieta.",
    observaciones VARCHAR(200) NULL COMMENT "Enumera problemas o aspectos a tener en cuenta a la hora de preparar la dieta.",
    CONSTRAINT DIETA_PK
        PRIMARY KEY (cod_dieta)
);

-- Tabla ALIMENTA, para registrar las tomas de comida de los animales por parte de los cuidadores
CREATE TABLE ALIMENTA (
    codigo_animal INT COMMENT "Clave foránea que identifica en la tabla ANIMAL al animal que fue alimentado.",
    codigo_empleado_cuidador INT COMMENT "Clave foránea que identifica al cuidador en la tabla CUIDADOR que se encargó de alimentar al animal.",
    cod_dieta INT COMMENT "Clave foránea que identifica la dieta de la tabla DIETA.",
    fecha DATETIME NOT NULL COMMENT "Fecha y hora en la que el animal fue alimentado.",
    CONSTRAINT ALIMENTA_PK
        PRIMARY KEY (codigo_animal, codigo_empleado_cuidador, cod_dieta),
    CONSTRAINT ALIMENTA_FK_ANIMAL
        FOREIGN KEY (codigo_animal) REFERENCES ANIMAL(codigo_animal)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT ALIMENTA_FK_CUIDADOR
        FOREIGN KEY (codigo_empleado_cuidador) REFERENCES CUIDADOR(codigo_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT ALIMENTA_FK_DIETA
        FOREIGN KEY (cod_dieta) REFERENCES DIETA(cod_dieta)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT ALIMENTA_hora_entre_8_y_20
        CHECK (HOUR(fecha) BETWEEN 8 AND 20)
);

-- Tabla CUIDA, lleva el registro de los diferentes cuidados a los animales
CREATE TABLE CUIDA (
    codigo_animal INT COMMENT "Clave foránea que identifica en la tabla ANIMAL el animal que recibió el cuidado.",
    codigo_empleado_cuidador INT COMMENT "Clave foránea que identifica en la tabla CUIDADOR al cuidador que se encargó de este cuidado.",
    fecha DATETIME COMMENT "Fecha y hora en la que se realizó el cuidado.",
    tipo_cuidado ENUM("Higiene","Observación","Cura","Otro") NOT NULL COMMENT "Elegir el tipo de cuidado que se llevó a cabo entre las opciones.",
    observaciones VARCHAR(200) NULL COMMENT "Campo para anotar cualquier incidente o particularidad durante el cuidado por parte del cuidador.",
    CONSTRAINT CUIDA_PK
        PRIMARY KEY (codigo_animal, codigo_empleado_cuidador, fecha),
    CONSTRAINT CUIDA_FK_ANIMAL
        FOREIGN KEY (codigo_animal) REFERENCES ANIMAL(codigo_animal)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT CUIDA_FK_CUIDADOR
        FOREIGN KEY (codigo_empleado_cuidador) REFERENCES CUIDADOR(codigo_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT CUIDA_hora_entre_8_y_20
        CHECK (HOUR(fecha) BETWEEN 8 AND 20)
);


-- Táboa FAMILIAR, para guardar los contactos de los empleados en caso de emergencia
CREATE TABLE FAMILIAR (
    cod_familiar INT AUTO_INCREMENT COMMENT "Identificador único de cada familiar.",
    nombre VARCHAR(60) NOT NULL COMMENT "Nombre del familiar.",
    apellido_1 VARCHAR(60) NOT NULL COMMENT "Primer apellido del familiar.",
    apellido_2 VARCHAR(60) NULL COMMENT "Segundo apellido del familiar si lo tiene.",
    DNI CHAR(9) NOT NULL UNIQUE COMMENT "Documento Nacional de Identidad del familiar con letra incluida.",
    CONSTRAINT FAMILIAR_PK
        PRIMARY KEY (cod_familiar),
    CONSTRAINT FAMILIAR_DNI_formato_correcto
        CHECK (DNI REGEXP '^[A-Z]{8}[0-9]$')
);

-- Táboa TIENE, tabla para reflejar la relación entre los diferentes empleados y familiares
CREATE TABLE TIENE (
    codigo_empleado INT COMMENT "Identidica en la tabla EMPLEADO al empleado que tiene un familiar.",
    cod_familiar INT COMMENT "Identifica en la tabla FAMILIAR al familiar que tiene el empleado.",
    CONSTRAINT TIENE_PK 
		PRIMARY KEY(codigo_empleado, cod_familiar),
    CONSTRAINT TIENE_FK_EMPLEADO
        FOREIGN KEY (codigo_empleado) REFERENCES EMPLEADO(codigo_empleado)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT TIENE_FK_FAMILIAR 
        FOREIGN KEY (cod_familiar) REFERENCES FAMILIAR(cod_familiar)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
);

-- Táboa TELEFONO_FAMILIAR, registro de los números de contacto de los familiares de los empleados
CREATE TABLE TELEFONO_FAMILIAR (
    cod_familiar INT COMMENT "Identifica al familiar en la tabla FAMILIAR.",
    telefono CHAR(15) COMMENT "Teléfono del familiar. Debe incluir el prefijo internacional (por ejemplo, +34 para España) seguido de los dígitos, sin espacio, del número de teléfono.",
    CONSTRAINT TELEFONO_FAMILIAR_PK
        PRIMARY KEY (cod_familiar, telefono),
    CONSTRAINT TELEFONO_FAMILIAR_FK_FAMILIAR
        FOREIGN KEY (cod_familiar) REFERENCES FAMILIAR(cod_familiar)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
);


-- Táboa TELEFONO_EMPLEADO, registro de los teléfonos de los empleados
CREATE TABLE TELEFONO_EMPLEADO (
    codigo_empleado INT COMMENT "Identifica al empleado en la tabla EMPLEADO.",
    telefono CHAR(15) COMMENT "Teléfono del empleado. Debe incluir el prefijo internacional (por ejemplo, +34 para España) seguido de los dígitos, sin espacio, del número de teléfono.",
    CONSTRAINT TELEFONO_EMPLEADO_PK
        PRIMARY KEY (codigo_empleado, telefono),
    CONSTRAINT TELEFONO_EMPLEADO_FK_EMPLEADO
        FOREIGN KEY (codigo_empleado) REFERENCES EMPLEADO(codigo_empleado)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);


-- Táboa ORGANIZA, refleja qué veterinarios participaron en la organización de las dfiferentes dietas de los animales
CREATE TABLE ORGANIZA (
    codigo_empleado_veterinario INT COMMENT "Identifica en la tabla VETRINARIO al veterinario que organiza la dieta.",
    cod_dieta INT COMMENT "Identifica en la tabla DIETA la dieta organizada.",
    CONSTRAINT ORGANIZA_PK
        PRIMARY KEY (codigo_empleado_veterinario, cod_dieta),
    CONSTRAINT ORGANIZA_FK_VETERINARIO
        FOREIGN KEY (codigo_empleado_veterinario) REFERENCES VETERINARIO(codigo_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT ORGANIZA_FK_DIETA
        FOREIGN KEY (cod_dieta) REFERENCES DIETA(cod_dieta)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT
);




-- Táboa TIPO; esta tabla hace referencia a los diferentes tipos de dieta que puede ser una misma dieta
CREATE TABLE TIPO (
    cod_dieta INT COMMENT "Identifica en la tabla DIETA a la dieta a la que hace referencia.",
    tipo ENUM("Prot","Fib","Veg","Omn","Car","Gran") COMMENT "Debe elegirse uno de los tipos a los que pertenece la dieta, siendo 'Prot' modificada en proteínas, 'Fib' para alta en fibra, 'Veg' para vegetariana, 'Omn' para omnívora, 'Car' carnívora y 'Gran' para granívora.",
    CONSTRAINT TIPO_PK
        PRIMARY KEY (cod_dieta, tipo),
    CONSTRAINT TIPO_FK_DIETA
        FOREIGN KEY (cod_dieta) REFERENCES DIETA(cod_dieta)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
);




-- Tabla ALIMENTO, para guardar los alimentos que componen las dietas de los animales
CREATE TABLE ALIMENTO(
    cod_alimento INT AUTO_INCREMENT COMMENT "Identificador único de cada alimento",
    nombre VARCHAR(40) NOT NULL COMMENT "Nombre del alimento",
    grasas DECIMAL (5,2) NOT NULL COMMENT "Gramos de grasa por cada 100 gramos de alimento; si no hay, el valor debe ser 0.",
    proteinas DECIMAL (5,2) NOT NULL COMMENT "Gramos de proteina por cada 100 gramos de alimento; si no hay, el valor debe ser 0.",
    hidratos DECIMAL (5,2) NOT NULL COMMENT "Gramos de hidratos por cada 100 gramos de alimento; si no hay, el valor debe ser 0.",
    stock DECIMAL (7,2) NOT NULL COMMENT "Cantidad disponible del alimento medido en kg; si no hay stock de un alimento, el valor debe ser 0.",
    CONSTRAINT ALIMENTO_PK
        PRIMARY KEY (cod_alimento),
    CONSTRAINT ALIMENTO_grasas_no_negativo
        CHECK (grasas >= 0 AND grasas <= 100),
    CONSTRAINT ALIMENTO_proteinas_no_negativo
        CHECK (proteinas >= 0 AND proteinas <= 100),
    CONSTRAINT ALIMENTO_hidratos_no_negativo
        CHECK (hidratos >= 0 AND hidratos <= 100),
    CONSTRAINT ALIMENTO_stock_no_negativo
        CHECK (stock >= 0)
);

-- Índice de stock de alimentos; para agilizar la preparación de comida se ha creado el siguiente índice, que muestra cuánto stock hay disponible de cada alimento:
CREATE INDEX INDICE_STOCK_ALIMENTOS ON ALIMENTO (nombre, stock);

-- Táboa COMPONE, tabla relacional entre los alimentos y las dietas, reflejando además la cantidad de los primeros
CREATE TABLE COMPONE (
    cod_dieta INT COMMENT "Identifica en la tabla DIETA a la dieta a la que hace referencia.",
    cod_alimento INT COMMENT "Identifica en la tabla ALIMENTO a los alimentos que componen la dieta.",
    cantidad DECIMAL (7,2) COMMENT "Cantidad en gramos del alimentos que forma parte de la dieta.",
    CONSTRAINT COMPONE_PK
        PRIMARY KEY (cod_dieta, cod_alimento),
    CONSTRAINT COMPONE_FK_DIETA
        FOREIGN KEY (cod_dieta) REFERENCES DIETA(cod_dieta)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT COMPONE_FK_ALIMENTO
        FOREIGN KEY (cod_alimento) REFERENCES ALIMENTO(cod_alimento)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT COMPONE_cantidad_positiva
        CHECK (cantidad > 0)
);




-- Táboa CLIENTE, registro de los clientes del zoo
CREATE TABLE CLIENTE (
    cod_cliente INT AUTO_INCREMENT COMMENT "Identificador único del cliente.",
    DNI CHAR(9) NULL COMMENT "DNI del cliente, en caso de que lo aporte.",
    nombre VARCHAR(60) NOT NULL COMMENT "Nombre del cliente.",
    apellido_1 VARCHAR(60) NOT NULL COMMENT "Primer apellido del cliente.",
    apellido_2 VARCHAR(60) NULL COMMENT "Segundo apellido del cliente en caso de que lo tenga.",
    CONSTRAINT CLIENTE_PK
        PRIMARY KEY (cod_cliente),
    CONSTRAINT CLIENTE_DNI_formato_correcto
        CHECK (DNI REGEXP '^[A-Z]{8}[0-9]$')
);


-- Táboa TELEFONO_CLIENTE, se almacenan los teléfonos de los clientes del zoo
CREATE TABLE TELEFONO_CLIENTE (
    cod_cliente INT COMMENT "Identifica al cliente en la tabla CLIENTE.",
    telefono CHAR(15) COMMENT "Teléfono del cliente. Debe incluir el prefijo internacional (por ejemplo, +34 para España) seguido de los dígitos, sin espacio, del número de teléfono.",
    CONSTRAINT TELEFONO_CLIENTE_PK
        PRIMARY KEY (cod_cliente, telefono),
    CONSTRAINT TELEFONO_CLIENTE_FK_CLIENTE
        FOREIGN KEY (cod_cliente) REFERENCES CLIENTE(cod_cliente)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);


-- Táboa MEMBRESIA, registro de las membresias de los clientes
CREATE TABLE MEMBRESIA (
    n_membresia INT AUTO_INCREMENT COMMENT "Identificador único de la membresía.",
    porcentaje TINYINT NOT NULL COMMENT "Porcentaje que se aplica al precio base de la entrada cuando se aplica la membresía para calcular el precio final de aquella.",
    precio_anual DECIMAL(5,2) NOT NULL COMMENT "Cantidad en € de lo que paga al año por ser miembro el cliente.",
    fecha_membresia DATE NOT NULL COMMENT "Fecha en la que se hizo miembro el cliente.",
    tipo_membresia ENUM("Inf", "Stu", "Jub", "Sta") NOT NULL DEFAULT 'Sta' COMMENT "Elegir el tipo de membresía: Infantil (Inf), Estudiante (Stu), Jubilado (Jub) o Estándar (Sta)",
    cod_cliente INT NOT NULL COMMENT "Identifica en la tabla CLIENTE al cliente que disfruta de la membresía.",
    CONSTRAINT MEMBRESIA_PK
        PRIMARY KEY (n_membresia),
    CONSTRAINT MEMBRESIA_FK_CLIENTE
        FOREIGN KEY (cod_cliente) REFERENCES CLIENTE(cod_cliente)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT MEMBRESIA_precio_anual_entre_10_y_100
        CHECK (precio_anual >= 10 AND precio_anual <= 100),
    CONSTRAINT MEMBRESIA_porcentaje_entre_5_y_60
        CHECK (porcentaje >= 5 AND porcentaje <= 60)
);


-- Táboa ENTRADA, registro de todas las entradas 
CREATE TABLE ENTRADA (
    n_entrada INT AUTO_INCREMENT COMMENT "Identificador único de la entrada",
    tipo_de_entrada ENUM("O","M") NOT NULL COMMENT "Explica si la entrada ha sido ordinaria (O) o si se ha aplicado algún tipo de membresía (M).",
    precio_base DECIMAL(5,2) NOT NULL COMMENT "Precio base de la entrada expresado en €.",
    precio_final DECIMAL(5,2) NOT NULL COMMENT "Precio final de la entrada expresado en €.",
    fecha_compra DATETIME NOT NULL COMMENT "Fecha y hora a la que tuvo lugar la compra de la entrada.",
    fecha_visita DATETIME NOT NULL COMMENT "Fecha y hora a la que tiene lugar el incio de la visita",
    codigo_empleado_cajero INT NOT NULL COMMENT "Identifica en la tabla CAJERO al empleado que vendió la entrada.",
    codigo_cliente INT NULL COMMENT "Identifica en la tabla CLIENTE al cliente que compró la entrada.",
    n_membresia INT NULL COMMENT "Identifica, en caso de que la haya, la membresía que ha sido aplicada en la tabla MEMBRESIA",
    CONSTRAINT
        PRIMARY KEY (n_entrada),
    CONSTRAINT ENTRADA_FK_CAJERO
        FOREIGN KEY (codigo_empleado_cajero) REFERENCES CAJERO(codigo_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT ENTRADA_FK_CLIENTE
        FOREIGN KEY (codigo_cliente) REFERENCES CLIENTE(cod_cliente)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT ENTRADA_FK_MEMBRESIA
        FOREIGN KEY (n_membresia) REFERENCES MEMBRESIA(n_membresia) 
            ON DELETE RESTRICT
            ON UPDATE RESTRICT,
    CONSTRAINT ENTRADA_precio_base_no_negativo
        CHECK (precio_base >= 0),
    CONSTRAINT ENTRADA_precio_final_no_negativo
        CHECK (precio_final >= 0), 
    CONSTRAINT ENTRADA_precio_final_no_superior_a_precio_base
        CHECK (precio_final <= precio_base), 
    CONSTRAINT ENTRADA_fecha_compra_anterior_a_fecha_visita
        CHECK (fecha_compra <= fecha_visita),
    CONSTRAINT ENTRADA_fecha_compra_en_horario
        CHECK (HOUR(fecha_compra) BETWEEN 8 AND 20),
    CONSTRAINT ENTRADA_fecha_visita_en_horario
        CHECK (HOUR(fecha_visita) BETWEEN 8 AND 19)
);  



