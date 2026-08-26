# frozen_string_literal: true

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
            it { is_expected.to contain_package(package_name).with(ensure: 'installed') }
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

        context 'when ca_certificates parameter is set' do
          let(:params) do
            {
              ca_certificates: {
                'example_ca.crt': {
                  source: 'file:///example_ca.crt',
                },
              },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to have_trusted_ca__ca_resource_count(1) }
          it { is_expected.to contain_trusted_ca__ca('example_ca.crt').with_source('file:///example_ca.crt') }
        end

        context 'when java_keystores parameter is set' do
          let(:params) do
            {
              java_keystores: {
                example_ca: {
                  java_keystore: '/etc/pki/java/example.jks',
                  source: 'file:///example_ca.crt',
                },
              },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to have_trusted_ca__java_resource_count(1) }
          it { is_expected.to contain_trusted_ca__java('example_ca').with_source('file:///example_ca.crt') }
          it { is_expected.to contain_trusted_ca__java('example_ca').with_java_keystore('/etc/pki/java/example.jks') }
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
