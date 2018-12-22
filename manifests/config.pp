# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent::config
class ca_sso_web_agent::config {
  
  $install_dir = $::ca_sso_web_agent::install_dir

  file_line { 'etc-sysconfig-httpd-NETE_WA_ROOT':
    path => '/etc/sysconfig/httpd',
    line => "NETE_WA_ROOT=${install_dir}",
  }
  file_line { 'etc-sysconfig-httpd-NETE_WA_PATH':
    path => '/etc/sysconfig/httpd',
    line => 'NETE_WA_PATH=${install_dir}/bin',
  }
  file_line { 'etc-sysconfig-httpd-CAPKIHOME':
    path => '/etc/sysconfig/httpd',
    line => "CAPKIHOME=${install_dir}/CAPKI",
  }
  file_line { 'etc-sysconfig-httpd-LD_LIBRARY_PATH':
    path => '/etc/sysconfig/httpd',
    line => 'LD_LIBRARY_PATH=${install_dir}/bin:${install_dir}/bin/thirdparty:${LD_LIBRARY_PATH}',
  }
  file_line { 'etc-sysconfig-httpd-PATH':
    path => '/etc/sysconfig/httpd',
    line => 'PATH=${install_dir}:${PATH}',
  }

}
