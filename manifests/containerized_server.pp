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
    cwd     => '/srv/jitsi',
    command => '/usr/local/bin/docker-compose down',
  }
  ~> exec { '/usr/bin/rm -Rf /srv/jitsi/.jitsi-meet-cfg' : }

  file { [
    '/srv/jitsi/.jitsi-meet-cfg/',
    '/srv/jitsi/.jitsi-meet-cfg/web',
    '/srv/jitsi/.jitsi-meet-cfg/web/letsencrypt',
    '/srv/jitsi/.jitsi-meet-cfg/transcripts',
    '/srv/jitsi/.jitsi-meet-cfg/prosody',
    '/srv/jitsi/.jitsi-meet-cfg/prosody/config',
    '/srv/jitsi/.jitsi-meet-cfg/prosody/prosody-plugins-custom',
    '/srv/jitsi/.jitsi-meet-cfg/jicofo',
    '/srv/jitsi/.jitsi-meet-cfg/jvb',
    '/srv/jitsi/.jitsi-meet-cfg/jigasi',
    '/srv/jitsi/.jitsi-meet-cfg/jibri',
    ] :
      ensure => directory,
  }

  exec { 'turn on jitsi':
    cwd     => '/srv/jitsi',
    command => '/usr/local/bin/docker-compose up -d',
    subscribe     => [
      Vcsrepo['/srv/jitsi/'],
      Exec['turn off jitsi'],
    ]
  }
}
