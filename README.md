# jitsi

Module for installing Jitsi Server (via docker-compose) and Client (as AppImage)

## Description

This module acts as a wrapper around a wrapper.
On the server, it clones a stable version of the docker-composer file, performs some minor modifications and starts the server.
By default it expects you to install a reverse proxy which exposes jitsi to the internet.

On the client it downloads a stable version of the AppImage from GitHub and saves it on `/usr/local/bin`.

## Usage

On the server side we set several values:

* default video resolution is set to 720p
* [layer suspension](https://jitsi.org/blog/new-off-stage-layer-suppression-feature/) is enabled
* you have several options to control audio processing.

Note that you have to provide passwords for internal communication.
You can pass them to the class directly as parameters or through hiera.
To find suitable values you can determine them with any means, for instance `openssl rand -hex 16` as the creators of the jitsi-docker-implementation recommend.

An example using hiera:
```
jitsi::containerized_server::jicofo_component_secret: 84f617c4eacf104e70192fd76b970cc2
jitsi::containerized_server::jicofo_auth_password: 111139410e4b893aaab88d7bc405f760
jitsi::containerized_server::jvb_auth_password: cf766b3e73526a86963bc5083de2f880
jitsi::containerized_server::jigasi_xmpp_password: 7b115af382049d6b57e094d5fff0961a
jitsi::containerized_server::jibri_recorder_password: 58502b58498042df781f49882551848e
jitsi::containerized_server::jibri_xmpp_password: a402dd279a6f7bb21109532bb98e8863
```

