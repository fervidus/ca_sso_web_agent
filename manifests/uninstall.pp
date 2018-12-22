# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent::uninstall
class ca_sso_web_agent::uninstall {

  $install_dir        = $::ca_sso_web_agent::install_dir
  $install_dir_parent = dirname($install_dir)

  exec { 'Uninstall CA SSO Web Agent':
    command => 'ca-wa-uninstall.sh -i silent',
    path    => $install_dir,
    user    => 'root',
    before  => File[$install_dir_parent],
  }

  file { $install_dir_parent:
    ensure  => absent,
    force   => true,
    recurse => true,
  }

# @TODO: There will also need to be cleanup of apache config, etc...
  file_line { 'etc-sysconfig-httpd-NETE_WA_ROOT':
    ensure => absent,
    path   => '/etc/sysconfig/httpd',
    line   => "NETE_WA_ROOT=${install_dir}",
  }
  file_line { 'etc-sysconfig-httpd-NETE_WA_PATH':
    ensure => absent,
    path   => '/etc/sysconfig/httpd',
    line   => 'NETE_WA_PATH=${NETE_WA_ROOT}/bin',
  }
  file_line { 'etc-sysconfig-httpd-CAPKIHOME':
    ensure => absent,
    path   => '/etc/sysconfig/httpd',
    line   => "CAPKIHOME=${install_dir}/CAPKI",
  }
  file_line { 'etc-sysconfig-httpd-LD_LIBRARY_PATH':
    ensure => absent,
    path   => '/etc/sysconfig/httpd',
    line   => 'LD_LIBRARY_PATH=${NETE_WA_ROOT}/bin:${NETE_WA_ROOT}/bin/thirdparty:${LD_LIBRARY_PATH}',
  }
  file_line { 'etc-sysconfig-httpd-PATH':
    ensure => absent,
    path   => '/etc/sysconfig/httpd',
    line   => 'PATH=${NETE_WA_PATH}:${PATH}',
  }

}
