FROM golang:1.17 AS builder

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN GOOS=linux CGO_ENABLED=0 go build -v -o demo-ha-gcp main.go

FROM alpine:latest
COPY --from=builder /user/src/app/demo-ha-gcp .
ENTRYPOINT ["./demo-ha-gcp"]

EXPOSE 9000