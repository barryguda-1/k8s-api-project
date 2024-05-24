#!/bin/bash
set -euo pipefail
echo "docker installation started........."
curl -SL https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
echo "docker installation done"
sudo chmod +x /usr/local/bin/docker-compose
docker ps
echo "docker installation done........."
DOCKER_BUILD_ARGS="-t k8s-service:v1" 
echo $DOCKER_BUILD_ARGS
docker build $DOCKER_BUILD_ARGS . 
echo "docker build done........."

docker login -u iamapikey --password-stdin "icr.io" <<< "$(get_env icr_push_apikey)"
docker tag k8s-service:v1 icr.io/bg-devops-test/k8s-service:v1
docker images
docker push icr.io/bg-devops-test/k8s-service:v1
digest=$(docker inspect --format='{{index .RepoDigests 0}}' icr.io/namespace/k8s-service:v1 | cut -d@ -f2)
echo "saving artifact"
save_artifact ui_service "name=icr.io/k8s-service:v1"
save_artifact ui_service "type=image"
save_artifact ui_service "digest=${digest}"
save_artifact ui_service "image_type=nonprod"
save_artifact ui_service "twistlock_group=$(get_env twistlock-group-id)"
