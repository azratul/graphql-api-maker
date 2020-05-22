#!/bin/sh

commit() {
    cd ${root}
    git init
    git add .
    git commit -am 'First commit'
    git push --set-upstream https://${_git_repo}/${project}.git master
    git remote add origin https://${_git_repo}/${project}.git
    echo "The repo was successfully created, BUT YOU HAVE TO CHANGE THE VISIBILITY MANUALLY TO 'INTERNAL'"
    echo "Go to: Settings->General->Visibility, project features, permissions"
}

