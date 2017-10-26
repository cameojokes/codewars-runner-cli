# Building erlang images have been suspended (frozen) until they are able to be repaired
CONTAINERS=node dotnet jvm java python ruby alt rust julia systems dart crystal ocaml swift haskell objc go lua esolangs chapel nim r erlang

ALL_CONTAINERS=${CONTAINERS} base

.PHONY: ${ALL_CONTAINERS} clean docker_rm docker_rmi

all: ${CONTAINERS}

recent: ${RECENT_CONTAINERS}

base: guard-HOSTNAME guard-REPO guard-CODEUSER
	cp docker/$@.docker ./Dockerfile
	docker build -t $(REPO)/$@-runner --build-arg codeuser=$(CODEUSER) .
	docker tag $(REPO)/$@-runner:latest $(HOSTNAME)/$(REPO)/$@-runner:latest

${CONTAINERS}: guard-HOSTNAME guard-REPO guard-CODEUSER
	cp docker/$@.docker ./Dockerfile
	docker build -t $(REPO)/$@-runner --build-arg repo=$(REPO) --build-arg codeuser=$(CODEUSER) .
	docker tag $(REPO)/$@-runner:latest $(HOSTNAME)/$(REPO)/$@-runner:latest

# Kill all of the in-flight and exited docker containers
docker_rm:
	docker ps -q | xargs docker stop
	[ ! -n "$(shell docker ps -a -q)" ] || echo $(shell docker ps -a -q) | xargs -n 1 docker rm -f

# Kill all docker images
docker_rmi: docker_rm
	docker rmi $(docker images -q -f dangling=true)

clean: docker_rmi

deep-clean: docker_rmi

push: guard-HOSTNAME guard-REPO
	docker push $(HOSTNAME)/$(REPO)/base-runner
	docker push $(HOSTNAME)/$(REPO)/node-runner
	docker push $(HOSTNAME)/$(REPO)/ruby-runner
	docker push $(HOSTNAME)/$(REPO)/python-runner
	docker push $(HOSTNAME)/$(REPO)/dotnet-runner
	docker push $(HOSTNAME)/$(REPO)/jvm-runner
	docker push $(HOSTNAME)/$(REPO)/java-runner
	docker push $(HOSTNAME)/$(REPO)/haskell-runner
	docker push $(HOSTNAME)/$(REPO)/systems-runner
	docker push $(HOSTNAME)/$(REPO)/erlang-runner
	docker push $(HOSTNAME)/$(REPO)/alt-runner
	docker push $(HOSTNAME)/$(REPO)/rust-runner
	docker push $(HOSTNAME)/$(REPO)/crystal-runner
	docker push $(HOSTNAME)/$(REPO)/dart-runner
	docker push $(HOSTNAME)/$(REPO)/ocaml-runner
	docker push $(HOSTNAME)/$(REPO)/objc-runner
	docker push $(HOSTNAME)/$(REPO)/swift-runner || true

pull: guard-HOSTNAME guard-REPO
	docker pull $(HOSTNAME)/$(REPO)/base-runner
	docker pull $(HOSTNAME)/$(REPO)/node-runner
	docker pull $(HOSTNAME)/$(REPO)/ruby-runner
	docker pull $(HOSTNAME)/$(REPO)/python-runner
	docker pull $(HOSTNAME)/$(REPO)/dotnet-runner
	docker pull $(HOSTNAME)/$(REPO)/jvm-runner
	docker pull $(HOSTNAME)/$(REPO)/java-runner
	docker pull $(HOSTNAME)/$(REPO)/haskell-runner
	docker pull $(HOSTNAME)/$(REPO)/systems-runner
	docker pull $(HOSTNAME)/$(REPO)/erlang-runner
	docker pull $(HOSTNAME)/$(REPO)/alt-runner
	docker pull $(HOSTNAME)/$(REPO)/rust-runner
	docker pull $(HOSTNAME)/$(REPO)/crystal-runner
	docker pull $(HOSTNAME)/$(REPO)/dart-runner
	docker pull $(HOSTNAME)/$(REPO)/ocaml-runner
	docker pull $(HOSTNAME)/$(REPO)/objc-runner
	docker pull $(HOSTNAME)/$(REPO)/swift-runner || true

guard-%:
	@ if [ "${${*}}" = "" ]; then \
	echo "Environment variable $* not set"; \
	exit 1; \
	fi
