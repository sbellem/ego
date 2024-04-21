ARG ego_version=1.5.0
FROM ghcr.io/edgelesssys/ego-dev:v${ego_version} AS build
#FROM golang AS build

ARG ego_version

#COPY --from=ghcr.io/edgelesssys/ego-dev:v1.5.0 /opt/edgelessrt/include/openenclave /usr/local/include/openenclave
WORKDIR /usr/src/ra_client

COPY ra_client .

RUN go build client.go
#RUN CGO_CFLAGS=-I/opt/ego/include CGO_LDFLAGS=-L/opt/ego/lib ego-go build client.go


FROM ghcr.io/edgelesssys/ego-deploy:v${ego_version} AS deploy

WORKDIR /opt/ego-ra-client

COPY --from=build /usr/src/ra_client/client /usr/local/bin/ego-ra-client
COPY public.pem .

ENTRYPOINT ["ego-ra-client"]
