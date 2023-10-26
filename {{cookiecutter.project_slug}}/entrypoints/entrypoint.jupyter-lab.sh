#!/usr/bin/env bash
set -e

. ./.venv/bin/activate
# TODO: virtualenv isn't being activated, so the specific interpreter is needed
./.venv/bin/python ./.venv/bin/jupyter-lab --allow-root --ip 0.0.0.0