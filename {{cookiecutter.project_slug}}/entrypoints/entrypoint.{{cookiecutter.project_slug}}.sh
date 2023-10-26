#!/usr/env/bin bash
set -e

. ./.venv/bin/activate
# TODO: virtualenv isn't being activated, so the specific interpreter is needed
./.venv/bin/python {{cookiecutter.project_src_dir}}/main.py