/*
Borro las tablas si existen
*/
DROP TABLE IF EXISTS public.nacimiento;

DROP TABLE IF EXISTS public.departamento;

DROP TABLE IF EXISTS public.provincia;

/* Creo las tablas para la base de datos definitiva, respetando todas las formas normales
Las formas normales son reglas que se aplican a las bases de datos relacionales para asegurar la integridad de los datos, evitar la redundancia y facilitar la eficiencia de las operaciones de la base de datos. Hay varias formas normales, cada una con sus propias reglas. Aquí están las tres primeras:
1. Primera Forma Normal (1NF): Cada columna de una tabla debe contener valores atómicos (indivisibles) y cada valor en una columna debe ser del mismo tipo. Además, cada fila debe ser única.
2. Segunda Forma Normal (2NF): Se aplica a las bases de datos con claves primarias compuestas (más de un campo en la clave primaria). Para cumplir con la 2NF, todos los campos no clave de la tabla deben depender de toda la clave primaria, no solo de una parte de ella.
3. Tercera Forma Normal (3NF): Una tabla está en 3NF si está en 2NF y además, los campos no clave no deben tener dependencias entre sí. Es decir, cada campo no clave debe depender solo de la clave primaria.
Existen formas normales más avanzadas como la Cuarta Forma Normal (4NF), Quinta Forma Normal (5NF) o la Forma Normal de Boyce-Codd (BCNF), pero las tres primeras son las más utilizadas y suelen ser suficientes para la mayoría de las aplicaciones.
*/
CREATE TABLE public.nacimiento (
    id serial,
    departamento_id INTEGER,
    provincia_id INTEGER,
    anio INTEGER,
    cantidad_nacimientos INTEGER,
    poblacion_total INTEGER,
    tbn FLOAT
);

CREATE TABLE public.departamento (
    id BIGINT,
    nombre VARCHAR,
    nombre_completo VARCHAR,
    centroide_lat FLOAT,
    centroide_lon FLOAT,
    categoria VARCHAR,
    provincia_id BIGINT
);

CREATE TABLE public.provincia (
    id BIGINT,
    nombre VARCHAR,
    nombre_completo VARCHAR,
    centroide_lat FLOAT,
    centroide_lon FLOAT,
    categoria VARCHAR
);

/*
Agrego las restricciones de clave primaria y foránea a las tablas
*/
ALTER TABLE public.nacimiento
ADD CONSTRAINT pk_nacimiento PRIMARY KEY (id);

ALTER TABLE public.provincia
ADD CONSTRAINT pk_provincia PRIMARY KEY (id);

ALTER TABLE public.departamento
ADD CONSTRAINT pk_departamento PRIMARY KEY (id);

ALTER TABLE public.departamento
ADD CONSTRAINT fk_departamento_provincia FOREIGN KEY (provincia_id) REFERENCES provincia (id);

ALTER TABLE public.nacimiento
ADD CONSTRAINT fk_nacimiento_departamento FOREIGN KEY (departamento_id) REFERENCES departamento (id);

/*
Creo las tablas temporales para cargar los datos
*/
CREATE TEMPORARY TABLE temp_departamentos (
    categoria VARCHAR,
    centroide_lat FLOAT,
    centroide_lon FLOAT,
    fuente VARCHAR,
    id VARCHAR,
    nombre VARCHAR,
    nombre_completo VARCHAR,
    provincia_id VARCHAR,
    provincia_interseccion FLOAT,
    provincia_nombre VARCHAR
);

CREATE TEMPORARY TABLE provincias_temp (
    categoria VARCHAR,
    centroide_lat FLOAT,
    centroide_lon FLOAT,
    fuente VARCHAR,
    id VARCHAR,
    iso_id VARCHAR,
    iso_nombre VARCHAR,
    nombre VARCHAR,
    nombre_completo VARCHAR
);

CREATE TEMPORARY TABLE temp_nacimiento (
    provincia_id TEXT,
    provincia_nombre VARCHAR,
    departamento_id TEXT,
    departamento_nombre VARCHAR,
    anio INTEGER,
    nacimientos_cantidad INTEGER,
    poblacion_total INTEGER,
    tbn FLOAT
);

/*
Cargo los datos en las tablas temporales
*/
COPY provincias_temp
FROM '/datos/provincias.csv' DELIMITER ',' CSV HEADER;

INSERT INTO
    public.provincia (
        id,
        nombre,
        nombre_completo,
        centroide_lat,
        centroide_lon,
        categoria
    )
SELECT
    CASE WHEN id = 'NA' THEN 46 ELSE id::INTEGER END,
    nombre,
    nombre_completo,
    centroide_lat,
    centroide_lon,
    categoria
FROM provincias_temp;

COPY temp_departamentos
FROM '/datos/departamentos.csv' DELIMITER ',' CSV HEADER;

INSERT INTO
    public.departamento (
        id,
        nombre,
        nombre_completo,
        centroide_lat,
        centroide_lon,
        categoria,
        provincia_id
    )
SELECT
    id::INTEGER,
    nombre,
    nombre_completo,
    centroide_lat,
    centroide_lon,
    categoria,
    provincia_id::INTEGER
FROM temp_departamentos;

/* 
Debemos insertar el departamento con id = 0 para casos especiales (por ejemplo, Ciudad Autónoma de Buenos Aires).
*/
INSERT INTO public.departamento (id, nombre) VALUES (0, 'No definido');

COPY temp_nacimiento
FROM '/datos/nacimientos_por_departamento_y_anio_2012_2022.csv' DELIMITER ',' CSV HEADER;

/*
Cargo los datos en las tablas definitivas
*/

/*
INSERT INTO
    public.provincia (id, nombre)
SELECT DISTINCT
    provincia_id,
    provincia_nombre
FROM temp_nacimiento
WHERE
    provincia_id NOT IN (
        SELECT id
        FROM public.provincia
    );

INSERT INTO
    public.departamento (id, nombre)
SELECT DISTINCT
    departamento_id,
    departamento_nombre
FROM temp_nacimiento
WHERE
    departamento_id NOT IN (
        SELECT id
        FROM public.departamento
    );
*/

INSERT INTO
    public.nacimiento (
        departamento_id,
        anio,
        cantidad_nacimientos,
        poblacion_total,
        tbn 
    )
SELECT
    CASE
        WHEN departamento_id = 'NA' THEN 0
        ELSE departamento_id::INTEGER
    END,
    anio,
    nacimientos_cantidad,
    poblacion_total,
    tbn
FROM temp_nacimiento;