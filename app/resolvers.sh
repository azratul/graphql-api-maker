#!/bin/sh

resolvers(){
    IFS=',' read -r -a table <<< "${tables}"

    for t in "${table[@]}"
    do
        # Por cada tabla se implementan los resolvers
        implementTable ${t}
    done

    rm ${root}/graph/queries.txt
}

