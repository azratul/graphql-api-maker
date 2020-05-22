#!/bin/sh

implementTable(){
    table=$1
    # Scrapping del archivo generado por query-generator que extrae las queries y definición
    select=$(grep "^${table}:SELECT " ${root}/graph/queries.txt | cut -f2- -d:)
    insert=$(grep "^${table}:INSERT " ${root}/graph/queries.txt | cut -f2- -d:)
    update=$(grep "^${table}:UPDATE " ${root}/graph/queries.txt | cut -f2- -d:)
    definition=$(grep "^${table}:DEFINITION:" ${root}/graph/queries.txt | cut -f3- -d:)
    IFS=';' read -r -a column <<< "${definition}"

    # Replace del archivo autogenerado por GQLGen por las queries scrappeadas de query-generator
    titleTable="${table//_/ }"
    titleTable=$(echo ${titleTable} | sed -e "s/\b\(.\)/\u\1/g")
    titleTable="${titleTable// /}"
    line_select=$(($(grep -n "^func .* GetRow${titleTable}" ${root}/graph/schema.resolvers.go | cut -f1 -d:) + 1))
    line_selectall=$(($(grep -n "^func .* GetRows${titleTable}" ${root}/graph/schema.resolvers.go | cut -f1 -d:) + 1))
    line_insert=$(($(grep -n "^func .* Create${titleTable}" ${root}/graph/schema.resolvers.go | cut -f1 -d:) + 1))
    line_update=$(($(grep -n "^func .* Update${titleTable}" ${root}/graph/schema.resolvers.go | cut -f1 -d:) + 1))

    count=1
    new=""
    while IFS= read -r LINE
    do
        # Implementación de Query de GraphQL (con Select de base de datos relacional)
        if [ $line_select == $count ]
        then
            LINE=$'\t'"db, err := database.Con()"
            LINE=${LINE}$'\n\t'"if err != nil {"
            LINE=${LINE}$'\n\t\t'"log.Println(\"Error: %s\", err)"
            LINE=${LINE}$'\n\t'"}"
            LINE=${LINE}$'\n\t'"${table} := &model.${titleTable}{}"
            LINE=${LINE}$'\n\t'"query := \"${select}\""
            LINE=${LINE}$'\n\t'"if filter != nil {"

            for col in "${column[@]}"
            do
                IFS=',' read -r -a x <<< "${col}"
                LINE=${LINE}$'\n\t\t'"if filter.${x[0]} != nil {"

                data_type=""
                if [ ${x[2]} == "string" ] || [ ${x[2]} == "time" ]
                then
                    data_type="'%s'"
                elif [ ${x[2]} == "int" ]
                then
                    data_type="%d"
                elif [ ${x[2]} == "float" ]
                then
                    data_type="%f"
                elif [ ${x[2]} == "bool" ]
                then
                    data_type="%t"
                fi

                LINE=${LINE}$'\n\t\t\t'"query += fmt.Sprintf(\" AND ${x[1]} = ${data_type} \", *filter.${x[0]})"
                LINE=${LINE}$'\n\t\t'"}"
            done

            LINE=${LINE}$'\n\t'"}"
            LINE=${LINE}$'\n\t'"err = db.Get(${table}, query)"
            LINE=${LINE}$'\n\t'"if err != nil {"
            LINE=${LINE}$'\n\t\t'"log.Println(\"Error: %s\", err)"
            LINE=${LINE}$'\n\t'"}"
            LINE=${LINE}$'\n\t'"db.Close()"
            LINE=${LINE}$'\n\t'"return ${table}, err"
        fi

        # Implementación de Query de GraphQL (con Select de base de datos relacional)
        if [ $line_selectall == $count ]
        then
            LINE=$'\t'"db, err := database.Con()"
            LINE=${LINE}$'\n\t'"if err != nil {"
            LINE=${LINE}$'\n\t\t'"log.Println(\"Error: %s\", err)"
            LINE=${LINE}$'\n\t'"}"
            LINE=${LINE}$'\n\t'"${table} := []*model.${titleTable}{}"
            LINE=${LINE}$'\n\t'"params := false"
            LINE=${LINE}$'\n\t'"query := \"${select}\""
            LINE=${LINE}$'\n\t'"if filter != nil {"

            for col in "${column[@]}"
            do
                IFS=',' read -r -a x <<< "${col}"
                LINE=${LINE}$'\n\t\t'"if filter.${x[0]} != nil {"

                data_type="%s"
                filter=""
                if [ ${x[2]} == "string" ]
                then
                    data_type="'%s'"
                    filter="utils.JoinStringpSlice(filter.${x[0]}, \"','\")"
                elif [ ${x[2]} == "int" ]
                then
                    filter="utils.JoinIntpSlice(filter.${x[0]}, \",\")"
                elif [ ${x[2]} == "float" ]
                then
                    filter="utils.JoinFloatpSlice(filter.${x[0]}, \",\")"
                elif [ ${x[2]} == "bool" ]
                then
                    filter="utils.JoinBoolpSlice(filter.${x[0]}, \",\")"
                elif [ ${x[2]} == "time" ]
                then
                    filter="utils.JoinTimepSlice(filter.${x[0]}, \",\")"
                fi

                LINE=${LINE}$'\n\t\t\t'"query += fmt.Sprintf(\" AND ${x[1]} IN (${data_type}) \", ${filter})"
                LINE=${LINE}$'\n\t\t'"}"
            done

            LINE=${LINE}$'\n\t\t'"params = true"
            LINE=${LINE}$'\n\t'"}"

            LINE=${LINE}$'\n\t'"if pagination != nil {"
            LINE=${LINE}$'\n\t\t'"params = true"
            LINE=${LINE}$'\n\t'"}"

            LINE=${LINE}$'\n\t'"if params == true {"
            LINE=${LINE}$'\n\t\t'"query = utils.QueryPagination(query, pagination)"
            LINE=${LINE}$'\n\t\t'"err = db.Select(&${table}, query)"
            LINE=${LINE}$'\n\t\t'"if err != nil{"
            LINE=${LINE}$'\n\t\t\t'"log.Println(err)"
            LINE=${LINE}$'\n\t\t'"}"
            LINE=${LINE}$'\n\t'"} else {"
            LINE=${LINE}$'\n\t\t'"err = errors.New(\"Debes pasar al menos un parámetro\")"
            LINE=${LINE}$'\n\t'"}"

            LINE=${LINE}$'\n\t'"db.Close()"
            LINE=${LINE}$'\n\t'"return ${table}, err"
        fi

        # Implementación de Mutation(Create) de GraphQL (con Insert de base de datos relacional)
        if [ $line_insert == $count ]
        then
            LINE=$'\t'"${table} := &model.${titleTable}{}"
            LINE=${LINE}$'\n\t'"db, err := database.Con()"
            LINE=${LINE}$'\n\t'"if err != nil {"
            LINE=${LINE}$'\n\t\t'"log.Println(\"Error: %s\", err)"
            LINE=${LINE}$'\n\t'"}"
            LINE=${LINE}$'\n\t'"columns := \"\""
            LINE=${LINE}$'\n\t'"values  := \"\""
            IN_COLUMNS=""
            for col in "${column[@]}"
            do
                IFS=',' read -r -a x <<< "${col}"

                NULLABLE=""

                [ ${x[3]} == "N" ] && NULLABLE="&"

                LINE=${LINE}$'\n\t'"if ${NULLABLE}input.${x[0]} != nil {"
                LINE=${LINE}$'\n\t\t'"${table}.${x[0]} = input.${x[0]}"
                LINE=${LINE}$'\n\t\t'"columns += \"${x[1]},\""
                LINE=${LINE}$'\n\t\t'"values  += \":${x[1]},\""
                LINE=${LINE}$'\n\t'"}"

                IN_COLUMNS="${IN_COLUMNS}${table}.${x[0]},"
            done
            LINE=${LINE}$'\n\t'"query := fmt.Sprintf(\"${insert}\", columns[:len(columns)-1], values[:len(values)-1])"
            LINE=${LINE}$'\n\t'"_, err = db.NamedExec(query, ${table})"
            LINE=${LINE}$'\n\t'"db.Close()"
            LINE=${LINE}$'\n\t'"return ${table}, err"
        fi

        # Implementación de Mutation(Update) de GraphQL (con Update de base de datos relacional)
        if [ $line_update == $count ]
        then
            LINE=$'\t'"if filter != nil {"
            LINE=${LINE}$'\n\t\t'"${table} := &model.${titleTable}{}"
            LINE=${LINE}$'\n\t\t'"db, err := database.Con()"
            LINE=${LINE}$'\n\t\t'"if err != nil {"
            LINE=${LINE}$'\n\t\t\t'"log.Println(\"Error: %s\", err)"
            LINE=${LINE}$'\n\t\t'"}"
            LINE=${LINE}$'\n\t\t'"where := \"\""
            LINE=${LINE}$'\n\t\t'"sets := \"\""

            for col in "${column[@]}"
            do
                IFS=',' read -r -a x <<< "${col}"

                data_type=""
                if [ ${x[2]} == "string" ] || [ ${x[2]} == "time" ]
                then
                    data_type="'%s'"
                elif [ ${x[2]} == "int" ]
                then
                    data_type="%d"
                elif [ ${x[2]} == "float" ]
                then
                    data_type="%f"
                elif [ ${x[2]} == "bool" ]
                then
                    data_type="%t"
                fi

                NULLABLE=""
                [ ${x[3]} == "N" ] && NULLABLE="*"

                LINE=${LINE}$'\n\t\t'"if input.${x[0]} != nil {"
                LINE=${LINE}$'\n\t\t\t'"${table}.${x[0]} = ${NULLABLE}input.${x[0]}"
                LINE=${LINE}$'\n\t\t\t'"sets += \"${x[1]}=:${x[1]},\""
                LINE=${LINE}$'\n\t\t'"}"

                LINE=${LINE}$'\n\t\t'"if filter.${x[0]} != nil {"
                LINE=${LINE}$'\n\t\t\t'"where += fmt.Sprintf(\" AND ${x[1]} = ${data_type} \", *filter.${x[0]})"
                LINE=${LINE}$'\n\t\t'"}"
            done
            LINE=${LINE}$'\n\t\t'"query := fmt.Sprintf(\"${update}%s\", sets[:len(sets)-1], where[:len(where)-1])"
            LINE=${LINE}$'\n\t\t'"_, err = db.NamedExec(query, ${table})"
            LINE=${LINE}$'\n\t\t'"db.Close()"
            LINE=${LINE}$'\n\t\t'"return ${table}, err"
            LINE=${LINE}$'\n\t'"}"
            LINE=${LINE}$'\n\t'"return nil, fmt.Errorf(\"Se requiere a lo menos un parámetro de filtro\")"
        fi

        new=${new}$'\n'${LINE}
        count=$(($count+1))
    done < ${root}/graph/schema.resolvers.go
    echo -E "$new" > ${root}/graph/schema.resolvers.go
}

