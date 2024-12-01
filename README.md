# mTCP NetDrive by Mike Brutman

This is a dockerized version of the mTCP NetDrive serverpart.

NetDrive enables a DOS machine to map a local drive to an UDP endpoint which can serve floppy and disk images. You can find more information about the amazing mTCP stack for DOS on his page https://www.brutman.com/mTCP. For NetDrive specific there is a [subpage](https://www.brutman.com/mTCP/mTCP_NetDrive.html), but have a look at the PDF manual as well on the main page as there's a useful section on NetDrive.

Please read the awesome manual from mTCP as it would also tell you how to setup the DOS side of this equation, as well as providing you a demo endpoint you can test first before you start your own NetDrive server.

Btw. Scout is flagging this image as the Go binary being pulled from the mTCP site is compiled with a particular version with stdlib. This needs to be fixed upstream but there's nothing I can do to fix this at my end - beside giving Mike a hint one of these days. But as the vector into this running Docker is the DOS client, I think this is not a biggy tbh.

My source on https://github.com/Smeedy/netdrive-docker

## Typical usage
You can have a local image folder containing floppy and disk image files. You usually can get images on archive sites or you create them yourself from scratch. There's information creating your blank images in the PDF on the mTCP website in the NetDrive section. If you have placed your images on your Docker host (or NAS or how you do your infra), you can start the NetDrive using something like:
```
docker run -it -v /your/local-path/to/dos-images:/images -p 2002:2002/udp smeed/netdrive
```

Or you will have it daemonized and have it running on your machine, cluster, whatever. If you made it this far, you probably know what you are doing.

It will use the internal '/images' folder within the running container pointing to your local source and map the 2002/UDP port to the outside of your host machine. Internally the NetDrive server will use 2002/UDP which you need to expose on your container host as well if you want this to be accessible from your DOS machine using your LAN. You can change the port on the host machine by changing the first number `-p nnnn:2002/UDP` - which even might enable you to run multiple NetDrives instances simultaneously if you have that urge. Anyways, moving on..

## Debugging

The default loglevel is `info`, but you can set the `NETDRIVE_LOG_LEVEL` to a value matching `debug|info|warn|error`. The default output without specifying this environmental variable is very modest is perfect for day to day operations. Setting it to `debug` might give you a hint when you are hunting down an error. It would yield to something like this:

```
docker run -it -v /my/images/folder:/images -p 2002:2002/udp -e NETDRIVE_LOG_LEVEL=debug smeed/netdrive
mTCP NetDrive by M Brutman (mbbrutman@gmail.com) (C)opyright 2023-2024, Version: Aug 16 2024

2024-11-30 22:53:40.0124        mTCP NetDrive by M Brutman (mbbrutman@gmail.com) (C)opyright 2023-2024, Version: Aug 16 2024
2024-11-30 22:53:40.0125        Args: [/app/netdrive -log_file netdrive.log -log_level debug serve -headless -image_dir /images -port 2002]
Headless mode specified - use Ctrl-C to exit.
2024-11-30 22:53:40.0128 INFO   Serve: Listening on port 2002
2024-11-30 22:53:47.2360 DEBUG  Serve:processUdp: Incoming command, addr: [::ffff:10.211.0.211]:59451, cmd: Ver: 2, Session: 0, Seq: 16922, Cmd: 1, Res: 0, Start: 0, Count: 0, optDataLen: 60
2024-11-30 22:53:47.2360 DEBUG  Serve:doConnect: Cmd and payload, addr: [::ffff:10.211.0.211]:59451, cmd: Ver: 2, Session: 0, Seq: 16922, Cmd: 1, Res: 0, Start: 0, Count: 0, payload: [0 11 180 0 0 1 1 0 0 2 68 79 83 32 55 46 49 48 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 68 105 115 107 50 46 105 109 103 0]
2024-11-30 22:53:47.2360 DEBUG  Serve:doConnect: Connection request, addr: [::ffff:10.211.0.211]:59451, client MAC: 00:0B:B4:00:00:01, image: Disk2.img
2024-11-30 22:53:47.2360 DEBUG  ImageFile:OpenImage: Attempting to open /images/Disk2.img
2024-11-30 22:53:47.2360 DEBUG  ImageFile:OpenImage: /images/Disk2.img, bytes: 1474560, mode: -rw-rw-r--
2024-11-30 22:53:47.2361 DEBUG  Journal:openGoBackJournal: image filename /images/Disk2.img
2024-11-30 22:53:47.2361 DEBUG  Journal:openJournalFile: drive filename /images/Disk2.img
2024-11-30 22:53:47.2361 INFO   Journal:openJournalFile: No journal found for /images/Disk2.img
2024-11-30 22:53:47.2361 DEBUG  ImageFile:OpenImage: New openImage created: Name: /images/Disk2.img, Size: 1474560, Readonly: false, Journal type: No Journal
2024-11-30 22:53:47.2362 DEBUG  ImageFile:ReadLbas: Session 0 Read 1 blocks at LBA 0 from offset 0 in image file
2024-11-30 22:53:47.2362 DEBUG  Serve:doConnect: BPB, addr [::ffff:10.211.0.211]:59451, filename: /images/Disk2.img, BPB err msg: <nil>, BPB: bps: 512, clsize: 1, RsvdSecs: 1, numFATs: 2, RootDirSize: 224, TotalSecs: 2880, MediaDesc: F0, SecsPerFat: 9 SecsPerTrack: 18, Heads: 2, HiddenSecs: 0, HugeSecs: 0
2024-11-30 22:53:47.2362 DEBUG  ImageFile:ReadLbas: Session 0 Read 1 blocks at LBA 1 from offset 512 in image file
2024-11-30 22:53:47.2362 DEBUG  Serve:sendResp: Addr: [::ffff:10.211.0.211]:59451, resp: Ver: 2, Session: 58726, Seq: 16922, Cmd: 1, Res: 0, Start: 0, Count: 0, optDataLen: 71
2024-11-30 22:53:47.2363 INFO   Serve:doConnect: New Session, addr: [::ffff:10.211.0.211]:59451, session: 58726, 00:0B:B4:00:00:01, 10.211.0.211:59451, /images/Disk2.img (RW), Started: 2024-11-30 22:53:47, Last seen: 2024-11-30 22:53:47, Blocks Read: 0, Blocks Written: 0, Retries: 0, Latency: 10000, OS Ver: DOS 7.10
2024-11-30 22:53:47.2613 DEBUG  Serve:processUdp: Incoming command, addr: [::ffff:10.211.0.211]:59451, cmd: Ver: 1, Session: 58726, Seq: 16923, Cmd: 3, Res: 0, Start: 19, Count: 1, optDataLen: 0
2024-11-30 22:53:47.2613 DEBUG  ImageFile:ReadLbas: Session 58726 Read 1 blocks at LBA 19 from offset 9728 in image file
2024-11-30 22:53:47.2613 DEBUG  Serve:sendResp: Addr: [::ffff:10.211.0.211]:59451, resp: Ver: 2, Session: 58726, Seq: 16923, Cmd: 3, Res: 0, Start: 19, Count: 1, optDataLen: 512
```

## Dockerfile

The build will fetch the mTCP precompiled binaries from the main site and will wrap it in an Alpine image. You can build it yourself if you want to and perhaps tweak with the `NETDRIVE_SERVER_VERSION`. The resulting docker image will launch the NetDrive server using the `-headless` option, but pushes log information to `/dev/stdout` so you can see what it is doing in the docker logs as it's using the log_file option.

```
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

# create a logfile which points to stdout
RUN ln -sf /dev/stdout netdrive.log 

EXPOSE 2002/udp
ENV NETDRIVE_LOG_LEVEL=info

ENTRYPOINT ["/bin/sh", "-c", "/app/netdrive -log_file netdrive.log -log_level ${NETDRIVE_LOG_LEVEL} serve -headless -image_dir /images -port 2002"]
```