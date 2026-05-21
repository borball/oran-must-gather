IMAGE_REGISTRY ?= quay.io
IMAGE_REPO ?= $(IMAGE_REGISTRY)/$(USER)/oran-must-gather
IMAGE_TAG ?= latest
IMAGE ?= $(IMAGE_REPO):$(IMAGE_TAG)

.PHONY: build push clean

build:
	podman build --no-cache -f Containerfile -t $(IMAGE) .

push: build
	podman push $(IMAGE)

clean:
	podman rmi $(IMAGE) 2>/dev/null || true
