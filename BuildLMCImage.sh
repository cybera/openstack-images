#! /bin/bash -x

DEFAULT_IMAGE_NAME=ubuntu-trusty-preheated-new
read -p "Image name ($DEFAULT_IMAGE_NAME): " IMAGE_NAME
IMAGE_NAME=${IMAGE_NAME:-$DEFAULT_IMAGE_NAME}

cd scripts

./UpdateUbuntu1404.sh $IMAGE_NAME
