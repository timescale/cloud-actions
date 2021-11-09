#!/bin/bash

for tag in ${tags}; do
    # If there is a target we use it
    echo "Building ${registry}:${tag}"
    [[ ${target} = '' ]] && docker build -t ${registry}:${tag} -f ${dockerfile} . || docker build -t ${registry}:${tag} --target ${target} -f ${dockerfile} .
    echo "Pushing ${registry}:${tag}"
    docker push ${registry}:${tag}
done
