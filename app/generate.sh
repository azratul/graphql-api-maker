#!/bin/sh

generate(){
    cd ${root}/graph
    # Go: obtiene definición de una o más tablas y escribe en filesystem un
    # archivo con esquema en estándar GraphQL
    ${tools}/graphql-schema-generator -motor="oracle" -schema="${_db_schema}" \
        -dsn="${_db_user}/${_db_password}@(DESCRIPTION=(LOAD_BALANCE=ON)(FAILOVER=ON)\
        (ADDRESS=(PROTOCOL=${_db_proto})(HOST=${_db_host})(PORT=${_db_port}))\
        (CONNECT_DATA=(SERVER=DEDICATED)(${_db_sid_or_sn}=${_db_service_name})))" -entities=${tables}
    # Go: obtiene definición de una o más tablas y escribe en filesystem un archivo
    # con queries de select, update e insert
    ${tools}/query-generator -motor="oracle" -schema="${_db_schema}" \
        -dsn="${_db_user}/${_db_password}@(DESCRIPTION=(LOAD_BALANCE=ON)(FAILOVER=ON)\
        (ADDRESS=(PROTOCOL=${_db_proto})(HOST=${_db_host})(PORT=${_db_port}))\
        (CONNECT_DATA=(SERVER=DEDICATED)(${_db_sid_or_sn}=${_db_service_name})))" -entities=${tables}
    rm schema.resolvers.go
    # Go: Third party app que genera el scaffolding en base al esquema generado
    # por graphql-schema-generator
    GO111MODULE=on go run github.com/99designs/gqlgen generate
    sed -i 's/:".*"/& db\U&/g' model/models_gen.go
    sed -i '10i\\t"'"${_git_repo}/${project}.git/graph/utils\"" schema.resolvers.go
    sed -i '10i\\t"'"${_git_repo}/${project}.git/database\"" schema.resolvers.go
    sed -i '10i\\t"'"log\"" schema.resolvers.go
    sed -i '10i\\t"'"errors\"" schema.resolvers.go
}

