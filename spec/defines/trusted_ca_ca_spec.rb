# frozen_string_literal: true

require 'spec_helper'

describe 'trusted_ca::ca' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }
        let(:title) { 'mycert' }
        let(:pre_condition) { 'include trusted_ca' }

        context 'validations' do
          context 'bad content' do
            let(:params) { { content: '^' } }

            it { is_expected.to compile.and_raise_error(%r{parameter 'content' expects}) }
          end

          context 'specifying both source and content' do
            let(:params) { { content: 'foo', source: 'puppet:///data/mycert.crt' } }

            it { is_expected.to compile.and_raise_error(%r{You must not specify both \$source and \$content}) }
          end

          context 'specifying neither source nor content' do
            let(:params) { {} }

            it { is_expected.to compile.and_raise_error(%r{You must specify either \$source or \$content}) }
          end
        end

        context 'ca cert' do
          case facts[:os]['family']
          when 'RedHat'
            file = '/etc/pki/ca-trust/source/anchors/mycert.crt'
            source = 'puppet:///data/mycert.crt'
          when 'Debian'
            file = '/usr/local/share/ca-certificates/mycert.crt'
            source = 'puppet:///data/mycert.crt'
          when 'Suse'
            if facts[:operatingsystem] == 'SLES'
              if facts[:operatingsystemmajrelease] == '11'
                file = '/etc/ssl/certs/mycert.pem'
                source = 'puppet:///data/mycert.pem'
              else
                file = '/etc/pki/trust/anchors/mycert.crt'
                source = 'puppet:///data/mycert.crt'
              end
            else
              file = '/etc/pki/trust/anchors/mycert.crt'
              source = 'puppet:///data/mycert.crt'
            end
          end

          let(:params) { { source: source } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file(file).that_notifies('Exec[update_system_certs]') }
        end
      end
    end
  end
end
