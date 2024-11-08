# Laboratorio 4
Se requiere hacer la recreación del siguiente diagrama en AWS con Terraform. El diagrama es intencionadamente impreciso para dejar abierta las soluciones según los criterios del AWS Well-Architected

<p align="center">
<img src="https://github.com/carlosgb3/lab4/blob/main/img/diagrama.png">
</p>

## Requisitos
* Definiremos un nuevo VPC con todos los componentes necesarios para que las instancias se puedan conectar a internet para actualizar las versiones de software
* Las instancias deberán ejecutar un Linux con el servicio web funcionando (apache)
* Se podrá elegir entre crear un grupo de auto escalado (ASG) con un balanceador donde el usuario se podrá conectar para ver la web desde cualquier parte del mundo por HTTPS o usar Microservicios (también por HTTPS)
* Route53 estará presente en un dominio interno propio para poder acceder a los recursos por DNS
* Finalmente instalaremos nuestro CMS favorito que nos permitirá tener una webdinámica. El requerimiento es que utilice una DB PostgreSQL
## Notas:
* Para gestionar los secretos, se debe utilizar AWS Secrets Manager
* Para la opción de ASG, el mínimo será de 2 instancias y el máximo será de 3. Para la opción de microservicios se desplegará con ECS o con EC2 + docker
* En ambas opciones se requerirá la creación un bucket de S3 para guardar imágenes y crear una distribución de CloudFront para distribuir el tráfico
* El código utilizado estará en un control de versiones, preferiblemente GIT
* Una vez finalizado el laboratorio, se deberá dar acceso al instructor para poder verificar el ejercicio
* A parte del código, se entregará una imagen con la arquitectura completa final elegida (la imagen puede estar dentro del mismo repositorio)
## Opcional:
* Se propone usar un doble balanceador de carga, el primero externo y el segundo interno
* Se propone guardar copias de seguridad en otro VPC e interconectarlos con VPCpeering
* Se propone crear un dashboard de CloudWatch donde se vean las principales métricas relevantes (uptime, rendimiento, etc)

