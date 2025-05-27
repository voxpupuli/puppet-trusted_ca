# frozen_string_literal: true

require 'spec_helper'

describe 'trusted_ca::java' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }
        let(:title) { 'mycert' }
        let(:pre_condition) { 'include trusted_ca' }
        let(:local_params) { {} }
        let(:params) { { java_keystore: '/etc/alternatives/jre_1.7.0/lib/security/cacerts' }.merge(local_params) }

        context 'validations' do
          context 'bad content' do
            let(:local_params) { { content: '^' } }

            it { is_expected.to compile.and_raise_error(%r{parameter 'content' expects}) }
          end

          context 'specifying both source and content' do
            let(:local_params) { { source: 'puppet:///data/mycert.crt', content: 'foo' } }

            it { is_expected.to compile.and_raise_error(%r{You must not specify both \$source and \$content}) }
          end

          context 'specifying neither source nor content' do
            it { is_expected.to compile.and_raise_error(%r{You must specify either \$source or \$content}) }
          end

          context 'not including trusted_ca' do
            let(:pre_condition) { nil }

            it { is_expected.to compile.and_raise_error(%r{You must include the trusted_ca base class}) }
          end
        end

        context 'correct call' do
          let(:local_params) { { content: 'abc' } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/tmp/mycert-trustedca') }

          it do
            is_expected.to contain_exec('validate /tmp/mycert-trustedca contents'). \
              with_command('openssl x509 -in /tmp/mycert-trustedca -noout').that_notifies('Exec[import /tmp/mycert-trustedca to jks /etc/alternatives/jre_1.7.0/lib/security/cacerts]')
          end

          it do
            is_expected.to contain_exec('import /tmp/mycert-trustedca to jks /etc/alternatives/jre_1.7.0/lib/security/cacerts'). \
              with_command('keytool -import -noprompt -trustcacerts -alias mycert -file /tmp/mycert-trustedca -keystore /etc/alternatives/jre_1.7.0/lib/security/cacerts -storepass changeit')
          end
        end
      end
    end
  end
end
