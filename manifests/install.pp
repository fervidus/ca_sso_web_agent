# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent::install
class ca_sso_web_agent::install {
 
  # archive module is used to download packages
  include ::archive

  $install_dir     = $::ca_sso_web_agent::install_dir
  $install_source  = $::ca_sso_web_agent::install_source
  $properties_file = $::ca_sso_web_agent::properties_file
  $temp_location   = $::ca_sso_web_agent::temp_location
  $version         = $::ca_sso_web_agent::version

  file { $temp_location:
    ensure => directory,
  }

  file { "${temp_location}/${properties_file}":
    content => "USER_INSTALL_DIR=${install_dir}\n",
  }

# Move this to profile::ca_sso_web_agent ???
  case $version {
    '12.52.109.2620': { 
      $installation_binary = 'ca-wa-12.52-sp01-cr09-linux-x86-64.bin'
      $installation_zip    = 'ca-wa-12.52-sp01-cr09a-linux-x86-64.zip'
    }
    default: { fail("Unsupported CA SSO Web Agent version ${version}") }
  }

  # Get installation binary
  archive { "${temp_location}/${installation_zip}":
    ensure       => present,
    source       => $install_source,
    extract      => true,
    extract_path => $temp_location,
    creates      => "${temp_location}/${installation_zip}",
    cleanup      => true,
  }

  exec {'Install CA SSO Web Agent':
    command => "${installation_binary} -f ${properties_file} -i silent",
    path    => $temp_location,
    user    => root,
  }
  exec {'Remove temp install files':
    command => "rm -rf ${temp_location}",
    path    => ['/bin', '/usr/bin',],
    user    => 'root',
  }

}
