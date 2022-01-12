# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'trusted_ca', order: :defined do
  let(:fqdn) { fact('networking.fqdn') }

  context 'failure before cert' do
    # Set up site first, verify things don't work
    it 'sets up apache for testing' do
      pp = <<-EOS
      include java
      include apache
      apache::vhost { 'trusted_ca':
        docroot    => '/tmp',
        port       => 443,
        servername => $facts['networking']['fqdn'],
        ssl        => true,
        ssl_cert   => '/etc/ssl-secure/test.crt',
        ssl_key    => '/etc/ssl-secure/test.key',
      }
      EOS
      apply_manifest(pp, catch_failures: true)
    end

    specify do
      expect(command("/usr/bin/curl https://#{fqdn}:443")).
        to have_attributes(exit_status: 60)
    end

    specify do
      expect(command("cd /root && /usr/bin/java SSLPoke #{fqdn} 443")).
        to have_attributes(exit_status: 1)
    end
  end

  context 'success after cert' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'trusted_ca': }
        trusted_ca::ca { 'test': source => '/etc/ssl-secure/test.crt' }
        PUPPET
      end
    end

    specify { expect(package('ca-certificates')).to be_installed }

    specify do
      expect(command("/usr/bin/curl https://#{fqdn}:443")).
        to have_attributes(exit_status: 0)
    end

    specify do
      expect(command("cd /root && /usr/bin/java SSLPoke #{fqdn} 443")).
        to have_attributes(exit_status: 0)
    end
  end
end
