FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_9_1.22 as builder

WORKDIR /yq/go/src/mikefarah/yq

COPY . .

RUN CGO_ENABLED=0 go build -ldflags "-s -w" .
# RUN ./scripts/test.sh -- this too often times out in the github pipeline.
RUN ./scripts/acceptance.sh

# Rebase on ubi9
FROM registry.access.redhat.com/ubi9:latest@sha256:66233eebd72bb5baa25190d4f55e1dc3fff3a9b77186c1f91a0abdb274452072

COPY --from=builder /yq/go/src/mikefarah/yq/yq /usr/bin/yq

WORKDIR /yq/workdir

RUN set -eux; \
  addgroup -g 1000 yq; \
  adduser -u 1000 -G yq -s /bin/sh -h /home/yq -D yq

RUN chown -R yq:yq /workdir

USER yq

ENTRYPOINT ["/usr/bin/yq"]
