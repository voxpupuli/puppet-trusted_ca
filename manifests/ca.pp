# @summary Install individual root CAs
#
# @param source
#   Path to the certificate PEM.
#   Must specify either content or source.
#
# @param content
#   Content of certificate in PEM format.
#   Must specify either content or source.
#
# @param install_path
#   Location to install trusted certificates
#
# @param certfile_suffix
#   The suffix of the certificate to install.
#   Default is OS/Distribution dependent, i.e. 'crt' or 'pem'
#
# @example Installation
#   include trusted_ca
#
#   trusted_ca::ca { 'example.org.local':
#     source => 'puppet:///data/ssl/example.com.pem',
#   }
#
#   trusted_ca::ca { 'example.net.local':
#     content  => lookup('example-net-x509'),
#   }
#
# @author Justin Lambert <mailto:jlambert@eml.cc>
#
define trusted_ca::ca (
  Optional[String] $source = undef,
  Optional[Pattern['^[A-Za-z0-9+/\n=-]+$']] $content = undef,
  Stdlib::Absolutepath $install_path = $trusted_ca::install_path,
  String $certfile_suffix = $trusted_ca::certfile_suffix,
) {
  if ! defined(Class['trusted_ca']) {
    fail('You must include the trusted_ca base class before using any trusted_ca defined resources')
  }

  if $source and $content {
    fail('You must not specify both $source and $content for trusted_ca defined resources')
  } elsif !$source and !$content {
    fail('You must specify either $source or $content for trusted_ca defined resources')
  }

  if $name =~ Pattern["\\.${certfile_suffix}$"] {
    $_name = $name
  } else {
    $_name = "${name}.${certfile_suffix}"
  }

  file { "${install_path}/${_name}":
    ensure       => 'file',
    content      => $content,
    source       => $source,
    notify       => Exec['update_system_certs'],
    mode         => '0644',
    owner        => 'root',
    group        => 'root',
    validate_cmd => 'openssl x509 -in % -noout',
  }
}
