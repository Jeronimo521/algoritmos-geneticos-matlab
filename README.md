# Algoritmos genéticos en MATLAB

Práctica de Bioingeniería con tres problemas: viajero, función Ackley e inventarios. Se comparan distintos métodos de selección, cantidades de iteraciones y valores de mutación.

## Qué hay aquí

- `matlab/`: código y pruebas.
- `resultados_matlab/`: resultados de las 295 ejecuciones.
- `anexos/`: mejores soluciones de cada configuración.
- `informe/`: informe en PDF y su fuente para abrir en Overleaf.

## Cómo ejecutarlo

Descarga el repositorio y abre la carpeta `matlab` en MATLAB.

Para ver una ejecución de los tres problemas y sus gráficas:

```matlab
demo
```

Para comprobar las funciones:

```matlab
pruebasFases
```

Para comprobar los resultados que ya vienen guardados, sin repetir los experimentos:

```matlab
verificarResultadosCSV
```

Para repetir todos los experimentos:

```matlab
experimentos
```

Los resultados se guardan en `resultados_matlab`. Este paso reemplaza los archivos de resultados existentes.

Después puedes generar las gráficas y comprobar los resultados con:

```matlab
prepararResultados
```

Este último paso necesita los archivos `.mat` que genera `experimentos`; no basta con descargar los CSV.

Antes de medir cada configuración se hace una ejecución de calentamiento. Los resultados incluyen el tiempo promedio, su variación y un archivo `entorno.csv` con la versión de MATLAB utilizada.

## Cambiar las pruebas

En `configuracion.m` puedes ajustar la población, las iteraciones, el método de selección y la mutación.

Las rutas actuales son abiertas. Si quieres salir de UCO y regresar allí, activa `fijarInicioUCO` y `regresoUCO` juntos.

## Consultar los resultados

- `resumen_completo.csv`: resumen de cada configuración.
- `corridas.csv`: resultados de cada ejecución.
- `mejores_individuos.md`, dentro de `anexos/`: soluciones correspondientes a los códigos C01 a C59 del informe.
- `graficas/`, dentro de `resultados_matlab/`: gráficas de convergencia y del estudio de dimensiones.
