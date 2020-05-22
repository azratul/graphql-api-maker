#!/bin/sh

project=${1}
tables=$(echo "${2}" | tr '[:upper:]' '[:lower:]')
config=$(sed -n '/^-'"${3}"'/,/^-.*/{/^-'"${3}"'/b;/^-.*/b;p}' .config)
tools=$(pwd)/tools
template=$(pwd)/template
root=$(pwd)/generated/${project}

# YAML files parser
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   echo "${1}" | sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

. app/init.sh
. app/generate.sh
. app/resolvers.sh
. app/implementTable.sh
. app/commit.sh

# Read the dotfile and convert in shell vars
eval $(parse_yaml "${config}")
# Start project
init
# GQLGen create the scaffolding
generate
# Implementation of resolvers
resolvers
# Commit y push to git repo
#commit
