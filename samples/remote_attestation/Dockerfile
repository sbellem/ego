ARG egover=1.5.0

FROM ghcr.io/edgelesssys/ego/build-base:v${egover} AS build

ARG egover

RUN apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        libssl-dev \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Download and install further requirements (if any)
#
# Make sure that these stay the same, e.g., don't use "latest", but fixed versions.
#
# Avoid installing packages via apt here. This may change the version of already
# installed dependencies and may influence the final binary. If not using apt isn't
# feasible, consider building a Docker image that gathers all required apt packages
# and serves as a stable base.

# Download and install EGo
# Use --force-depends to ignore SGX dependencies, which aren't required for building
RUN egodeb=ego_${egover}_amd64_ubuntu-$(grep -oP 'VERSION_ID="\K[^"]+' /etc/os-release).deb \
  && wget https://github.com/edgelesssys/ego/releases/download/v${egover}/${egodeb} \
  && dpkg -i --force-depends ${egodeb}


WORKDIR /usr/src/ra

COPY . .

RUN ego-go build -trimpath
RUN --mount=type=secret,id=signingkey,dst=private.pem,required=true ego sign server

RUN CGO_CFLAGS=-I/opt/ego/include CGO_LDFLAGS=-L/opt/ego/lib ego-go build ra_client/client.go

# Use the deploy target if you want to deploy your app as a Docker image
FROM ghcr.io/edgelesssys/ego-deploy:v${egover} AS deploy
WORKDIR /opt/ego-ra
COPY --from=build /usr/src/ra/server .
COPY --from=build /usr/src/ra/client .
ENTRYPOINT ["ego", "run", "server"]
