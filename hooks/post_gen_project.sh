#!/usr/bin/env bash
set -e
poetry lock --no-update
poetry install --with dev --sync
git init --initial-branch=develop
poetry run pre-commit install
