# **ETL para la carga de *`datasets`* de Nacimientos en Argentina (2012-2022)**

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Apache Superset](https://img.shields.io/badge/Apache_Superset-FF5733?style=for-the-badge&logo=apache-superset&logoColor=white)
![pgAdmin](https://img.shields.io/badge/pgAdmin-316192?style=for-the-badge&logo=postgresql&logoColor=white)
## **Descripción del Proyecto**
El objetivo de este proyecto es llevar a cabo un proceso ETL(Extract, Transform, Load) a partir de un conjunto de archivos en formato CSV que presentan información sobre la cantidad anual de nacimientos en Argentina entre los años 2012 y 2022, clasificada por departamento y provincia.

Obtendremos en pocos pasos una base de datos relacional con toda la información relevante provista, permitiendo realizar todo tipo de consultas sobre la misma y hasta pudiendo generar gráficos con sus resultados mediante distintas herramientas.

Llevaremos a cabo el ETL de manera "manual", es decir, implementandolo directamente con SQL en PostgreSQL, en lugar de usar un lenguaje como Python o una herramienta específica de ETL
A continuación explicamos el paso a paso para poder reproducir y utilizar esta base de datos, empleando tan solo los archivos que se encuentran en este repositorio. 

## **Participantes del proyecto**
Barrionuevo, Imanol - barrionuevoimanol@gmail.com 

Broilo, Mateo José - broilomateo@gmail.com

Correa, Valentín - correavale2004@gmail.com 

Díaz, Gabriel - gabidiaz4231@gmail.com 

Gambino, Tomás - tomigambino21@gmail.com 

Gomez, Andrés - andresgf925@gmail.com 

Letona, Mateo - mateolet883@gmail.com 

Wursten Gill, Santiago - santiwgwuri@gmail.com 

## **Datasets utilizados**
Para este proyecto hacemos uso de 3 data sets: 

- Nacimientos en Argentina por departamento (2012 - 2022)
- Departamentos
- Provincias

Estos archivos csv, y muchisimos más con información de distintas categorías, pueden descargarse desde el portal oficial de datos abiertos del gobierno de Argentina, el cual proporciona información pública en formatos reutilizables:  

[https://datos.gob.ar/dataset](https://datos.gob.ar/dataset)

Sin embargo, cabe aclarar que ya se encuentran en el repositorio, por lo que no será necesaria su descarga por separado. 

## **Resumen del Tutorial**

Como dijimos, explicaremos el paso a paso para poder reproducir el proyecto, desde la configuración hasta la creación de tableros gráficos.

1. Clonar el repositorio.
2. Configurar archivos necesarios.
3. Levantar los servicios con Docker y configurar la conexión a la base de datos en Apache Superset.
4. Acceder a las herramientas.
5. Ejecutar consultas SQL con Superset para obtener la información deseada.
6. Crear gráficos y tableros interactivos para visualizar los datos obtenidos en las consultas.

## **Para tener en cuenta**

Será necesario antes de comenzar tener instalados los siguientes componentes:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- Navegador web para acceder a Apache Superset y pgAdmin.

Además, deberá tener Git y Github correctamente configurados para poder clonar el repositorio.

## **Definición de servicios en Docker Compose**

En el archivo `docker-compose.yml`, a partir del cual levantaremos los contenedores necesarios para este proyecto, definimos tres servicios:

-Base de datos (PostgreSQL), un sistema de gestión de bases de datos relacional (RDBMS) de código abierto.
-Apache Superset, una plataforma moderna de visualización de datos y BI (business intelligence).
-PgAdmin, una herramienta de administración web para PostgreSQL.

Las características de estos servicios se especifican en el archivo como se ve a continuación:

1. **Base de Datos (PostgreSQL):**
   - Imagen: `postgres:alpine`
   - Puertos: `5432:5432`
   - Volúmenes:
     - `postgres-db:/var/lib/postgresql/data` (almacenamiento persistente de datos)
     - `./scripts:/docker-entrypoint-initdb.d` (scripts de inicialización)
     - `./datos:/datos` (directorio para datos adicionales)
   - Variables de entorno:
     - Configuradas en el archivo `.env.db`
   - Healthcheck:
     - Comando: `pg_isready`
     - Intervalo: 10 segundos
     - Retries: 5

2. **Apache Superset:**
   - Imagen: `apache/superset:4.0.0`
   - Puertos: `8088:8088`
   - Dependencias:
     - Depende del servicio `db` y espera a que esté saludable.
   - Variables de entorno:
     - Configuradas en el archivo `.env.db`

3. **pgAdmin:**
   - Imagen: `dpage/pgadmin4`
   - Puertos: `5050:80`
   - Dependencias:
     - Depende del servicio `db` y espera a que esté saludable.
   - Variables de entorno:
     - Configuradas en el archivo `.env.db`

## **Instrucciones**
A continuación se presentan los comandos que se deben ejecutar en la terminal y tareas a realizar para llevar a cabo cada paso.

1. **Clonar el repositorio:**
   
   Clonamos el repositorio y nos "paramos" dentro del mismo.
   ```sh
   git clone <URL_DEL_REPOSITORIO>
   cd postgres-etl
   ```
   
   Esto será suficiente para disponer de todos los archivos necesarios para la ejecución del proyecto. Alternativamente podría descargar los archivos manualmente desde el repositorio de    github.

2. **Configurar el archivo `.env.db`:**
   
   Si no se encuentra en el repositorio al momento de clonarlo, crea un archivo `.env.db` en la raíz del proyecto con las siguientes variables de entorno:

   ```env
    #Definimos cada variable
    DATABASE_HOST=db
    DATABASE_PORT=5432
    DATABASE_NAME=postgres
    DATABASE_USER=postgres
    DATABASE_PASSWORD=postgres
    POSTGRES_INITDB_ARGS="--auth-host=scram-sha-256 --auth-local=trust"
    # Configuracion para inicializar postgres
    POSTGRES_PASSWORD=${DATABASE_PASSWORD}
    PGUSER=${DATABASE_USER}
    # Configuracion para inicializar pgadmin
    PGADMIN_DEFAULT_EMAIL=postgres@postgresql.com
    PGADMIN_DEFAULT_PASSWORD=${DATABASE_PASSWORD}
    # Configuracion para inicializar superset
    SUPERSET_SECRET_KEY=your_secret_key_here
   ```
   Este archivo será necesario al momento de levantar los servicios.

3. **Levantar los servicios y configurar la conexión a la base de datos en Apache Superset:**
   Ejecuta los siguientes comandos para iniciar los contenedores:
   ```sh
   docker compose up -d
   . init.sh
   ```
Si no es la primera vez que levantamos el contenedor y queremos ejecutar el script de inicialización de la base de datos (por ejemplo, porque agregamos algo), luego de "docker compose up" ejecutamos:

```bash
$ cat scripts/000_initdb.sql | docker exec -i postgres-etl-db-1 psql
```

4. **Acceder a las herramientas:**
   - **Apache Superset:** Accedemos mediante el siguiente link [http://localhost:8088/](http://localhost:8088/)  
     Nos logueamos con las credenciales predeterminadas, las definidas en el `init.sh`: ***`admin/admin`***
   - **pgAdmin:** Accedemos mediante el siguiente link [http://localhost:5050/](http://localhost:5050/)  
     Configura la conexión a PostgreSQL utilizando las credenciales definidas en el archivo `.env.db`.

Accedemos a Apache Superset y creamos una conexión a la base de datos PostgreSQL en la sección ***`Settings`***. Para esto vamos arriba a la derecha en:

 Settings -> Data/Database Connections.

Apretamos el ícono celeste donde dice **+   DATABASE**. PostgreSQL, el host lo sacamos de la ip del contenedor `postgres-etl-db-1`, puerto 5432, el nombre de la db es **postgres**, user y pass son **postgres** y nos conectamos.

Debemos asegurarnos de que la conexión sea exitosa antes de proceder. Una vez sea así:

-Vamos arriba donde dice SQL/SQL Lab. 
-Elegimos la base de datos postgres, el schema es public (esto tiene que ver con el armado del script)
-A la derecha podemos probar queries en la BD.



5.** Consultas SQL**

Ya podemos ejecutar consultas SQL para obtener la información almacenada en la base de datos. A modo de ejemplo mostramos una consulta.

#### **Consulta: Nacimientos por provincia**
Esta consulta nos permite conocer la cantidad total de nacimientos en cada provincia (teniendo en cuenta todos sus departamentos) entre los años 2012-2022, ordenandolas en orden descendente.

```sql
SELECT provincia.nombre AS "Provincia", SUM(nacimiento.cantidad_nacimientos) AS "Total Nacimientos 2012-2022"
FROM public.nacimiento 
INNER JOIN public.departamento ON (nacimiento.departamento_id = departamento.id)
INNER JOIN public.provincia ON (departamento.provincia_id = provincia.id)
GROUP BY provincia.nombre
ORDER BY "Total Nacimientos 2012-2022";
```


6. **Creación de Gráficos y Tableros**

1. Si aún no lo hiciste, ejecuta las consultas del paso anterior en ***`SQL Lab`*** de Apache Superset.
2. Haz clic en el botón ***`CREATE CHART`*** para crear gráficos interactivos.
3. Configura el tipo de gráfico y las dimensiones necesarias.
4. Si lo deseas, guarda el gráfico en un tablero con el botón ***`SAVE`***.

## **¡Gracias por llegar hasta el final!**

Esperamos que el tutorial te haya sido util, y que hayas podido ejecutar todo a la perfección. De lo contrario, más arriba podes encontrar nuestros mails para realizar cualquier consulta.
