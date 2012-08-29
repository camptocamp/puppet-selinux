#
# == Definition: selinux::permissivedomain
#
# put/remove a single domain in permissive mode
#
define selinux::permissivedomain( $ensure='present' ) {

  if $ensure == 'present' {
    $action='-a'
  } else {
    $action='-d'
  }

  exec { "semanage permissive ${action} ${name}":
    command => "semanage permissive ${action} ${name}",
    unless  => "semodule --list | grep permissive_${name}",
  }

}
