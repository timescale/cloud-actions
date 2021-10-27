#!/bin/bash

for tag in ${tags}; do
    # If there is a target we use it
    echo "Building ${tag}"
    [[ ${target} = '' ]] && docker build -t ${tag} -f ${dockerfile} . || docker build -t ${tag} --target ${target} -f ${dockerfile} .
    echo "Pushing ${tag}"
    docker push ${tag}
done
