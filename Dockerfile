FROM golang:1.15-alpine as builder
ARG http_proxy
ARG https_proxy
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG no_proxy

LABEL builder=test-election

RUN apk update && apk add --no-cache protobuf bash git build-base make gcc ca-certificates tzdata docker wget && update-ca-certificates

RUN adduser -D -g '' appuser

WORKDIR /app/

# Download dependencies
COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

# Copy the source code
COPY *.go .

# Build proto e source code
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o /app/bin/server main.go

FROM alpine
RUN apk add curl
WORKDIR /app
EXPOSE 8080 2112

# Import from builder.
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /app/bin/server /app/server

# Use an unprivileged user.
USER appuser

ENTRYPOINT ["/app/server"]