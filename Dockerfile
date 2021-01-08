#
# alpine-abuild Dockerfile
#
# https://github.com/jlesage/docker-alpine-abuild
#

ARG ALPINE_VERSION=unknown

# Pull base image.
FROM alpine:${ALPINE_VERSION}

ARG ALPINE_VERSION=unknown

# Define working directory.
WORKDIR /tmp

RUN \
    if test "${ALPINE_VERSION}" = "edge"; then \
        echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories; \
    fi

# Install required packages to build packages.
RUN apk --no-cache add \
     alpine-sdk \
     coreutils \
     cmake \
     su-exec

# Clear Linux groups.
RUN echo 'root:x:0:root' > /etc/group

# Clear Linux users.
RUN echo 'root:x:0:0:root:/root:/bin/ash' > /etc/passwd

# Add the 'builder' user to sudoers.
RUN echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install build script.
COPY start-build /bin/

# Set environment variables.
ENV USER_ID=1000 \
    GROUP_ID=1000 \
    PKG_SIGNING_KEY_NAME=ssh \
    PKG_SIGNING_PRIV_KEY= \
    PKG_SIGNING_PUB_KEY= \
    PKG_SRC_DIR=/pkg_src \
    PKG_DST_DIR=/pkg_dst

# Define mountable directories.
VOLUME ["/pkg_src"]
VOLUME ["/pkg_dst"]

# Define entrypoint.
ENTRYPOINT ["start-build", "-r"]
