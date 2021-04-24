# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include jitsi::containerized_server
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
) {
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
