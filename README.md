# puppet_githook

This pre-commit script will check for syntax error and will avoid commit is find any problem.

## Install:

You need to create a symbolic link to pre-commit.bash.
ex.: ln -s <local path to this directory>/pre-commit.bash <path to local git workcopy>/.git/hooks/pre-commit


## NOTE:
you can use -n to skip the pre-commit hook if you need.
git commit --no-verify
