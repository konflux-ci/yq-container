FROM registry.access.redhat.com/ubi9/ubi:latest@sha256:d342aa80781bf41c4c73485c41d8f1e2dbc40ee491633d9cafe787c361dd44ff as builder
RUN dnf -y install golang

WORKDIR /go/src/mikefarah/yq

COPY yq/ .

RUN CGO_ENABLED=0 go build -ldflags "-s -w" .

# RUN ./scripts/test.sh -- this too often times out in the github pipeline.
RUN ./scripts/acceptance.sh

# Rebase on ubi9
FROM registry.access.redhat.com/ubi9/ubi:latest@sha256:d342aa80781bf41c4c73485c41d8f1e2dbc40ee491633d9cafe787c361dd44ff
RUN dnf -y install gettext

COPY --from=builder /go/src/mikefarah/yq/yq /usr/bin/yq

WORKDIR /workdir

RUN \
  groupadd -g 1000 yq; \
  useradd -u 1000 -g yq -s /bin/sh -d /home/yq yq

RUN chown -R yq:yq /workdir

USER yq

LABEL name=yq \
      com.redhat.component=yq \
      summary="A rebuild of mikefarah/yq available at quay.io/konflux-ci/yq:latest" \
      description="A rebuild of mikefarah/yq available at quay.io/konflux-ci/yq:latest" \
      io.k8s.description="A rebuild of mikefarah/yq available at quay.io/konflux-ci/yq:latest" \
      io.k8s.display-name=yq \
      io.openshift.tags=yq

ENTRYPOINT ["/usr/bin/yq"]
