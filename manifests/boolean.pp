#
# == Definition: selinux::boolean
#
# set the value of an selinux boolean
#
define selinux::boolean( $value ) {

  case $value {
    0,'0','off': { $_value = 'off' }
    1,'1','on': { $_value = 'on' }
    default: { fail '$value must be \'on\' or \'off\'' }
  }

  exec { "semanage boolean -m --${_value} ${name}":
    unless  => "semanage boolean -l | grep ${name} | grep \(${_value}",
  }

}
