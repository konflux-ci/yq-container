FROM registry.access.redhat.com/ubi9/ubi:latest@sha256:ee0b908e958a1822afc57e5d386d1ea128eebe492cb2e01b6903ee19c133ea75 as builder
RUN dnf -y install golang

WORKDIR /go/src/mikefarah/yq

COPY yq/ .

RUN CGO_ENABLED=0 go build -ldflags "-s -w" .

# RUN ./scripts/test.sh -- this too often times out in the github pipeline.
RUN ./scripts/acceptance.sh

# Rebase on ubi9
FROM registry.access.redhat.com/ubi9:latest@sha256:2bae9062eddbbc18e76555972e7026ffe02cef560a0076e6d7f72bed2c05723f
RUN dnf -y install gettext

COPY --from=builder /go/src/mikefarah/yq/yq /usr/bin/yq

WORKDIR /workdir

RUN \
  groupadd -g 1000 yq; \
  useradd -u 1000 -g yq -s /bin/sh -d /home/yq yq

RUN chown -R yq:yq /workdir

USER yq

ENTRYPOINT ["/usr/bin/yq"]
