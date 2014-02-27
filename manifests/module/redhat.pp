#
# == Definition: selinux::module::redhat
#
# This definition builds a binary SELinux module with the Makefile provided by
# the selinux-policy-devel or selinux-policy package.
# It should only be called ba the selinux::module definition, in case of
# RedHat osfamily.
#
# Parameters:
#
# - *name*: the name of the SELinux module
# - *workdir*: where the module source and binary files are stored. Defaults to
#   "/etc/puppet/selinux" (not used here, yet ?)
# - *dest*: where the binary module must be copied. Defaults to
#   "/usr/share/selinux/targeted/"
# - *content*: inline content or template of the module source
# - *source*: file:// or puppet:// URI of the module source file
#
#
define selinux::module::redhat (
  $workdir='/etc/puppet/selinux',
  $dest='/usr/share/selinux/targeted/',
  $content=undef,
  $source=undef
) {

  if $content {
    file { "${dest}/${name}.te":
      ensure  => present,
      content => $content,
    }
  }

  if $source {
    file { "${dest}/${name}.te":
      ensure  => present,
      source  => $source,
    }
  }

  file { "${dest}/${name}.pp":
    require => [File["${dest}/${name}.te"], Package['checkpolicy']],
    notify  => Exec["build selinux policy package ${name}"],
  }

  $build_reqs = $lsbmajdistrelease  ? {
    '5'     => [File["${dest}/${name}.te"], Package['checkpolicy'], Package ['selinux-policy-devel']],
    default => [File["${dest}/${name}.te"], Package['checkpolicy']],
  }
  exec { "build selinux policy package ${name}":
    cwd     => $dest,
    command => "make -f /usr/share/selinux/devel/Makefile ${name}.pp",
    require => $build_reqs,
  }

}
