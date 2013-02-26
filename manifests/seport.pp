/*
== Definition: selinux::seport

Adds/removes ports to SELinux security contexts.

Parameters:

- *$name*: security context name
- *$ensure*: present/absent
- *$proto*: tcp/udp
- *$port*: port number to add/remove from security context

Example usage:

  # allow apache to bind on port 8001
  selinux::seport { "http_port_t":
    ensure => present,
    proto  => "tcp",
    port   => "8001",
    before => Service["apache"],
  }

*/
define selinux::seport($ensure='present', $proto='tcp', $port, $setype=undef) {

# this is dreadful to read, sorry...

  if $setype == undef {
    $type = $name
  }   
  else {
    $type = $setype
  }   

  $re = "^${type}\W+${proto}\W+.*\W${port}(\W|$)"

    if $ensure == "present" {
      $semanage = "--add"
        $grep     = "egrep -q" 
    } else {
      $semanage = "--delete"
        $grep     = "! egrep -q" 
    }

  exec { "semanage port ${port}, proto ${proto}, type ${type}":
    command => "semanage port ${semanage} --type ${type} --proto ${proto} ${port}",
            unless  => "semanage port --list | ( ${grep} '${re}' )", # subshell required to invert return status with !
  }
}
