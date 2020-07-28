#!/bin/bash

removeSpaces() {
  echo "${1}" | xargs | tr " " -
}

createSlug() {
  tmp="$1"

  if [[ "$1" = *" "* ]]; then
    echo >&2 "Removing spaces from Project name..."
    tmp=$(removeSpaces "$1")
    echo >&2 "Project name without spaces: $tmp"
  fi

  echo "$tmp" | tr '[:upper:]' '[:lower:]'
}

checkProjectName() {
  if [[ ! "$1" =~ ^[a-zA-Z0-9-]+$ ]]; then
    echo "Project name cannot contain special characters"
    exit 1
  fi
}

run() {
  slug_name=$(createSlug "$PROJECT_NAME")

  checkProjectName $slug_name

  mkdir $CURRENT_PWD/$slug_name

  if [[ $FRAMEWORK == "ReactJS" ]]; then
    cp -r web/beagle-react/* $CURRENT_PWD/$slug_name

    cd $CURRENT_PWD/$slug_name

    sed "s,\${bff_url},$BFF_URL," -i src/beagle/beagle-service.ts
    sed "s,\${project_name},$PROJECT_NAME," -i package.json
  else
    cp -r web/beagle-angular/* $CURRENT_PWD/$slug_name

    cd $CURRENT_PWD/$slug_name

    sed "s,\${bff_url},$BFF_URL," -i src/app/beagle.module.ts
    sed "s,\${project_name},$PROJECT_NAME," -i package.json
  fi

  if [[ $DOCKER_EXECUTION ]]; then
    chown 1000:1000 -R $CURRENT_PWD/$slug_name
  fi
}
