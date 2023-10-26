# syntax=docker/dockerfile:1

# Base stage
ARG PYTHON_VERSION={{cookiecutter.python_version}}
FROM python:${PYTHON_VERSION}-slim as base

ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

#-----------------------------------------------------------------------------
# Compiler stage
FROM base AS builder

USER root

ARG PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    POETRY_VERSION=1.5.1 \
    POETRY_HOME=/opt/poetry \
    POETRY_CACHE_DIR=/opt/.cache \
    POETRY_INSTALLER_MODERN_INSTALLATION=true

RUN pip install setuptools poetry==${POETRY_VERSION}

# Install base libraries, repository host keys
RUN <<EOF
apt-get update -q
apt-get install -yq \
    cmake g++ \
    libbz2-dev \
    gfortran libblas-dev liblapack-dev \
    swig openssh-server git
apt update
{%- if cookiecutter.include_postgres %}
apt install -y libpq-dev
{%- endif %}
mkdir -p -m 0700 /root/.ssh
ssh-keyscan {{cookiecutter.git_host}}.com >> /root/.ssh/known_hosts
EOF

# Lock and install main dependencies if there are changes
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN --mount=type=ssh \
    --mount=type=cache,target=/root/.cache <<EOF
    poetry config virtualenvs.in-project true
    poetry lock --no-update
    poetry install --without dev --compile --sync --no-root
EOF

# Install self in virtualenv
# poetry install --only-root installs only mixilo_autoexploration; most other options end up removing the dependencies
COPY {{cookiecutter.project_src_dir}}/ ./{{cookiecutter.project_src_dir}}
COPY README.md ./
RUN --mount=type=ssh \
    --mount=type=cache,target=/root/.cache <<EOF
    poetry install --only-root
    poetry build --format wheel
    ./.venv/bin/pip3 install ./dist/{{cookiecutter.project_src_dir}}-*.whl
EOF

#-----------------------------------------------------------------------------
# Runner stage
FROM base AS final

ARG BUILD_DIRECTORY=/opt/ml/processing/input/mixilo-autoexploration
WORKDIR ${BUILD_DIRECTORY}

# Add dependencies required in runtime (e.g. gcc, latex, postgres)
{%- if (cookiecutter.containerize_latex, cookiecutter.containerize_gcc, cookiecutter.include_postgres)|select|first %}
RUN <<EOF
apt-get update -q
apt update -q
{%- if cookiecutter.containerize_latex or cookiecutter.containerize_gcc %}
apt-get install -yq \
    {%- if cookiecutter.containerize_latex %}
    texlive-xetex texlive-fonts-recommended \
    texlive-plain-generic pandoc \
    {%- endif %}
    {%- if cookiecutter.containerize_gcc %}
    g++ \
    {%- endif %}
    ;
{%- endif %}
{%- if cookiecutter.include_postgres %}
apt install -yq \
    libpq-dev \
{% endif %}
EOF
{%- endif %}

ENV TZ="America/Argentina/Buenos_Aires"
ENV DEBIAN_FRONTEND=noninteractive

# Copy built virtualenv from builder stage
COPY --from=builder /app/.venv ./.venv
ENV PATH ./.venv/bin:$PATH

# Copy code and notebooks from local directory
COPY {{cookiecutter.project_src_dir}}/ ./{{cookiecutter.project_src_dir}}

# Uncomment for copying notebooks
# COPY notebooks/ ./notebooks

# Copy entrypoints and add execution permissions
COPY entrypoints/entrypoint.*.sh ./
RUN chmod -R +x ./entrypoint.*.sh

# TODO: add user with access to volumes
# ARG UID=10001
# RUN adduser \
#     --disabled-password \
#     --gecos "" \
#     --home "/appuser" \
#     --shell "/sbin/nologin" \
#     --uid "${UID}" \
#     appuser
# USER appuser

# Overrideable endpoint
CMD [ "./entrypoint.{{cookiecutter.project_slug}}.sh" ]