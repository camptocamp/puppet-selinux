#
# == Definition: selinux::permissivedomain
#
# put/remove a single domain in permissive mode
#
define selinux::permissivedomain( $ensure='present' ) {

  if $ensure == 'present' {
    $action = '-a'
    $onlyif = undef
    $unless = "semanage permissive -l | grep -q '^${name}$'"
  } else {
    $action = '-d'
    $onlyif = "semanage permissive -l | grep -q '^${name}$'"
    $unless = undef
  }

  exec { "semanage permissive ${action} ${name}":
    command => "semanage permissive ${action} '${name}'",
    onlyif  => $onlyif,
    unless  => $unless,
  }

}
