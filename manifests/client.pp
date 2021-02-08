# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include jitsi::client
class jitsi::client (
  String $version,
  String $checksum,
  String $checksum_type,
) {
  remote_file { 'jitsi_AppImage':
    ensure        => present,
    source        => "https://github.com/jitsi/jitsi-meet-electron/releases/download/${version}/jitsi-meet-x86_64.AppImage",
    path          => '/usr/local/bin/jitsi-meet-x86_64.AppImage',
    checksum      => $checksum,
    checksum_type => $checksum_type,
    mode          => '0755',
  }

  file { '/usr/local/bin/jitsi':
    ensure => link,
    target => '/usr/local/bin/jitsi-meet-x86_64.AppImage',
  }
}
