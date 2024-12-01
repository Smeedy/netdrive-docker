# ---- BUILD
FROM busybox AS unpack

ARG NETDRIVE_SERVER_VERSION=2024-08-16

WORKDIR /unpack

# get the multiarch binary and unzip it
ADD https://www.brutman.com/mTCP/download/mTCP_NetDrive_${NETDRIVE_SERVER_VERSION}_Servers.zip /tmp
RUN unzip /tmp/mTCP_NetDrive_${NETDRIVE_SERVER_VERSION}_Servers.zip -d /tmp
RUN mv /tmp/mTCP_NetDrive_${NETDRIVE_SERVER_VERSION}_Servers/* .

# and create a generic entrypoint
RUN echo "$(uname -s)/$(uname -m)" > arch.txt \
 && case "$(uname -s)/$(uname -m)" in \
         "Linux/x86_64")  FOLDER=linux_x86   ;; \
         "Linux/aarch64")  FOLDER=linux_arm  ;; \
         # "Darmin/arm64") FOLDER=darwin_arm64 ;; \ <-- In docker on arm it will do Linux/aarch64 and will run just fine
    esac \
 && ln -s ${FOLDER}/netdrive

# ---- RUN
FROM alpine:3

# we need some libc for Go binaries to run
RUN apk add libc6-compat


WORKDIR /app
COPY --from=unpack /unpack/ /app
RUN mkdir /images

# create a logfile which point to stdout
RUN ln -sf /dev/stdout netdrive.log 

EXPOSE 2002/udp
ENV NETDRIVE_LOG_LEVEL=info

ENTRYPOINT ["/bin/sh", "-c", "/app/netdrive -log_file netdrive.log -log_level ${NETDRIVE_LOG_LEVEL} serve -headless -image_dir /images -port 2002"]
