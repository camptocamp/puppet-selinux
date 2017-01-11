# == Definition: selinux::fcontext
#
# Changes the selinux context of files and directories.
#
# Parameters:
#
# - *$name*: file/dir name or regex
# - *$ensure*: present/absent
# - *$recursive*: apply to all subdirectories
# - *$setype*: security context name
# - *$refreshonly*: if true, restorecon only runs if something changed
#
# Example usage:
#
#   # allow apache to read from here
#   selinux::fcontext { "/var/www":
#     ensure    => present,
#     recursive => true,
#     setype    => "httpd_sys_content_t"
#   }
#
# This will add a line (between the #), to the configuration
# ini the output of: semanage fcontext --list
#/var/www(/.*)?                                     all files          system_u:object_r:httpd_sys_content_t:s0 # lint:ignore:80chars
#
# A more complex example:
#
#   # Make /var/www/*/*/logs httpd_log_t
#   selinux::fcontext { '/var/www(/.*)(/.*)/logs':
#    ensure      => present,
#    recursive   => true,
#    setype      => "httpd_log_t",
#    refreshonly => true,
#   }
#
# This will add a line to the configuration
# It can be seen by executing semanage fcontext --list
#/var/www(/.*)(/.*)/logs(/.*)?                      all files          system_u:object_r:httpd_log_t:s0

define selinux::fcontext(
  $setype,
  $ensure    = 'present',
  $recursive = true,
  $refreshonly = true,
) {

  $path = $name

# Escaping most common special characters in contexts - (/.*)?
  $reescapedpath = regsubst($path, '\(/\.\*\)', '\\(/\\.\\*\\)', 'G')

# Regular expression that is generated to be used with semanage fcontext --list
  $re = "^${reescapedpath}\\(/\\.\\*\\)\\?\\s+.*\\s+\\w+:\\w+:${setype}:s0 $"

  if $recursive {
    $path_glob = '(/.*)?'
  } else {
    # lint:ignore:empty_string_assignment
    $path_glob = ''
    # lint:endignore
  }

  if $ensure == 'present' {
    $semanage = '--add'
    $grep     = 'egrep'
  } else {
      $semanage = '--delete'
      $grep     = '! egrep -q'
  }

# Change the regex into a shell glob
  $pathrc = regsubst($path, '\(/\.\*\)', '/*', 'G')

  exec { "semanage fcontext ${setype} ${path}${path_glob}":
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => "semanage fcontext -a -t ${setype} \"${path}${path_glob}\"",
    unless  => "semanage fcontext --list | ( ${grep} '${re}' >/dev/null)",
  } ~>
  exec { "restorecon -R ${pathrc}":
    path        => '/usr/bin:/usr/sbin:/bin:/sbin',
    refreshonly => $refreshonly,
  }

}
