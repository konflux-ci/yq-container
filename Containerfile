FROM registry.access.redhat.com/ubi9/ubi:latest@sha256:f4ebd46d3ba96feb016d798009e1cc2404c3a4ebdac8b2479a2ac053e59f41b4 as builder
RUN dnf -y install golang

WORKDIR /go/src/mikefarah/yq

COPY yq/ .

RUN CGO_ENABLED=0 go build -ldflags "-s -w" .

# RUN ./scripts/test.sh -- this too often times out in the github pipeline.
RUN ./scripts/acceptance.sh

# Rebase on ubi9
FROM registry.access.redhat.com/ubi9/ubi:latest@sha256:f4ebd46d3ba96feb016d798009e1cc2404c3a4ebdac8b2479a2ac053e59f41b4
RUN dnf -y install gettext

COPY --from=builder /go/src/mikefarah/yq/yq /usr/bin/yq

RUN mkdir /licenses/
COPY yq/LICENSE /licenses/LICENSE

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
      io.openshift.tags=yq \
      license=MIT

ENTRYPOINT ["/usr/bin/yq"]
