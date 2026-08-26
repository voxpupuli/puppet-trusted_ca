# @summary Manage distribution's trusted certificates
#
# @param certificates_version
#   This can be set to `present` or `latest` or a specific version to choose the distribution specific package
# @param path Search path (`$PATH`) used to execute `$trusted_ca::update_command`
# @param install_path Location to install the trusted certificates
# @param update_command Command to rebuild the system-trusted certificates
# @param certfile_suffix Suffix of certificate files. Default is OS/Distribution dependent, i.e. `pem` or `crt`
# @param certs_package Package name of the distribution-specific trusted certificates. Default is OS/Distribution specific
#
# @example Installation
#   include trusted_ca
#
#   trusted_ca::ca { 'example.org.local':
#     source => 'puppet:///data/ssl/example.com.pem',
#   }
#
# @author Justin Lambert <mailto:jlambert@eml.cc>
#
class trusted_ca (
  String $certificates_version = 'installed',
  Variant[Array[String], String] $path = $trusted_ca::params::path,
  Stdlib::Absolutepath $install_path = $trusted_ca::params::install_path,
  String $update_command = $trusted_ca::params::update_command,
  String $certfile_suffix = $trusted_ca::params::certfile_suffix,
  String $certs_package = $trusted_ca::params::certs_package,
) inherits trusted_ca::params {
  stdlib::ensure_packages([$certs_package], { ensure => $certificates_version })

  exec { 'update_system_certs':
    command     => $update_command,
    path        => $path,
    logoutput   => on_failure,
    refreshonly => true,
  }
}
