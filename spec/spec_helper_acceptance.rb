require 'beaker-puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    install_module_on(hosts)
    install_module_dependencies_on(hosts)
    install_module_from_forge_on(hosts, 'puppetlabs/apache', '>= 0')
    install_module_from_forge_on(hosts, 'puppetlabs/java', '>= 0')
    hosts.each do |host|
      # testing dependencies
      scp_to(host, File.expand_path(File.join(File.dirname(__FILE__), 'acceptance', 'helpers', 'SSLPoke.class')), '/root/SSLPoke.class')
      scp_to(host, File.expand_path(File.join(File.dirname(__FILE__), 'acceptance', 'helpers', 'gen_cert.sh')), '/root/gen_cert.sh')
      shell('chmod a+x /root/gen_cert.sh')
      shell('/root/gen_cert.sh')
    end
  end
end
