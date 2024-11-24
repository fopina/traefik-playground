FROM golang:1.23.3-alpine AS builder

WORKDIR /app
COPY main.go .
COPY go.mod .
RUN go build .

FROM scratch

COPY --from=builder /app/cn_validator /

ENTRYPOINT [ "/cn_validator" ]
