Puppet::Type.type(:selinux_port).provide(:semanage) do

  commands :semanage => 'semanage', :restorecon => 'restorecon'

  mk_resource_methods

  def self.instances
    semanage(['port', '-n', '-l']).split("\n").map do |port|
      seltype, proto, port = port.split
      new({
        :ensure  => :present,
        :name    => "#{seltype}+#{proto}",
        :seltype => seltype,
        :proto   => proto,
        :port    => port,
      })
    end
  end

  def self.prefetch(resources)
    ports = instances
    resources.keys.each do |name|
      if provider = ports.find{ |port| port.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    semanage(['port', '-a', resource[:seltype], '-p', resource[:proto].to_s, resource[:port]])
    @property_hash[:ensure] == :present
  end

  def destroy
    semanage(['port', '-d', resource[:seltype], '-p', resource[:proto].to_s, resource[:port]])
    @property_hash.clear
  end

  def port=(value)
    semanage(['port', '-m', resource[:seltype], '-p', resource[:proto].to_s, value])
    @property_hash[:port] = value
  end
end
