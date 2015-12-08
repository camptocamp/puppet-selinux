require 'spec_helper'

describe Puppet::Type.type(:selinux_fcontext).provider(:semanage) do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      before :each do
        Facter.clear
        facts.each do |k, v|
          Facter.stubs(:fact).with(k).returns Facter.add(k) { setcode { v } }
        end
      end

      describe 'instances' do
        it 'should have an instance method' do
          expect(described_class).to respond_to :instances
        end
      end

      describe 'prefetch' do
        it 'should have a prefetch method' do
          expect(described_class).to respond_to :prefetch
        end
      end

      context 'without file contexts' do
        before :each do
          described_class.expects(:semanage).with('fcontext', '-n', '-l', '-C').returns ''
        end
        it 'should return no resources' do
          expect(described_class.instances.size).to eq(0)
        end
      end

      context 'with a file context' do
        before :each do
          described_class.expects(:semanage).with('fcontext', '-n', '-l', '-C').returns \
            '/                                                  directory          system_u:object_r:root_t:s0 '
        end
        it 'should return one resource' do
          expect(described_class.instances.size).to eq(1)
        end
        it 'should return / file' do
          expect(described_class.instances[0].instance_variable_get("@property_hash")).to eq( {
            :ensure   => :present,
            :name     => '/',
            :seluser  => 'system_u',
            :selrole  => 'object_r',
            :seltype  => 'root_t',
            :selrange => 's0',
          } )
        end
      end

      context 'with two file contexts' do
        before :each do
          described_class.expects(:semanage).with('fcontext', '-n', '-l', '-C').returns \
            '/                                                  directory          system_u:object_r:root_t:s0 
/.*                                                all files          system_u:object_r:default_t:s0 '
        end
        it 'should return two resources' do
          expect(described_class.instances.size).to eq(2)
        end
        it 'should return /.*' do
          expect(described_class.instances[1].instance_variable_get("@property_hash")).to eq( {
            :ensure   => :present,
            :name     => '/.*',
            :seluser  => 'system_u',
            :selrole  => 'object_r',
            :seltype  => 'default_t',
            :selrange => 's0',
          } )
        end
      end

      context 'when adding a new entry with only seltype' do
        let(:resource) do
          Puppet::Type.type(:selinux_fcontext).new(
            {
              :name     => '/web(/.*)?',
              :provider => 'semanage',
              :seltype  => 'httpd_sys_content_t',
            }
          )
        end

        let(:provider) do
          resource.provider
        end

        it 'should create a new entry' do
          described_class.expects(:semanage).with(['fcontext', '-a', '--type', 'httpd_sys_content_t', '"/web(/.*)?"'])
          described_class.expects(:restorecon).with(['-R', '/web'])
          provider.create
        end
      end
    end
  end
end
