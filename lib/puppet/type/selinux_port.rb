Puppet::Type.newtype(:selinux_port) do
  @doc = "Manage SELinux network port type definitions."

  ensurable

  newparam(:seltype, :namevar => true) do
    desc "SELinux Type for the object."
    newvalues(/_port_t$/)
  end

  newparam(:proto, :namevar => true) do
    desc "Protocol for the specified port (tcp|udp) or internet protocol version for the specified node (ipv4|ipv6)."
    newvalues(:tcp, :udp, :ipv4, :ipv6)
    defaultto :tcp
  end

  def self.title_patterns
    [
      [
        /^(\S+)\/(\S+)$/,
        [
          [ :seltype, lambda{|x| x} ],
          [ :proto, lambda{|x| x} ],
        ],
        /(.*)/,
        [
          [ :seltype, lambda{|x| x} ],
        ],
      ],
    ]
  end

  newproperty(:port) do
    desc "The SELinux type to apply."
  end
end
