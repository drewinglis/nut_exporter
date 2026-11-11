### STAGE 1: Build ###

FROM --platform=$BUILDPLATFORM golang:1-alpine AS builder
ARG TARGETOS TARGETARCH TARGETVARIANT

WORKDIR /app
COPY . /app
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GOARM=${TARGETVARIANT#v} \
  go build -trimpath -o /go/bin/nut_exporter .

### STAGE 2: Setup ###

FROM alpine
RUN apk add --no-cache \
  libc6-compat
COPY --from=builder /go/bin/nut_exporter /nut_exporter
RUN chmod +x /nut_exporter
ENTRYPOINT ["/nut_exporter"]
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:9199/metrics || exit 1
