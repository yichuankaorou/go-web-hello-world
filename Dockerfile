FROM golang:alpine as build
WORKDIR /root/go/src/demo/go-web-hello-world
ADD . .
RUN CGO_ENABLED=1 GOOS=linux go build -o run 

FROM alpine:3.6
COPY --from=build /root/go/src/demo/go-web-hello-world/run .
CMD ["./run"]
