#!/bin/bash

echo "Loading kubeconfig for env ${INPUT_ENV} ${INPUT_REGION}"
if ! [[ "${INPUT_ENV}" =~ dev|stage|prod ]]; then
  echo "::error title=Non-standard ENV::Non-standard value for ENV, canonical envs are dev, stage, prod."
  exit 1
fi

# For historical reasons, us-east-1 kubeconfig is not keyed with its region.
region_upper="${INPUT_REGION^^}"
REGION="${region_upper//-/_}"
ENV="${INPUT_ENV^^}"
ORG_KUBECONFIG="ORG_KUBECONFIG_${ENV}_${REGION}"
if [ "${INPUT_REGION}" = 'us-east-1' ]; then
  ORG_KUBECONFIG="ORG_KUBECONFIG_${ENV}"
fi

# Ensure the needed kubeconfig var has been configured, else emit an error.
if [ -z "${!ORG_KUBECONFIG}" ]; then
  echo "::error title=Kubeconfig Not Found::Kubeconfig var '${ORG_KUBECONFIG}' is unset or has an empty value, this is typically configured as an organization secret."
  exit 1
fi

# Keep the ./kubeconfig file generation for legacy reasons
base64 --decode <<<"${!ORG_KUBECONFIG}" >./kubeconfig_${INPUT_ENV}_${INPUT_REGION} && cp ./kubeconfig_${INPUT_ENV}_${INPUT_REGION} ./kubeconfig
