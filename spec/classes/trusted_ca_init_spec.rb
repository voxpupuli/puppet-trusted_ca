require 'spec_helper'

describe 'trusted_ca' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'ca-certificates' do
          package_name = if facts[:osfamily] == 'Suse' && facts[:operatingsystem] == 'SLES' && facts[:operatingsystemmajrelease] == '11'
                           'openssl-certs'
                         else
                           'ca-certificates'
                         end

          context 'default' do
            it { is_expected.to contain_package(package_name).with(ensure: 'latest') }
          end

          context 'set version' do
            let(:params) { { certificates_version: '1.2.3.4' } }

            it { is_expected.to contain_package(package_name).with(ensure: '1.2.3.4') }
          end
        end

        context 'update_system_certs' do
          context 'array path' do
            let(:params) { { path: ['/bin', '/usr/bin'] } }

            it { is_expected.to contain_exec('update_system_certs').with(refreshonly: true, path: ['/bin', '/usr/bin']) }
          end

          context 'string path' do
            let(:params) { { path: '/usr/bin' } }

            it { is_expected.to contain_exec('update_system_certs').with(refreshonly: true, path: '/usr/bin') }
          end
        end
      end
    end
  end

  context 'fail on unsupported system' do
    let(:facts) do
      {
        os: {
          family: 'FreeBSD',
          name: 'FreeBSD',
          release: {
            full: '1.2.3'
          }
        },
        osfamily: 'FreeBSD',
        operatingsystemrelease: '1.2.3'
      }
    end

    it { is_expected.to compile.and_raise_error(%r{not supported}) }
  end
end
