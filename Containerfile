FROM registry.access.redhat.com/ubi9/ubi:latest@sha256:4495380286c97b9c2635b0b5d6f227bbd9003628be8383a37ff99984eefa42ed as builder
RUN dnf -y install golang

WORKDIR /go/src/mikefarah/yq

COPY yq/ .

RUN CGO_ENABLED=0 go build -ldflags "-s -w" .

# RUN ./scripts/test.sh -- this too often times out in the github pipeline.
RUN ./scripts/acceptance.sh

# Rebase on ubi9
FROM registry.access.redhat.com/ubi9/ubi:latest@sha256:4495380286c97b9c2635b0b5d6f227bbd9003628be8383a37ff99984eefa42ed
RUN dnf -y install gettext

COPY --from=builder /go/src/mikefarah/yq/yq /usr/bin/yq

WORKDIR /workdir

RUN \
  groupadd -g 1000 yq; \
  useradd -u 1000 -g yq -s /bin/sh -d /home/yq yq

RUN chown -R yq:yq /workdir

USER yq

ENTRYPOINT ["/usr/bin/yq"]
