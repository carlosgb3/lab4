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

