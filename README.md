# jitsi

Module for installing Jitsi Server (via docker-compose) and Client (as AppImage)

## Description

This module acts as a wrapper around a wrapper.
On the server, it clones a stable version of the docker-composer file, performs some minor modifications and starts the server.
By default it expects you to install a reverse proxy which exposes jitsi to the internet.

On the client it downloads a stable version of the AppImage from GitHub and saves it on `/usr/local/bin`.

Client and server classes are completely unrelated but, of course, deal with connected subjects.

## Usage

### Client

The class for the client does not need any further parameters but can work with the defaults.
Just assign it to your node and it will download the AppImage from the GitHub Releases.

```
include jitsi::client
```

You can also specify the version you want to download.
In that case make sure you also specify the corresponding checksum and checksum type.
```
class { 'jitsi::client':
  version       => 'v2.8.5',
  checksum      => 'a5a97217d72c7711efe9a1dffa51f75f93105cdfdf951e7dcc90724b89feb41b964cc664d7f9b6df5662ba6841a40e6b6613e07d6c9f08510ef32fadb1bdb242',
  checksum_type => 'sha512',
```

### Containerized Server

To install the containerized version of the Jitsi server part it is required to define at least the XMPP secrets.
```
class { 'jitsi::containerized_server':
  jicofo_component_secret => 84f617c4eacf104e70192fd76b970cc2,
  jicofo_auth_password    => 111139410e4b893aaab88d7bc405f760,
  jvb_auth_password       => cf766b3e73526a86963bc5083de2f880,
  jigasi_xmpp_password    => 7b115af382049d6b57e094d5fff0961a,
  jibri_recorder_password => 58502b58498042df781f49882551848e,
  jibri_xmpp_password     => a402dd279a6f7bb21109532bb98e8863,
}
```

You can set all parameters using hiera:
```
classes:
  - jitsi::containerized_server

jitsi::containerized_server::jicofo_component_secret: 84f617c4eacf104e70192fd76b970cc2
jitsi::containerized_server::jicofo_auth_password: 111139410e4b893aaab88d7bc405f760
jitsi::containerized_server::jvb_auth_password: cf766b3e73526a86963bc5083de2f880
jitsi::containerized_server::jigasi_xmpp_password: 7b115af382049d6b57e094d5fff0961a
jitsi::containerized_server::jibri_recorder_password: 58502b58498042df781f49882551848e
jitsi::containerized_server::jibri_xmpp_password: a402dd279a6f7bb21109532bb98e8863
```
To find suitable values you can determine them with any means, for instance `openssl rand -hex 16` as the creators of the jitsi-docker-implementation recommend.

There are several files governing the behaviour of your jitsi server.
Most of the settings are passed to the containers as environment variable using the file `.env`
Settings concerning the web frontend are changed in `${CONFIG_DIR}/web/config.js`.
Both are rendered from templates.

You can add environment variables (see [Self-Hosting Guide - Docker](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker/)) via custom_variables parameter, if they aren't represented as a parameter itself:
```
jitsi::containerized_server::custom_variables:
  DISABLE_AUDIO_LEVELS: 0
  ENABLE_END_CONFERENCE: 0
```

#### Changing ports

You can, for instance, change the ports the containers expose.
By default they are running on `30799` for HTTP and `30800` for HTTPS.
The HTTP port is relevant if you place your jitsi behind a reverse proxy.
In that case it is also recommended to set your public url:

```
jitsi::containerized_server::http_port: 30032
jitsi::containerized_server::https_port: 30033
jitsi::containerized_server::public_url: "https://your.jitsi.domain
```

Not that so far, no testing of the Let's Encrypt Integration have been done.

#### Changing web frontend

On the server side we set several values:

* default video resolution is set to 720p
* [layer suspension](https://jitsi.org/blog/new-off-stage-layer-suppression-feature/) is enabled
* you have several options to control audio processing.

Jitsi by default does some audio processing.
You can turn it off completely by passing

```
jitsi::containerized_server::disable_all_audio_processing: true
```

Note the inverse structure: The parameters are meant to disable features, so setting the parameters to `false` activates the function.
By default this setup disables auto gain controll and high pass filters while enabling echo cancellation and noise suppression

```
jitsi::containerized_server::disable_echo_cancellation: false
jitsi::containerized_server::disable_noise_supression: false
jitsi::containerized_server::disable_auto_gain_control: true
jitsi::containerized_server::disable_high_pass_filter: true
```

#### Starting additional containers

You can add additional container to compose process (like Jigasi, Jibri and Etherpad) using these parameters:
```
jitsi::containerized_server::compose_jigasi: false
jitsi::containerized_server::compose_jibri: false
jitsi::containerized_server::compose_etherpad: false
```

## Notes

This is an experiment on how to handle standalone containerized applications.
