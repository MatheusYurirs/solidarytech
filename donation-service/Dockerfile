FROM golang:1.26-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o main .

FROM alpine:3.22
RUN adduser -D -u 10001 appuser
WORKDIR /app
COPY --from=builder /app/main .
USER appuser
EXPOSE 8082
CMD ["./main"]
