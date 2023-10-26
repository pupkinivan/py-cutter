include .env

.PHONY: run_{{ cookiecutter.project_src_dir }}
run_search:
	@docker-compose up -d
	@docker run --rm --name {{ cookiecutter.project_slug }} \
		--network={{ cookiecutter.project_slug }}_network \
		--env-file .env \
		{{ cookiecutter.project_slug }}:latest
# Example volumes:
# -v $(shell pwd)/config:/opt/ml/processing/input/{{ cookiecutter.project_slug }}/config \
# -v $(shell pwd)/resources:/opt/ml/processing/input/{{ cookiecutter.project_slug }}/resources \
# -v $(shell pwd)/outputs:/opt/ml/processing/input/{{ cookiecutter.project_slug }}/outputs \
# -v $(shell pwd)/data:/opt/ml/processing/input/{{ cookiecutter.project_slug }}/data \
# -v $(shell pwd)/notebooks:/opt/ml/processing/input/{{ cookiecutter.project_slug }}/notebooks \

.PHONY: jupyter_lab
jupyter_lab:
	@docker-compose up -d
	@docker run --rm --name {{ cookiecutter.project_slug }} \
		--network={{ cookiecutter.project_slug }}_network \
		--env-file .env \
		-p 8888:8888 \
		{{ cookiecutter.project_slug }} \
		"./entrypoint.jupyter-lab.sh"
# No docker stop here because Jupyter Lab is interactive.
# In order to tear it down, run manually `make down`.
# Example volumes:
# -v $(shell pwd)/config:/opt/ml/processing/input/{{ cookiecutter.project_slug }}/config \
# -v $(shell pwd)/resources:/opt/ml/processing/input/{{ cookiecutter.project_slug }}/resources \
# -v $(shell pwd)/outputs:/opt/ml/processing/input/{{ cookiecutter.project_slug }}/outputs \
# -v $(shell pwd)/data:/opt/ml/processing/input/{{ cookiecutter.project_slug }}/data \
# -v $(shell pwd)/notebooks:/opt/ml/processing/input/{{ cookiecutter.project_slug }}/notebooks \

.PHONY: build
build:
	echo "Building container " ;\
	ssh-add ${SSH_PRIVATE_KEY_PATH} ;\
	docker buildx build \
		-t {{ cookiecutter.project_slug }}:{{ cookiecutter.project_version }} \
		-t {{ cookiecutter.project_slug }}:latest \
		--ssh default \
		. ;

.PHONY: down
down:
	-docker kill {{ cookiecutter.project_slug }};
	-docker rm {{ cookiecutter.project_slug }};
	docker-compose down --remove-orphans;