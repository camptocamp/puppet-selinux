Puppet::Type.type(:selinux_fcontext).provide(:semanage) do

  commands :semanage => 'semanage'

  mk_resource_methods

  def self.instances
    semanage('fcontext', '-n', '-l', '-C').split("\n").map do |fcontext|
      name, *type, context = fcontext.split
      seluser, selrole, seltype, selrange = context.split(':')
      new({
        :ensure   => :present,
        :name     => name,
        :seluser  => seluser,
        :selrole  => selrole,
        :seltype  => seltype,
        :selrange => selrange,
      })
    end
  end

  def self.prefetch(resources)
    fcontexts = instances
    resources.keys.each do |name|
      if provider = fcontexts.find{ |fcontext| fcontext.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
