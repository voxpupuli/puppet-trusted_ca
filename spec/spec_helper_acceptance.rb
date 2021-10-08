require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_module_from_forge_on(host, 'puppetlabs/apache', '>= 0 < 7.0.0')
  install_module_from_forge_on(host, 'puppetlabs/java', '>= 0 < 8.0.0')

  # testing dependencies
  scp_to(host, File.join(__dir__, 'acceptance', 'helpers', 'SSLPoke.class'), '/root/SSLPoke.class')
  scp_to(host, File.join(__dir__, 'acceptance', 'helpers', 'gen_cert.sh'), '/root/gen_cert.sh')
  on host, 'chmod a+x /root/gen_cert.sh'
  on host, '/root/gen_cert.sh'
end
