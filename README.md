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


# Solución
Route53 nos permite hacer el enrutamiento interno por DNS. El Nat gateway permite a las instancias salir a internet. El AutoScaling Group 
lanza las instancias adecuando la cantidad al tráfico existente y el Balanceador de carga distribuye el trafico entre ellas.
El EFS nos permite tener un almacenamiento persitente y autoescalable para compartir entre las instancias.
La BBDD es una multi AZ garantizando la H.A. La Memcache cachea las sesiones de usuario y la Redis cachea la BBDD.
Por último el bucket de S3 nos permite tener las imagenes almacenadas y cacheadas con cluudfront.
<p align="center">
<img src="https://github.com/carlosgb3/lab4/blob/main/img/diagrama-solucion-lab4.png">
</p>

## Procedimiento:
1º Creamos la VPC con un CDIR 10.0.0.0/16 con suficiente direccionamiento interno. Creamos las subnets, los routing tables, nat Gatways, 
internet gateway y los Security Groups
<p align="center">
<img src="https://github.com/carlosgb3/lab4/blob/main/img/vpc.png">
</p>

2º Creamos la AMI instalando todo el software necesario: Apache, Php, Wordpress con los plugins, el cliente de PostgreSQL, amazon efs utils. 
<p align="center">
<img src="https://github.com/carlosgb3/lab4/blob/main/img/wordpress.png">
</p>


3º Creamos el Launch template con la AMI, el Load balancer, el Target Group y el AutoScaling group. Creamos el certificado auto firmado de openSSL y se lo
instalamos en el Aplication load Balancer. Comprobamos en el Target group el estado de las instancias
<p align="center">
<img src="https://github.com/carlosgb3/lab4/blob/main/img/tg.png">
</p>

4º Por último creamos la DB, el EFS, la cache Redis, la cache Memcache y el Bucket de S3
<p align="center">
<img src="https://github.com/carlosgb3/lab4/blob/main/img/s3.png">
</p>


