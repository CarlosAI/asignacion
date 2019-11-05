# README
Proyecto de asignacion.

Pequeño sistema Web que a traves de un archivo JSON proporcionado.

1.	Verifica la correcta estructura del archivo JSON.
2.	Consulta a Fedex via API, informacion correspondiente indicada en el archivo JSON.
3.	Genera un reporte de resultados.


# Status Actual.

El sistema soporta un archivo JSON de hasta 20 registros, esto con el proposito de asigancion en un ambiente de pruebas/testing. Se tomo la decisión de hacerlo de esta manera por varios motivos.

1. No se especificaron aspectos tecnicos mas detallados.
2. La falta de credenciales y/o servicios de terceros para proporcionar una mejor experiencia (AWS, Redis, etc.)

El sistema funciona procesando la informacion seleccionada y generando el reporte correspondiente. En caso de que la informacion/archivo seleccionado por el usuario presente algun aspecto que no permita procesar la informacion, el sistema asi lo señalara.

Asi mismo, al estar usando el ambiente de pruebas de Fedex, en algunas ocaciones los request hacia su plataforma suelen demorarse y Fedex al haber esta demora suele detener el procesos de solicitud y regresar el estatus "Fedex is not able to process your request at this time, try later"; Sin embargo, esto no es un error critico, en caso de que esto suceda, basta con esperar un par de minutos, y volver a realizar el proceso sin ningun problema.

# Oportunidades de mejora.

Como se mencionó en el Status actual, existen 2 factores propuestas que mejorarian por mucho la calidad de este pequeño proyecto, las cuales son:

1. Implementar un servicio de Redis, para poder desarrollar servicios Sidekiq (Jobs o Workers), que permitan la escalabilidad del sistema sin la importancia del tiempo de respuesta de por medio. Se menciono anteriormente que el sistema actualmente aceptaba solo 20 registros, esto debido al tiempo de procesamiento que le toma al servidor procesar estos datos desde la carga del archivo hasta la generacion del reporte final; Entonces la implementacion de Sidekiq ayudaria al procesamiento de todos los registros sin importar el tamaño pues seria un servicio corriendo en segundo plano.

2. Uso de servicios AWS S3. Los reportes que son generados por el sistema son reportes que se "renderizan" o procesan por decirlo de alguna manera en la memoria del servidor. Con el uso de un bucket de S3, podemos generar el archivo PDF base, y subirlo directamente a un bucket de AWS S3 para despues poder via API acceder al archivo. Una de las ventajas de esto, entre muchas, es que nos quitamos este paso extra de renderizacion, pues al subir el archivo y consultarlo, accedemos ya al archivo final, proporcionando solo una url fisica del bucket en S3 para descargar el archivo indicado.


# Contributors
[CarlosAI] (https://github.com/CarlosAI) (Carlos Alberto Ivan)
