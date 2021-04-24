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

