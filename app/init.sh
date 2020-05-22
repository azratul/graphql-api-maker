#!/bin/sh

init(){
    # Copia de los templates base para openfaas y conexión a DB Oracle
    # (TODO: add some more dbs[_db_motor var])
    cp -r ${template} ${root}
    cd ${root}
    upper=$(echo "${project}" | tr '[:lower:]' '[:upper:]')
    # Replace de tags de templates por variables del proyecto
    grep -rl '{template}' . | xargs sed -i "s/{template}/${project}/g"
    grep -rl '{git_repo}' . | xargs sed -i "s|{git_repo}|${_git_repo}|g"
    grep -rl '{TEMPLATE}' . | xargs sed -i "s/{TEMPLATE}/${upper}/g"
    mv ./openfaas/\{template\}.yml ./openfaas/${project}.yml
    mv ./openfaas/\{template\}-dev.yml ./openfaas/${project}-dev.yml
    mv ./openfaas/\{template\} ./openfaas/${project}
    # Creación de archivo de variables de entorno con la query connection string
    printf "export DB_USER=\"${_db_user}\"\n\
export DB_PASSWORD=\"${_db_password}\"\n\
export DB_PROTO=\"${_db_proto}\"\n\
export DB_HOST=\"${_db_host}\"\n\
export DB_PORT=\"${_db_port}\"\n\
export DB_SCHEMA=\"${_db_schema}\"\n\
export DB_SID_OR_SN=\"${_db_sid_or_sn}\"\n\
export DB_SERVICE_NAME=\"${_db_service_name}\"\n\
export HC_DELAY=0\n\
export HC_TIMEOUT=1\n\
export HC_EXECUTION_PERIOD=30\n" > .env
    openfaas_vars="DB_USER: ${_db_user}\n\
      DB_PASSWORD: ${_db_password}\n\
      DB_PROTO: ${_db_proto}\n\
      DB_HOST: ${_db_host}\n\
      DB_PORT: ${_db_port}\n\
      DB_SCHEMA: ${_db_schema}\n\
      DB_SID_OR_SN: ${_db_sid_or_sn}\n\
      DB_SERVICE_NAME: ${_db_service_name}\n\
      HC_DELAY: 0\n\
      HC_TIMEOUT: 1\n\
      HC_EXECUTION_PERIOD: 30\n"
    openfaas_vars_tpl="DB_USER: \n\
      DB_PASSWORD: \n\
      DB_PROTO: \n\
      DB_HOST: \n\
      DB_PORT: \n\
      DB_SCHEMA: \n\
      DB_SID_OR_SN: \n\
      DB_SERVICE_NAME: \n\
      HC_DELAY: 0\n\
      HC_TIMEOUT: 1\n\
      HC_EXECUTION_PERIOD: 30\n"
    go mod init ${_git_repo}/${project}.git
    # Go: Third party app que genera el scaffolding inicial del proyecto
    GO111MODULE=on go run github.com/99designs/gqlgen init
    go mod edit -require github.com/jmoiron/sqlx@master
    sed -i '7i\\t"'"strconv\"" server.go
    sed -i '11i\\t"'"${_git_repo}/${project}.git/healthchecks\"" server.go
    sed -i '11i\\thealth "'"github.com/AppsFlyer/go-sundheit\"" server.go
    sed -i '11i\\thealthhttp "'"github.com/AppsFlyer/go-sundheit/http\"" server.go
    sed -i '21i\\tdelay, _ := strconv.Atoi(os.Getenv("HC_DELAY"))' server.go
    sed -i '22i\\ttimeout, _ := strconv.Atoi(os.Getenv("HC_TIMEOUT"))' server.go
    sed -i '23i\\texecutionPeriod, _ := strconv.Atoi(os.Getenv("HC_EXECUTION_PERIOD"))' server.go
    sed -i '29i\\th := health.New()' server.go
    sed -i '30i\\tdb := map[string]string{' server.go
    sed -i '31i\\t'$'\t''"endpoint": os.Getenv("DB_HOST")+":"+os.Getenv("DB_PORT"),' server.go
    sed -i '32i\\t'$'\t''"type": "db",' server.go
    sed -i '33i\\t}' server.go
    sed -i '34i\\t''services := map[string]map[string]string{' server.go
    sed -i '35i\\t'$'\t\t''"DB.Check" : db,' server.go
    sed -i '36i\\t'$'\t''}' server.go
    sed -i '37i\\tgo healthchecks.Register(h, services, delay, timeout, executionPeriod)\n' server.go
    sed -i '43i\\thttp.Handle("/healthcheck", healthhttp.HandleHealthJSON(h))' server.go
    sed -i 's/{OPENFAAS_VARS}/'"${openfaas_vars_tpl}"'/g' ./openfaas/${project}.yml
    sed -i 's/{OPENFAAS_VARS}/'"${openfaas_vars}"'/g' ./openfaas/${project}-dev.yml
}

