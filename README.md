# API Maker

## Intro

This project is in development stage. Thanks to [GqlGen Project!](https://github.com/99designs/gqlgen).

## How to use it

1. Download the project

    `git clone https://github.com/graphql-api-maker.git`

2. Enter to the project's folder

    `cd maker`

3. Copy or rename the YAML file to .config and replace it with your settings.

    `cp config.yml .config`

4. Run the script with these params: project's name, table's name and config tag. Ex. `./run.sh example-project table orcl_example`

    `./run.sh {project_name} {table} {config_tag}`

5. Enter to the generated project folder and run it

    `cd generated/{project_name}`

    `make go-run`
