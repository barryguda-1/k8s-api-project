#!/bin/bash
set -euo pipefail

DOCKER_COMPOSE_VERSION="v2.23.0"
DOCKER_COMPOSE_BIN="/usr/local/bin/docker-compose"
DOCKER_IMAGE_NAME="k8s-service:v1"
DOCKER_REGISTRY="icr.io"
DOCKER_NAMESPACE="bg-devops-test"
DOCKER_REPOSITORY="${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${DOCKER_IMAGE_NAME}"

echo "docker installation started........."
curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" -o ${DOCKER_COMPOSE_BIN}
echo "docker installation done"

sudo chmod +x ${DOCKER_COMPOSE_BIN}
docker ps
echo "docker installation done........."

DOCKER_BUILD_ARGS="-t ${DOCKER_IMAGE_NAME}"
echo ${DOCKER_BUILD_ARGS}
docker build ${DOCKER_BUILD_ARGS} .

echo "docker build done........."

DOCKER_LOGIN_COMMAND="docker login -u iamapikey --password-stdin ${DOCKER_REGISTRY}"
DOCKER_TAG_COMMAND="docker tag ${DOCKER_IMAGE_NAME} ${DOCKER_REPOSITORY}"
DOCKER_PUSH_COMMAND="docker push ${DOCKER_REPOSITORY}"

${DOCKER_LOGIN_COMMAND} <<< "$(get_env ibmcloud-api-key)"
${DOCKER_TAG_COMMAND}
docker images
${DOCKER_PUSH_COMMAND}

digest=$(docker inspect --format='{{index .RepoDigests 0}}' ${DOCKER_REPOSITORY} | cut -d@ -f2)
echo "saving artifact"

save_artifact ui_service "name=${DOCKER_REPOSITORY}"
save_artifact ui_service "type=image"
save_artifact ui_service "digest=${digest}"
save_artifact ui_service "image_type=nonprod"
save_artifact ui_service "twistlock_group=$(get_env twistlock-group-id)"