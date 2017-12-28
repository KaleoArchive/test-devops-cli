#!/bin/bash
set -eu -o pipefail

# Variables
site_repo="git@github.com:kaleocheng/test-devops-site.git"
site_theme_repo="git@github.com:kaleocheng/test-devops-neo.git"
site_path="../test-devops-site"
site_config="$site_path/config.toml"
current_path=$(pwd)
baseurl="http://kaleo.run"
dev_baseurl="http://dev.kaleo.run"
staging_baseurl="http://staging.kaleo.run"

init(){
    # Get site code
    git clone $site_repo $site_path
    git clone $site_theme_repo $site_path/themes/neo
    # build test-devops-cli
    make
}

# build accepts a branch name such as 'dev-gh-pages' or
# 'staging-gh-pages', it will be mounted to the 'public' by
# 'git worktree', and then build the site.
build(){
    echo "Compile the site to $1"
    cd $site_path
    ## 'rm -rf public' it is too dangerous, so we must check out the
    # $site_path carefully.

    # ensure $site_path has been set
    if [[ -z ${site_path+x} ]]
    then
        echo "site_pathh has not been set"
        exit 0
    fi

    # ensure $site_path is not empty
    if [[ -z "$site_path" ]]
    then
        echo "site_path is empty"
        exit 0
    fi

    rm -rf public
    git worktree prune
    git worktree add -B $1 public origin/$1
    hugo --theme=neo
    cd $current_path
}

# create_post where create a post with $1 as title and then
# use the output of fortune command as the content.
create_post(){
    echo "Create a post: $1"
    cd $site_path
    hugo  new $1 && \
    fortune >> content/$1 && \
    hugo undraft content/$1
    cd $current_path
}

dev(){
    post_title=$(./test-devops-cli title)
    post_path="post/$post_title.md"
    create_post $post_path

    version=$(./test-devops-cli --config=$site_config update dev)
    ./test-devops-cli --config=$site_config baseurl $dev_baseurl
    build dev-gh-pages
    ./test-devops-cli --config=$site_config baseurl $baseurl

    echo "Commmit and Push"
    cd $site_path
    git add .
    git commit -m "Add new post: $post_title, version: $version"
    git push origin master

    cd public/
    git add .
    git commit -m "Add new post: $post_title, version: $version"
    git push origin dev-gh-pages
    cd $current_path
}

staging(){

    version=$(./test-devops-cli --config=$site_config update staging)
    ./test-devops-cli --config=$site_config baseurl $staging_baseurl
    build staging-gh-pages
    ./test-devops-cli --config=$site_config baseurl $baseurl

    echo "Commmit and Push"
    cd $site_path
    git add .
    git commit -m "Publish: $version"
    git tag $version
    git push --tags origin master

    cd public/
    git add .
    git commit -m "Publish : $version"
    git push origin staging-gh-pages
    cd $current_path


    ## After build staging, dev should also be updated.

    ./test-devops-cli --config=$site_config baseurl $dev_baseurl
    build dev-gh-pages
    ./test-devops-cli --config=$site_config baseurl $baseurl
    cd $site_path/public
    git add .
    git commit -m "Publish : $version"
    git push origin dev-gh-pages

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
