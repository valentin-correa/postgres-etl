echo "Muestra la cantidad de nacimientos por año en el departamento General San Martín de Córdoba de forma descendente"
SELECT anio AS "Año", cantidad_nacimientos as "Cantidad Nacimiento", departamento.nombre AS "Departamento"
FROM nacimiento
INNER JOIN departamento ON (nacimiento.departamento_id = departamento.id) 
INNER JOIN provincia ON (departamento.provincia_id = provincia.id)
WHERE provincia.nombre = 'Córdoba' AND departamento.nombre = 'General San Martín' 
ORDER BY nacimiento.cantidad_nacimientos DESC
;

echo "Muestra los 3 departamentos con menor cantidad de nacimientos en el año 2022"
SELECT departamento.nombre AS "Departamento", cantidad_nacimientos as "Cantidad Nacimiento", anio AS "Año"
FROM nacimiento
INNER JOIN departamento ON (nacimiento.departamento_id = departamento.id) 
WHERE anio = 2022 
ORDER BY nacimiento.cantidad_nacimientos
LIMIT 3
;

echo "Muestra los 3 departamentos con mayor cantidad de nacimientos en el año 2022"
SELECT departamento.nombre AS "Departamento", cantidad_nacimientos as "Cantidad Nacimiento", anio AS "Año"
FROM nacimiento
INNER JOIN departamento ON (nacimiento.departamento_id = departamento.id) 
WHERE anio = 2022 
ORDER BY nacimiento.cantidad_nacimientos DESC
LIMIT 3
;

echo "Muestra la cantidad de nacimientos por provincia entre 2012-2022 de manera descendente"
SELECT provincia.nombre AS "Provincia", SUM(nacimiento.cantidad_nacimientos) AS "Total Nacimientos 2012-2022"
FROM public.nacimiento 
INNER JOIN public.departamento ON (nacimiento.departamento_id = departamento.id)
INNER JOIN public.provincia ON (departamento.provincia_id = provincia.id)
GROUP BY provincia.nombre
ORDER BY "Total Nacimientos 2012-2022" DESC
;