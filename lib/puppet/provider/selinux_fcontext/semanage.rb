Puppet::Type.type(:selinux_fcontext).provide(:semanage) do

  commands :semanage => 'semanage', :restorecon => 'restorecon'

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

  def create
    args = ['fcontext', '-a']
    args << ['--seuser', resource[:seluser]] if resource[:seluser]
    args << ['--role', resource[:selrole]] if resource[:selrole]
    args << ['--type', resource[:seltype]] if resource[:seltype]
    args << ['--range', resource[:selrange]] if resource[:selrange]
    args << "\"#{resource[:name]}\""
    semanage(args.flatten)
    restorecon(['-R', resource[:name].split('(')[0]])
    @property_hash[:ensure] == :present
  end

  def destroy
    semanage(['fcontext', '-d', "\"#{resource[:name]}\""])
    restorecon(['-R', resource[:name].split('(')[0]])
    @property_hash[:ensure] == :absent
  end
end
