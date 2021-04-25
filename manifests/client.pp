# @summary Install the Jitsi client
#
# On Linux hosts this class installs the specified version of the standalone
# electron client for jitsi as an AppImage package.
#
# @example
#   include jitsi::client
# @param version
#   Which version to install. Find available versions on
#   https://github.com/jitsi/jitsi-meet-electron/releases.
#   The default of this parameter gets updated regularly.
#   When overriding the default make sure you also set the
#   corresponding values for `checksum` and `checksum_type`.
#   This is used to ensure you actually downloaded the file
#   you want to have.
# @param checksum
#   Part of the release assets for the Jitsi client is the file
#   latest-linux.yaml. It contains the checksum and its type.
#   Note that the checksum is encoded and you have to decode and
#   convert it:
#   ```
#   echo $value_from_yaml | base64 -d | xxd -p
#   ```
# @param checksum_type
#   Which hashing algorithm is used to calculate the checksum of
#   the AppImage. By default this is sha512.
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
