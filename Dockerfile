ARG ALPINE_VER=3.16

FROM alpine:${ALPINE_VER} AS build

# Install prerequisities
RUN apk update && apk add boost && apk add --no-cache --virtual build-dependencies openssh git unzip cmake build-base ninja pkgconfig linux-headers curl zip
RUN git clone https://github.com/Microsoft/vcpkg.git /tmp/vcpkg \
  && cd /tmp/vcpkg \
  && ./bootstrap-vcpkg.sh

# Build
COPY . /tmp/bt-migrate
RUN mkdir /tmp/bt-migrate/_build \
  && cd /tmp/bt-migrate/_build \
  && VCPKG_FORCE_SYSTEM_BINARIES=1 cmake .. -DCMAKE_TOOLCHAIN_FILE=/tmp/vcpkg/scripts/buildsystems/vcpkg.cmake \
  && cmake --build .

FROM alpine:${ALPINE_VER} AS runtime

RUN apk update && apk add --no-cache libstdc++
COPY --from=build /tmp/bt-migrate/_build/BtMigrate /usr/local/bin/

ENTRYPOINT [ "BtMigrate" ]