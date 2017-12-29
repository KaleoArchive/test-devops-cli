# test-devops-cli
The script to create a post and publish the site for test-devops.

- `cli.sh`: (Shell) The main script，take one parameter which either `dev` or `staging`.
- `test-devops-cli`: (Golang) Called by `cli.sh`, increment the version, generate a random word as post title and so on.

## Requirements
- Go
- Git >= 12.13 (We want to use 'git worktree', and there is a bug in git 2.7.4 [https://discourse.gohugo.io/t/github-deployment-using-worktrees-failing/5918/5](https://discourse.gohugo.io/t/github-deployment-using-worktrees-failing/5918/5))
- [Hugo](https://gohugo.io/)
- Make
- fortune
- Ensure /usr/share/dict/words is exist(On ubuntu, it's wamerican package)

Or just **vagrant**, All deps have been in Vagrantfile.


# Usage


```shell
$ git clone https://github.com/kaleocheng/test-devops-cli.git
$ cd test-devops-cli/box

# Start with vagrant
$ ./start-box.sh
$ vagrant ssh 
```

Init with `cli.sh`:
> You need to have the permission (ssh key) to pull & push `test-devops-site` and `test-devops-neo`:
```shell
$ cd $GOPATH/src/github.com/kaleocheng/test-devops-cli
$ ./cli.sh init
```

Create a post, increment version by 0.0.1 and then commit & push:
```shell
$ ./cli.sh dev
```

Increment version by 0.1.0 and then commit & push:
```shell
$ ./cli.sh staging
```

> Also You need to have the permission to push.

By default:
```shell
git.username="Kaleo Cheng"
git.email="kaleocheng@gmail.com"
```
you could set to yours:
```shell
$ git config --global user.name "Your name"
$ git config --global user.email "your@email"
```

For more details, use `help`:

```shell
$ ./cli.sh help
CLI for test-devops
Usage:
cli.sh init | dev | staging
      'init' get the source code of 'test-devops-site' and 'test-devops-neo'
      'dev' create a new post, increment version by 0.0.1, compile and push site
      'staging' increment version by 0.1.0, complile and push site

$ ./test-devops-cli help
A command-line tool for test-devops

Usage:
  test-devops-cli [command]

Available Commands:
  baseurl     Change baseurl
  help        Help about any command
  title       Print a random word as the post title
  update      Increment the version which in the site config file

Flags:
      --config string   config file (default is ./config.toml)
  -h, --help            help for test-devops-cli

Use "test-devops-cli [command] --help" for more information about a command.
```


# FAQ

## Why both shell and go
This test involves some different technologies, such as git and Hugo. I think it could be more concise and easy to understand by called them directly in shell. So the main script `cli.sh` was written in shell.

However, on the other hand, shell is not good at parsing configuration files and increment version by either 0.1.0 or 0.1.0, It seems like magic. So there is an other command-line `test-devops-cli` written in Go.

## How it works?
`dev`:
1. use `test-devops-cli title` get a random word as the post title
2. use `hugo new` to create a post and use `fortune` as the content
3. use `test-devops-cli update dev` to increment version by 0.0.1
4. use `test-devops-cli baseurl $dev_baseurl` to update baseurl
5. use `git worktree` to create public dir and checkout `dev-gh-pages` into it
6. use `hugo` to build site
6. reset baseurl
7. commit and push both `master` and `dev-gh-pages`

`staging`:
1. use `test-devops-cli update staging` to increment version by 0.1.0
2. use `test-devops-cli baseurl $staging_baseurl` to update baseurl
3. use `git worktree` to create public dir and checkout `staging-gh-pages` into it
4. use `hugo` to build site
5. reset baseurl
6. commit and push both `master` and `staging-gh-pages`
7. rebuild `dev-gh-pages` and commit & push
