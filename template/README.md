# {template}

Proyecto que funciona como reemplazo a una tabla en Oracle, entregando un listado de las {template}.

El proyecto se encuentra desarrollado utilizando [Golang](https://golang.org/) 1.13.5, [GQLGen](https://github.com/99designs/gqlgen/handler) para el soporte a GraphQL y [OpenFaaS](https://github.com/openfaas/faas-cli), también se utilizaron las bibliotecas [godror](https://github.com/godror/godror) como driver de Oracle y [SQLx](https://github.com/jmoiron/sqlx) como handler de acceso a datos.

## Desarrollo local

### Requerimientos para desarrollar

Para poder contribuir con el proyecto es necesario

 - Tener instalado [go](https://golang.org/doc/install), [OpenFaaS](https://github.com/openfaas/faas-cli) y [Oracle Instant Client] Light(https://www.oracle.com/database/technologies/instant-client/downloads.html)

### Para comenzar a desarrollar
1. Obtener el proyecto del repositorio

    `git clone https://github.com/user/{template}`

2. Ingresar a la carpeta donde se ubica el proyecto

    `cd {template}`

3. Obtener las dependencias

    `go mod download`

**Ahora estás listo para comenzar a contribuir al proyecto**

Recuerda que después de contribuir al proyecto debes actualizar las dependencias antes de subir al repositorio.

**Ahora puede subir al repositorio sin problemas**

## Ejecución del proyecto de forma local

### Para ejecutar el proyecto a través de su archivo binario (Debes tener Oracle instant client)

1. Obtener el proyecto del repositorio

    `git clone https://github.com/user/{template}`

2. Ingresar a la carpeta donde se ubica el proyecto

    `cd {template}`

3. Ejecutar el proyecto

    `make go-run`

4. Puedes probar la función ingresando una petición con cURL

    `curl 'http://localhost:8080/query' -H 'Content-Type: application/json' -H 'Accept: application/json' --data-binary '{"query":"query {get{template}( filter : { atributo : valor } ) { atributo1 atributo2 } } "}' --compressed`

