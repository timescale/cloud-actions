#!/bin/bash

for tag in ${tags}; do
    # Search-and-replace all / characters to -, which allows using github.ref_name in the tag since most branches include a / character.
    tag="${tag//\//-}"

    # If there is a target we use it
    echo "Building ${registry}:${tag}"
    cd "${context}" || exit 1
    if [[ ${target} = '' ]]; then
        docker build --secret id=gh_token,env=gh_token -t ${registry}:${tag} -f ${dockerfile} .
    else
        docker build --secret id=gh_token,env=gh_token -t ${registry}:${tag} --target ${target} -f ${dockerfile} .
    fi
    echo "Pushing ${registry}:${tag}"
    docker push ${registry}:${tag}
done
