Puppet::Type.newtype(:selinux_fcontext) do
  @doc = "Manage SELinux file contexts."

  ensurable

  newparam(:name) do
    desc "The default namevar."
  end

  newproperty(:context) do
    desc "The SELinux context to apply."
  end
end
