-- Tabla ANIMAL; se propone cambiar la extensión del campo "especie" a 60 caracteres.
ALTER TABLE ANIMAL
    MODIFY especie VARCHAR(60) NOT NULL COMMENT "Nombre científico de la especie animal a la que pertenece el animal.";

-- Tabla ZONA; se cambia el nombre de la tabla a AREA, y por consiguiente se modifica el nombre de la clave primaria.
ALTER TABLE ZONA
    RENAME TO AREA,
    RENAME COLUMN codigo_zona TO codigo_area,
    DROP PRIMARY KEY,
    ADD CONSTRAINT AREA_PK 
        PRIMARY KEY (codigo_area);


-- Tabla VIVE; como se cambió la tabla ZONA a AREA, y se modificó también el nombre de su clave principal, se cambia en VIVE la clave foránea para que haga referencia al nuevo nombre.
ALTER TABLE VIVE
    RENAME COLUMN codigo_zona TO codigo_area,
    DROP CONSTRAINT VIVE_FK_ZONA,
    ADD CONSTRAINT VIVE_FK_AREA
        FOREIGN KEY (codigo_area) REFERENCES AREA(codigo_area)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT;


-- Tabla EMPLEADO; se añade la columna "inicio_contrato" y se cambia su clave primaria a "DNI"; como "codigo_empleado" ya no tiene utilidad, se elimina esa columna.
ALTER TABLE EMPLEADO
    ADD COLUMN inicio_contrato DATE NOT NULL COMMENT "Fecha en la que inicio su contrato de trabajo para el zoológico." AFTER nº_SS;

-- Antes de cambiar la clave primaria en EMPLEADO, es necesario eliminar las restricciones de las otras tablas que hacen referencia a "codigo_empleado":
ALTER TABLE MANTENIMIENTO
    DROP FOREIGN KEY MANTENIMIENTO_FK_EMPLEADO;
  
ALTER TABLE VETERINARIO
    DROP FOREIGN KEY VETERINARIO_FK_EMPLEADO;
  
ALTER TABLE CAJERO
    DROP FOREIGN KEY CAJERO_FK_EMPLEADO;
  
ALTER TABLE CUIDADOR
    DROP FOREIGN KEY CUIDADOR_FK_EMPLEADO;
  
ALTER TABLE ADMINISTRADOR
    DROP FOREIGN KEY ADMINISTRADOR_FK_EMPLEADO;
  
ALTER TABLE TIENE
    DROP FOREIGN KEY TIENE_FK_EMPLEADO;
  
ALTER TABLE TELEFONO_EMPLEADO
    DROP FOREIGN KEY TELEFONO_EMPLEADO_FK_EMPLEADO;
  
ALTER TABLE EMPLEADO
	DROP FOREIGN KEY EMPLEADO_FK_ADMINISTRADOR;

-- Ahora se puede eliminar la clave primaria antigua, se modifica el comentario de "DNI" para aclarar que ahora es la clave primaria y se añade como clave. Como la columna "codigo_empleado" ya no nos sirve, la eliminamos.
ALTER TABLE EMPLEADO 
    DROP PRIMARY KEY,
    MODIFY COLUMN DNI CHAR(9) NOT NULL COMMENT "Documento Nacional de Identidad del empleado y clave primaria de la tabla.",
    ADD PRIMARY KEY (DNI),
    DROP COLUMN codigo_empleado;
  
-- Ahora será necesario añadir la columna "DNI_empleado" a aquellas tablas que tienen relación con empleado (CAJERO, MANTENIMIENTO, ADMINISTRADOR, VETERINARIO, CUIDADOR), y como además las claves primarias de estas tablas son claves foráneas en otras tablas, será también necesario retocar estas otras:

-- De la tabla MANTIENE será necesario eliminar su FOREIGN KEY para poder cambiar la clave primaria en MANTENIMIENTO:
ALTER TABLE	MANTIENE
	DROP FOREIGN KEY MANTIENE_FK_MANTENIMIENTO;
    
-- Además, se quiere cambiar los nombres de las columnas de las fechas por unos más cortos, y en consecuencia, modificar el CONSTRAINT con los nuevos nombres:
ALTER TABLE MANTIENE
    CHANGE COLUMN fecha_inicio inicio DATE NOT NULL COMMENT "Fecha en la que el empleado de mantenimiento comenzó a ocuparse de esta zona; comienza cuando empiece la jornada de ese día." AFTER codigo_empleado_mantenimiento,
    CHANGE COLUMN fecha_fin fin DATE NOT NULL COMMENT "Fecha y hora en la que el empleado de mantenimiento dejó de ocuparse de esta zona; termina cuando termine la jornada de ese día.",
    DROP CONSTRAINT MANTIENE_fechas_inicio_y_fin_correctas,
    ADD CONSTRAINT MANTIENE_inicio_y_fin_correctos
        CHECK (inicio < fin);

-- Ahora, en la tabla MANTENIMIENTO, es posible añadir la nueva clave primaria
    ALTER TABLE MANTENIMIENTO
    ADD COLUMN DNI_empleado CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla EMPLEADO.",
    DROP PRIMARY KEY,
    ADD CONSTRAINT
        PRIMARY KEY (DNI_empleado),
    ADD CONSTRAINT MANTENIMIENTO_FK_EMPLEADO
        FOREIGN KEY (DNI_empleado) REFERENCES EMPLEADO(DNI)
            ON UPDATE CASCADE
            ON DELETE CASCADE;

-- Como "codigo_empleado" ya no tiene utilidad, se elimina:
ALTER TABLE MANTENIMIENTO
	DROP COLUMN codigo_empleado;
      

-- Ahora modificamos la tabla ADMINISTRADOR de la misma manera:
ALTER TABLE ADMINISTRADOR
    ADD COLUMN DNI_empleado CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla EMPLEADO.",
    DROP PRIMARY KEY,
    ADD CONSTRAINT
        PRIMARY KEY (DNI_empleado),
    ADD CONSTRAINT ADMINISTRADOR_FK_EMPLEADO
        FOREIGN KEY (DNI_empleado) REFERENCES EMPLEADO(DNI)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    	    DROP COLUMN codigo_empleado;

-- Hay que ajustar la nueva clave foránea que une EMPLEADO y ADMINISTRADOR en la tabla EMPLEADO:
ALTER TABLE EMPLEADO
	DROP COLUMN codigo_empleado_administrador,
    ADD COLUMN DNI_empleado_administrador CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla EMPLEADO.";
    
ALTER TABLE EMPLEADO
	ADD CONSTRAINT EMPLEADO_FK_ADMINISTRADOR
		FOREIGN KEY (DNI_empleado_administrador) REFERENCES ADMINISTRADOR(DNI_empleado);
			
      
      
      
-- Hacemos lo mismo con VETERINARIO; de esta tabla dependen FORMA_VETERINARIO, TRATAMIENTO, DIAGNOSTICA, VACUNA Y ORGANIZA, por lo que antes habrá que modificar estas tablas:

-- En FORMA_VETERINARIO, además, se quiere añadir la hora en los campos de las fechas.
ALTER TABLE FORMA_VETERINARIO
	DROP FOREIGN KEY FORMA_VETERINARIO_FORMADOR_FK_VETERINARIO,
    DROP FOREIGN KEY FORMA_VETERINARIO_PRINCIPIANTE_FK_VETERINARIO,
    MODIFY COLUMN fecha_inicio_formacion DATETIME NOT NULL COMMENT "Fecha y hora en la que comenzó o comenzará la formación del veterinario.",  
    MODIFY COLUMN fecha_final_formacion DATETIME NOT NULL COMMENT "Fecha y hora en la que finalizó o finalizará la formación del veterinario.";
  
 
 -- En la tabla TRATAMIENTO, además, se cambia la clave primaria "cod_tratamiento" a una clave compuesta por "medicamento", "fecha_inicio" y "codigo_animal".
ALTER TABLE TRATAMIENTO
	DROP FOREIGN KEY TRATAMIENTO_FK_VETERINARIO,
	DROP PRIMARY KEY,
	ADD CONSTRAINT TRATAMIENTO_PK
		PRIMARY KEY (medicamento, fecha_inicio, codigo_animal),
	DROP COLUMN cod_tratamiento;

ALTER TABLE DIAGNOSTICA
	DROP FOREIGN KEY DIAGNOSTICA_FK_VETERINARIO;
    
ALTER TABLE VACUNA
    ADD COLUMN DNI_empleado_veterinario CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla VETERINARIO." AFTER codigo_animal, 
    DROP COLUMN codigo_empleado_veterinario,
    DROP FOREIGN KEY VACUNA_FK_VETERINARIO;
  
-- Táboa ORGANIZA
ALTER TABLE ORGANIZA
    DROP FOREIGN KEY ORGANIZA_FK_VETERINARIO;

	
ALTER TABLE VETERINARIO
    ADD COLUMN DNI_empleado CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla EMPLEADO.",
    DROP PRIMARY KEY,
    ADD CONSTRAINT
        PRIMARY KEY (DNI_empleado),
    ADD CONSTRAINT VETERINARIO_FK_EMPLEADO
        FOREIGN KEY (DNI_empleado) REFERENCES EMPLEADO(DNI)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    DROP COLUMN codigo_empleado;
      
-- Queda por añadir la nueva clave primaria a VACUNA:
ALTER TABLE VACUNA
DROP PRIMARY KEY,
    ADD CONSTRAINT VACUNA_PK
        PRIMARY KEY (codigo_animal, DNI_empleado_veterinario),
	ADD CONSTRAINT VACUNA_FK_VETERINARIO
        FOREIGN KEY (DNI_empleado_veterinario) REFERENCES VETERINARIO(DNI_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT;
      
-- Ahora hay que hacer lo mismo para las tablas relacionadas con CUIDADOR: ALIMENTA, CUIDA y FORMA_CUIDADOR:
ALTER TABLE ALIMENTA
    DROP FOREIGN KEY ALIMENTA_FK_CUIDADOR;
  
ALTER TABLE CUIDA
	DROP FOREIGN KEY CUIDA_FK_CUIDADOR;
    
ALTER TABLE FORMA_CUIDADOR
	DROP FOREIGN KEY FORMA_CUIDADOR_FORMADOR_FK_CUIDADOR,
    DROP FOREIGN KEY FORMA_CUIDADOR_PRINCIPIANTE_FK_CUIDADOR;


ALTER TABLE CUIDADOR
    ADD COLUMN DNI_empleado CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla EMPLEADO.",
    DROP PRIMARY KEY,
    ADD CONSTRAINT
        PRIMARY KEY (DNI_empleado),
    ADD CONSTRAINT CUIDADOR_FK_EMPLEADO
        FOREIGN KEY (DNI_empleado) REFERENCES EMPLEADO(DNI)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    DROP COLUMN codigo_empleado;
     
-- De CAJERO depende ENTRADA:
ALTER TABLE ENTRADA
	DROP FOREIGN KEY ENTRADA_FK_CAJERO;
 
-- Una vez eliminada la restricción que las vinculaba, se puede modificar CAJERO:
ALTER TABLE CAJERO
    ADD COLUMN DNI_empleado CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla EMPLEADO.",
    DROP PRIMARY KEY,
    ADD CONSTRAINT
        PRIMARY KEY (DNI_empleado),
    ADD CONSTRAINT CAJERO_FK_EMPLEADO
        FOREIGN KEY (DNI_empleado) REFERENCES EMPLEADO(DNI)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
	DROP COLUMN codigo_empleado;
      
-- Todavía es necesario hacer más cambios en algunas tablas anteriores, hay que añadir las nuevas columnas que hagan referencia a "DNI_empleado" de la tabla EMPLEADO para poder crear las nuevas claves foráneas en FORMA_CUIDADOR, VACUNA, MANTIENE, ALIMENTA, CUIDA y ORGANIZA:


ALTER TABLE FORMA_CUIDADOR
    ADD COLUMN DNI_empleado_cuidador_formador CHAR(9) NOT NULL COMMENT "DNI del empleado formador e identificador del mismo en la tabla CUIDADOR." AFTER codigo_empleado_cuidador_formador,
    ADD COLUMN DNI_empleado_cuidador_principiante CHAR(9) NOT NULL COMMENT "DNI del empleado que recibe la formación e identificador del mismo en la tabla CUIDADOR." AFTER codigo_empleado_cuidador_principiante,
    DROP PRIMARY KEY,
    ADD CONSTRAINT FORMA_CUIDADOR_PK
        PRIMARY KEY (DNI_empleado_cuidador_formador, DNI_empleado_cuidador_principiante),
    ADD CONSTRAINT FORMA_FORMADOR_FK_CUIDADOR
    	FOREIGN KEY (DNI_empleado_cuidador_formador) REFERENCES CUIDADOR(DNI_empleado)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    ADD CONSTRAINT FORMA_PRINCIPIANTE_FK_CUIDADOR
    	FOREIGN KEY (DNI_empleado_cuidador_principiante) REFERENCES CUIDADOR(DNI_empleado)
            ON UPDATE CASCADE
            ON DELETE CASCADE;
        
ALTER TABLE VACUNA
	DROP PRIMARY KEY,
    ADD CONSTRAINT VACUNA_PK
        PRIMARY KEY (codigo_animal, DNI_empleado_veterinario),
    DROP FOREIGN KEY VACUNA_FK_VETERINARIO;
  
ALTER TABLE VACUNA
    ADD CONSTRAINT VACUNA_FK_VETERINARIO
        FOREIGN KEY (DNI_empleado_veterinario) REFERENCES VETERINARIO(DNI_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT;
        
ALTER TABLE MANTIENE
    ADD COLUMN DNI_empleado_mantenimiento CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla MANTENIMIENTO." FIRST,
    ADD COLUMN codigo_area INT COMMENT "Clave foránea que identifica cuál es el área de la tabla ÁREA." AFTER codigo_zona;

ALTER TABLE MANTIENE
    DROP COLUMN codigo_zona,
    DROP COLUMN codigo_empleado_mantenimiento,
    DROP PRIMARY KEY,
    DROP FOREIGN KEY MANTIENE_FK_ZONA,
    ADD PRIMARY KEY (codigo_area, DNI_empleado_mantenimiento),
    ADD CONSTRAINT MANTIENE_FK_AREA
    		FOREIGN KEY (codigo_area) REFERENCES AREA(codigo_area)
                ON UPDATE RESTRICT
                ON DELETE RESTRICT,
    ADD CONSTRAINT MANTIENE_FK_MANTENIMIENTO
    		FOREIGN KEY (DNI_empleado_mantenimiento) REFERENCES MANTENIMIENTO(DNI_empleado)
                ON UPDATE RESTRICT
                ON DELETE RESTRICT;
      
ALTER TABLE ALIMENTA
    CHANGE COLUMN codigo_empleado_cuidador DNI_empleado_cuidador CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla CUIDADOR." FIRST,
    DROP PRIMARY KEY,
    ADD CONSTRAINT ALIMENTA_PK
        PRIMARY KEY (codigo_animal, DNI_empleado_cuidador, cod_dieta),
    ADD CONSTRAINT ALIMENTA_FK_CUIDADOR
        FOREIGN KEY (DNI_empleado_cuidador) REFERENCES CUIDADOR(DNI_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT; 
      
-- Táboa CUIDA
ALTER TABLE CUIDA
    CHANGE COLUMN codigo_empleado_cuidador DNI_empleado_cuidador CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla CUIDADOR." FIRST,
    DROP PRIMARY KEY,
    ADD CONSTRAINT CUIDA_PK
        PRIMARY KEY (codigo_animal, DNI_empleado_cuidador),
    ADD CONSTRAINT CUIDA_FK_CUIDADOR
        FOREIGN KEY (DNI_empleado_cuidador) REFERENCES CUIDADOR(DNI_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT;
      
ALTER TABLE ORGANIZA
    CHANGE COLUMN codigo_empleado_veterinario DNI_empleado_veterinario CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla VETERINARIO." FIRST,
    DROP PRIMARY KEY,
    ADD CONSTRAINT ORGANIZA_PK
        PRIMARY KEY (DNI_empleado_veterinario, cod_dieta),
    ADD CONSTRAINT ORGANIZA_FK_VETERINARIO
        FOREIGN KEY (DNI_empleado_veterinario) REFERENCES VETERINARIO(DNI_empleado)
            ON DELETE RESTRICT
            ON UPDATE RESTRICT;
      
-- En la tabla AFECCION se quiere cambiar el nombre de la columna "gravedad" por "magnitud":
ALTER TABLE AFECCION
    RENAME COLUMN gravedad TO magnitud;
    
    
-- Se quiere renombrar la tabla DIAGNOSTICA a DICTAMINA:
ALTER TABLE DIAGNOSTICA
    RENAME TO DICTAMINA;
  
  
-- Se quiere cambiar el comentario de la columna "nombre_afeccion" en la tabla SINTOMAS para ajustarlo al cambio de DIAGNOSTICA por DICTAMINA; como es la clave foránea de AFECCION, primero habrá que eliminar la restricción:
ALTER TABLE SINTOMAS
	DROP FOREIGN KEY SINTOMAS_FK_AFECCION;
  
-- Se cambia el comentario:
ALTER TABLE SINTOMAS
    MODIFY COLUMN nombre_afeccion varchar(60) COMMENT "Clave foránea que identifica la afección en la tabla AFECCION que ha sido dictaminada.";
  
-- Y se vuelve a añadir la clave foránea:
ALTER TABLE SINTOMAS
	ADD CONSTRAINT SINTOMAS_FK_AFECCION 
		FOREIGN KEY (nombre_afeccion) REFERENCES AFECCION(nombre);
        

-- En la tabla DIETA se quiere establecer un valor por defecto a la columna observaciones:
ALTER TABLE DIETA
    ALTER COLUMN observaciones SET DEFAULT 'Sin observaciones.';
  

-- No todos los contactos de un empleado tienen que ser familiares, así que se cambia el nombre a la tabla FAMILIAR:
ALTER TABLE FAMILIAR
    RENAME AS CONTACTO,
    RENAME COLUMN cod_familiar TO cod_contacto;

-- Y por consiguiente se modifican las tablas TIENE y TELEFONO_FAMILIAR:
ALTER TABLE TIENE
    CHANGE COLUMN cod_familiar cod_contacto INT COMMENT "Identifica en la tabla CONTACTO al contacto que tiene el empleado.",
    CHANGE COLUMN codigo_empleado DNI_empleado CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla EMPLEADO." FIRST,
    DROP PRIMARY KEY,
    DROP FOREIGN KEY TIENE_FK_FAMILIAR,
    ADD CONSTRAINT TIENE_PK 
    		PRIMARY KEY(DNI_empleado, cod_contacto),
    ADD CONSTRAINT TIENE_FK_EMPLEADO
        FOREIGN KEY (DNI_empleado) REFERENCES EMPLEADO(DNI)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    ADD CONSTRAINT TIENE_FK_CONTACTO 
        FOREIGN KEY (cod_contacto) REFERENCES CONTACTO(cod_contacto)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT;    
        
        
ALTER TABLE TELEFONO_FAMILIAR
    RENAME TO TELEFONO_CONTACTO;
  
ALTER TABLE TELEFONO_CONTACTO
    CHANGE COLUMN cod_familiar cod_contacto INT COMMENT "Identifica al familiar en la tabla CONTACTO.";

ALTER TABLE TELEFONO_CONTACTO
    DROP PRIMARY KEY,
    ADD CONSTRAINT TELEFONO_CONTACTO_PK
        PRIMARY KEY (cod_contacto, telefono),
    ADD CONSTRAINT TELEFONO_CONTACTO_FK_CONTACTO
        FOREIGN KEY (cod_contacto) REFERENCES CONTACTO(cod_contacto)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT;
      
-- Hay que modificar tambien la tabla TELEFONO_EMPLEADO para ajustarla a los cambios de la tabla EMPLEADO:
ALTER TABLE TELEFONO_EMPLEADO
    CHANGE COLUMN codigo_empleado DNI_empleado CHAR(9) NOT NULL COMMENT "DNI del empleado e identificador del mismo en la tabla EMPLEADO." FIRST,
    DROP PRIMARY KEY,
    ADD CONSTRAINT TELEFONO_EMPLEADO_PK
        PRIMARY KEY (DNI_empleado, telefono),
    ADD CONSTRAINT TELEFONO_EMPLEADO_FK_EMPLEADO
        FOREIGN KEY (DNI_empleado) REFERENCES EMPLEADO(DNI)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT;
      

-- Se quiere añadir el valor "Otra" entre los posibles para la columna "tipo", y ajustarlo como el valor por defecto:
ALTER TABLE TIPO
    MODIFY COLUMN tipo ENUM("Prot","Fib","Veg","Omn","Car","Gran","Otra") COMMENT "Debe elegirse uno de los tipos a los que pertenece la dieta, siendo 'Prot' modificada en proteínas, 'Fib' para alta en fibra, 'Veg' para vegetariana, 'Omn' para omnívora, 'Car' carnívora, 'Gran' para granívora y 'Otra' para otra.";

ALTER TABLE TIPO
    ALTER COLUMN tipo SET DEFAULT 'Otra';
  
  
  -- En la tabla ALIMENTO se quiere añadir una nueva columna para las grasas saturadas, que no podrán estar en una cantidad mayor que las grasas totales:
ALTER TABLE ALIMENTO 
    ADD COLUMN grasas_saturadas DECIMAL (5,2) NOT NULL COMMENT "Gramos de grasas saturadas por cada 100 gramos de alimento; si no hay, el valor debe ser 0." AFTER grasas,
    ADD CONSTRAINT ALIMENTO_grasas_saturadas_no_negativo
      CHECK (grasas_saturadas >= 0),
    ADD CONSTRAINT ALIMENTO_grasas_no_superior_a_grasas
      CHECK (grasas >= grasas_saturadas);
    
-- En la tabla COMPONE se quiere aumentar la cantidade mínima de un alimento a medio gramo:
ALTER TABLE COMPONE
    DROP CONSTRAINT COMPONE_cantidad_positiva,
    ADD CONSTRAINT COMPONE_cantidad_minimo_1_gramo CHECK (cantidad >= 0.5);
  
  
-- Se quieren renombrar los campos de los apellidos en la tabla CLIENTE:
ALTER TABLE CLIENTE
    RENAME COLUMN apellido_1 TO primer_apellido,
    RENAME COLUMN apellido_2 TO segundo_apellido;
  
-- En la tabla TELEFONO_CLIENTE se quiere asegurar que todos los teléfonos insertados empiecen por "+" y continúen por dígitos.
ALTER TABLE TELEFONO_CLIENTE
    ADD CONSTRAINT TELEFONO_CLIENTE_formato_correcto
        CHECK (telefono LIKE '+[0-9]%');
    
-- De la tabla MEMBRESIA se quiere quitar el valor por defecto de "tipo_membresia":
ALTER TABLE MEMBRESIA
    ALTER COLUMN tipo_membresia DROP DEFAULT;
  
-- En la tabla ENTRADA se elimina la columna "tipo_de_entrada" porque se llega a la conclusión de que con "n_membresia" se puede saber si es una entrada ordinaria o por membresía.
ALTER TABLE ENTRADA
    DROP COLUMN tipo_de_entrada;
  
  
-- En la columna "tipo_membresia" de la tabla MEMBRESIA se ha decidido asignar como valor por defecto la membresía estandar (Sta):
ALTER TABLE MEMBRESIA
    ALTER COLUMN tipo_membresia SET DEFAULT "Sta";