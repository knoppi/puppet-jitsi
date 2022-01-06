# @summary Install Jitsi as a containerized service
#
# This class downloads definitions from https://github.com/jitsi/docker-jitsi-meet
# and performs basic settings to produce a simple working setup of jitsi.
# The code in the repository uses docker-compose to start the services as
# containers.
#
# @example
#   include jitsi::containerized_server
#
# @param jicofo_component_secret
#   (required) XMPP component password for Jicofo;
#   set it to random string as output by `openssl rand -hex 16`
# @param jicofo_auth_password
#   (required) XMPP password for Jicofo client connections;
#   set it to random string as output by `openssl rand -hex 16`
# @param jvb_auth_password
#   (required) XMPP password for JVB client connections;
#   set it to random string as output by `openssl rand -hex 16`
# @param jigasi_xmpp_password
#   (required) XMPP password for Jigasi MUC client connections;
#   set it to random string as output by `openssl rand -hex 16`
# @param jibri_recorder_password
#   (required) XMPP recorder password for Jibri client connections;
#   set it to random string as output by `openssl rand -hex 16`
# @param jibri_xmpp_password
#   (required) XMPP password for Jibri client connections;
#   set it to random string as output by `openssl rand -hex 16`
# @param http_port
#   Set the port on which you can reach the web frontend via HTTP.
#   Defaults to 30799.
#   This is required in particular if you run Jitsi behin a reverse proxy.
# @param https_port
#   Set the port on which you can reach the web frontend via HTTPS.
#   Defaults to 30800.
# @param timezone
#   Set the timezone, your jitsi instance is running in.
#   Defaults to Europe/Amsterdam.
# @param public_url
#   Set the URL where your users can reach the web frontend.
# @param domain
#   FQDN of your jitsi instance.
# @param version
#   version of the container images used
# @param jibri_domain
#   If using jibri for recording or streaming, it enters the meeting as an additional
#   user. If it has the domain given in this parameter it will actually be hidden.
# @param enable_breakout_rooms
#   Enables breakout rooms
# @param disable_all_audio_processing
#   Set to True if you want to disable all audio processing.
#   Overrides all of the subsequent parameters.
# @param disable_echo_cancellation
#   Set to True if you want to disable echo cancellation.
# @param disable_noise_supression
#   Set to True if you want to disable noise suppression.
# @param disable_auto_gain_control
#   Set to True if you want to disable auto gain control.
# @param disable_high_pass_filter
#   Set to True if you want to disable high pass filtering.
# @param jwt_app_id
#   Define an id for embedding into jwt based authentication
# @param jwt_app_secret
#   Secret for use with JWT authentication
# @param allow_guests
#   If guests access is allowed
# @param disable_third_party_requests
#   when set to true, no third parties like gravatar will be called (default)
# @param noisy_mic_detection
#   set to false if you want to disable the detection of noisy mics
# @param video_resolution
#   set the preferred video resolution
# @param start_muted
#   use this to define if a user shall start muted (true) or with audio enabled (false)
# @param start_without_video
#   use this to define if a user shall start without video activatedf (true)
class jitsi::containerized_server (
  Integer $http_port,
  Integer $https_port,
  String $timezone,
  String $public_url,
  String $domain,
  String $version,
  String $jibri_domain,
  Boolean $disable_all_audio_processing,
  Boolean $disable_echo_cancellation,
  Boolean $disable_noise_supression,
  Boolean $disable_auto_gain_control,
  Boolean $disable_high_pass_filter,
  Boolean $enable_breakout_rooms,
  String $jicofo_component_secret,
  String $jicofo_auth_password,
  String $jvb_auth_password,
  String $jigasi_xmpp_password,
  String $jibri_recorder_password,
  String $jibri_xmpp_password,
  String $jwt_app_id,
  String $jwt_app_secret,
  Integer $allow_guests,
  Boolean $disable_third_party_requests,
  Boolean $noisy_mic_detection,
  Integer $video_resolution,
  Boolean $start_muted,
  Boolean $start_without_video,
) {
  if ($jwt_app_id != '' and $jwt_app_secret != '')
  {
    $auth_enabled = 1
    $auth_type = 'jwt'
  }
  else {
    $auth_enabled = 0
    $auth_type = 'internal'
  }


  vcsrepo { '/srv/jitsi/':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/jitsi/docker-jitsi-meet',
    revision => $version,
  }
  -> file { '/srv/jitsi/.env':
    ensure  => present,
    content => template('jitsi/env.erb'),
  }
  ~> exec { 'turn off jitsi':
    cwd         => '/srv/jitsi',
    command     => '/usr/local/bin/docker-compose down',
    refreshonly => true,
  }
  ~> exec { '/usr/bin/rm -Rf /srv/jitsi/.jitsi-meet-cfg' :
    refreshonly => true,
  }

  file { [
    '/srv/jitsi/.jitsi-meet-cfg/',
    '/srv/jitsi/.jitsi-meet-cfg/web',
    '/srv/jitsi/.jitsi-meet-cfg/transcripts',
    '/srv/jitsi/.jitsi-meet-cfg/prosody',
    '/srv/jitsi/.jitsi-meet-cfg/prosody/config',
    '/srv/jitsi/.jitsi-meet-cfg/prosody/prosody-plugins-custom',
    '/srv/jitsi/.jitsi-meet-cfg/jicofo',
    '/srv/jitsi/.jitsi-meet-cfg/jvb',
    ] :
      ensure => directory,
  }

  exec { 'turn on jitsi':
    cwd         => '/srv/jitsi',
    command     => '/usr/local/bin/docker-compose up -d',
    subscribe   => [
      Vcsrepo['/srv/jitsi/'],
      Exec['turn off jitsi'],
    ],
    refreshonly => true,
  }

  file { '/srv/jitsi/.jitsi-meet-cfg/web/config.js':
    ensure  => present,
    content => template('jitsi/web_config.js.erb'),
    backup  => '.puppet-bak',
  }

}
