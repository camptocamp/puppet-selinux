require 'spec_helper'

describe Puppet::Type.type(:selinux_port).provider(:semanage) do

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

      context 'without ports' do
        it 'should return no resources' do
          described_class.expects(:semanage).with(['port', '-n', '-l']).returns ''
          expect(described_class.instances.size).to eq(0)
        end
      end

      context 'with a port' do
        before :each do
          described_class.expects(:semanage).with(['port', '-n', '-l']).returns \
            'afs_bos_port_t                 udp      7007
'
        end
        it 'should return one resource' do
          expect(described_class.instances.size).to eq(1)
        end
        it 'should return / file' do
          expect(described_class.instances[0].instance_variable_get("@property_hash")).to eq( {
            :ensure  => :present,
            :name    => 'afs_bos_port_t/udp',
            :seltype => 'afs_bos_port_t',
            :proto   => 'udp',
            :port    => '7007',
          } )
        end
      end

      context 'with two file contexts' do
        before :each do
          described_class.expects(:semanage).with(['port', '-n', '-l']).returns \
            'afs_bos_port_t                 udp      7007
afs_client_port_t              udp      7001
'
        end
        it 'should return two resources' do
          expect(described_class.instances.size).to eq(2)
        end
        it 'should return /.*' do
          expect(described_class.instances[1].instance_variable_get("@property_hash")).to eq( {
            :ensure  => :present,
            :name    => 'afs_client_port_t/udp',
            :seltype => 'afs_client_port_t',
            :proto   => 'udp',
            :port    => '7001',
          } )
        end
      end

      context 'when manipulating objects' do
        let(:resource) do
          Puppet::Type.type(:selinux_port).new({:name => 'http_port_t/tcp', :port => '81', :provider => 'semanage'})
        end

        let(:provider) do
          resource.provider
        end

        context 'when allowing Apache to listen on tcp port 81' do
          it 'should call `semanage port -a -t http_port_t -p tcp 81`' do
            provider.expects(:semanage).with(['port', '-a', 'http_port_t', '-p', 'tcp', '81'])
            provider.create
          end
        end

        context 'when disallowing Apache to listen on tcp port 81' do
          it 'should call `semanage port -d http_port_t -p tcp 81`' do
            provider.expects(:semanage).with(['port', '-d', 'http_port_t', '-p', 'tcp', '81'])
            provider.destroy
          end
        end

        context 'when modifying an port' do
          it 'should call `semanage port -m http_port_t -p tcp 80`' do
            provider.expects(:semanage).with(['port', '-m', 'http_port_t', '-p', 'tcp', '80'])
            provider.port = '80'
          end
        end
      end

      context 'when not using composite namevar' do
        let(:resource) do
          Puppet::Type.type(:selinux_port).new({:name => 'myport', :seltype => 'http_port_t', :proto => 'tcp', :port => '81', :provider => 'semanage'})
        end

        let(:provider) do
          resource.provider
        end

        context 'when allowing Apache to listen on tcp port 81' do
          it 'should call `semanage port -a -t http_port_t -p tcp 81`' do
            provider.expects(:semanage).with(['port', '-a', 'http_port_t', '-p', 'tcp', '81'])
            provider.create
          end
        end

        context 'when disallowing Apache to listen on tcp port 81' do
          it 'should call `semanage port -d http_port_t -p tcp 81`' do
            provider.expects(:semanage).with(['port', '-d', 'http_port_t', '-p', 'tcp', '81'])
            provider.destroy
          end
        end

        context 'when modifying an port' do
          it 'should call `semanage port -m http_port_t -p tcp 80`' do
            provider.expects(:semanage).with(['port', '-m', 'http_port_t', '-p', 'tcp', '80'])
            provider.port = '80'
          end
        end
      end
    end
  end
end
