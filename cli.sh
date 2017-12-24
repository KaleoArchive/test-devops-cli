#!/bin/bash
set -eu -o pipefail

# Variables
site_repo="git@github.com:kaleocheng/test-devops-site.git"
site_theme_repo="git@github.com:kaleocheng/test-devops-neo.git"
site_path="../test-devops-site"
site_config="$site_path/config.toml"
current_path=$(pwd)

init(){
    git clone $site_repo $site_path
    git clone $site_theme_repo $site_path/themes/neo
}

build_site(){
    # Compile the site
    echo "Compile the site"
    cd $site_path
    hugo --theme=neo
    cd $current_path
}
dev(){
    # Create a new post
    echo "Create a new post"
    post_title=$(./test-devops-cli title)
    post_path="post/$post_title.md"
    cd $site_path
    hugo  new $post_path && \
    fortune >> content/$post_path && \
    hugo undraft content/$post_path
    cd $current_path

    # Increment the version
    echo "Increment the version"
    version=$(./test-devops-cli --config=$site_config update dev)

    build_site

    # Commit and Push
    echo "Commmit and Push"
    cd $site_path
    git add .
    git commit -m "Add new post: $post_title, version: $version"
    git push origin master
    cd $current_path
}

staging(){
    # Increment the version
    echo "Increment the version"
    version=$(./test-devops-cli --config=$site_config update staging)

    build_site

    # Commit and Push
    echo "Commmit and Push"
    cd $site_path
    git add .
    git commit -m "Update version: $version"
    git tag $version
    git push --tags origin master
    cd $current_path
}

# Print usage info
usage(){
    echo "CLI for test-devops"
    echo "Usage: "
    echo "cli.sh init | dev | staging"
    echo "      'init' get the source code of 'test-devops-site' and 'test-devops-neo'"
    echo "      'dev' create a new post, increment version by 0.0.1, compile and push site"
    echo "      'staging' increment version by 0.1.0, complile and push site"
}


# Main
## Check params num
if [ $# -ne 1 ]
then
    usage
    exit 0
fi

case $1 in
	"init") init ;;
	"dev") dev ;;
	"staging") staging ;;
	*) echo "invalid params"
       echo
       usage ;;
esac
