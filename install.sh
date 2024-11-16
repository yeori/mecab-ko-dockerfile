#!/bin/bash

readonly HOST=https://bitbucket.org/eunjeon
readonly mecab_img_name=mecab-img
readonly mecab_con_name=mecab-con
readonly working_dir=$(pwd)
readonly volume_dir=$working_dir/mecab
readonly volume_app=$volume_dir/app
readonly volume_dic=$volume_dir/dictionary
set -e

ok() {
    local msg=$1
    echo -e "[\e[32mOK  \e[0m] $msg"
}
step() {
    echo -e "\n[\e[35mSTEP\e[0m] $1"
}
check_success() {
    local msg=$1
    local exit_code=$2
    if [ $? -ne 0 ]; then
        echo "[Error] $msg"
        return $exit_code
    fi
}
scaffold() {
    mkdir -p $volume_dir/jar
}
download_jar() {
    step "Downloading ..."
    wget -qnc --show-progress -P $volume_dir/jar $HOST/$1
    check_success "Failed to download $1. Exiting." 1
    ok "Downloaded $1"
}
check_docker() {
    if [ -x "$(command -v docker)" ]; then
        echo "Docker: $(docker --version)"
    else
        echo "Install docker"
        exit 1
    fi
}
build_mecab_img() {
    step "Building mecab image"
    docker build -t $mecab_img_name -f Dockerfile .
    check_success "Failed to build mecb_image. Exiting." 1
    ok "mecab image $mecab_img_name"
}

remove_container() {
    local container_id=$(docker ps -a -q -f name="^${mecab_con_name}$")
    if [[ -n "$container_id" ]]; then
        if [[ -d $volume_app ]]; then
            rm -rf $volume_app
        fi
        if [[ -d $volume_dic ]]; then
            rm -rf $volume_dic
        fi
        echo "Container '$CONTAINER_NAME' found. Removing it..."
        docker rm -f "$container_id"
        echo "Container '$CONTAINER_NAME' has been removed."
    fi
}

build_mecab() {
    remove_container
    step "Building mecab container";
    docker run -itd --rm \
        --name $mecab_con_name \
        $mecab_img_name bash
    check_success "Failed to run mecb container. Exiting." 1

    echo "Fetching mecab app";
    docker cp $mecab_con_name:/app $volume_dir
    check_success "fail to copy $mecab_con_name:/app" 1
    
    echo "Fetching mecab dictionary";
    docker cp $mecab_con_name:/usr/local/lib/mecab/dic/mecab-ko-dic/ $volume_dic
    check_success "fail to copy $mecab_con_name:/usr/local/lib/mecab/dic/mecab-ko-dic" 1
    docker stop $mecab_con_name
    ok "container removed succesfully";
}

run_mecab() {
    step "Running mecab container \e[32m${mecab_con_name}\e[0m";
    docker run -itd \
        --mount type=bind,source=$volume_app,target=/app \
        --mount type=bind,source=$volume_dic,target=/usr/local/lib/mecab/dic/mecab-ko-dic \
        --name $mecab_con_name \
        $mecab_img_name bash
    ok "container started \e[32m${mecab_con_name}\e[0m";
}
scaffold
download_jar "/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz"
download_jar "/mecab-ko-dic/downloads/mecab-ko-dic-2.1.1-20180720.tar.gz"
check_docker
build_mecab_img
build_mecab
run_mecab

