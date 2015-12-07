Puppet::Type.type(:selinux_fcontext).provide(:semanage) do

  commands :semanage => 'semanage'

  mk_resource_methods

  def self.instances
  end

  def self.prefetch
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
