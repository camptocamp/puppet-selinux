Puppet::Type.newtype(:selinux_port) do
  @doc = 'Manage SELinux network port type definitions.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The default namevar.'
  end

  newparam(:seltype, namevar: true) do
    desc 'SELinux Type for the object.'
    newvalues(%r{_port_t$})
  end

  newparam(:proto, namevar: true) do
    desc 'Protocol for the specified port (tcp|udp) or internet protocol version for the specified node (ipv4|ipv6).'
    newvalues(:tcp, :udp, :ipv4, :ipv6)
    defaultto :tcp
  end

  newparam(:port, namevar: true) do
    desc 'The SELinux type to apply.'
  end

  def self.title_patterns
    [
      [
        /^(([^\/]+)\/([^\/]+)\/(.*))$/,
        [
          [:name, ->(x) { x }],
          [:seltype, ->(x) { x }],
          [:proto, ->(x) { x }],
          [:port, ->(x) { x }],
        ],
      ],
      [
        /^(([^\/]+)\/([^\/]+))$/,
        [
          [:name, ->(x) { x }],
          [:seltype, ->(x) { x }],
          [:proto, ->(x) { x }],
        ],
      ],
      [
        %r{(.*)},
        [
          [:name, ->(x) { x }],
        ],
      ],
    ]
  end
end
