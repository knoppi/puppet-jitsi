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
  String $version,
) {
  vcsrepo { '/srv/jitsi/':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/jitsi/docker-jitsi-meet',
    revision => $version,
  }

  file { '/srv/jitsi/.env':
    ensure  => present,
    content => template('jitsi/env.erb'),
  }
}
