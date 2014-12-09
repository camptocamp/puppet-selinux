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
define selinux::fcontext(
  $setype,
  $ensure    = 'present',
  $recursive = true,
) {

  $path = $name

  $re = "^${path}\\(/\\.\\*\\)\\?\\s+.*\\s+\\w+:\\w+:${setype}:s0 $"

  if $recursive {
    $path_glob = '(/.*)?'
  } else {
    $path_glob = ''
  }

  if $ensure == 'present' {
    $semanage = '--add'
    $grep     = 'egrep'
  } else {
      $semanage = '--delete'
      $grep     = '! egrep -q'
  }

  exec { "semanage fcontext ${setype} ${path}${path_glob}":
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => "semanage fcontext -a -t ${setype} \"${path}${path_glob}\"",
    unless  => "semanage fcontext --list | ( ${grep} '${re}' >/dev/null)"
  }

  exec { "restorecon -R ${path}":
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => "restorecon -R ${path}"
  }

}
