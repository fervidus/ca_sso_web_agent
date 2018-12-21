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
  $properties_file = $::ca_sso_web_agent::properties_file
  $temp_location   = $::ca_sso_web_agent::temp_location
  $version         = $::ca_sso_web_agent::version

  file { $temp_location:
    ensure => 'directory',
  }

  file { "${temp_location}/${properties_file}":
    #content => "USER_INSTALL_DIR=${install_dir}\nUSER_SHORTCUTS=/root\n",
    content => "USER_INSTALL_DIR=${install_dir}\n",
  }

  case $version {
    '12.52.109.2620': { $installation_binary = 'ca-wa-12.52-sp01-cr09-linux-x86-64.bin' }
    default: { fail("Unsupported CA SSO Web Agent version ${version}") }
  }

  # Get installation binary
  # @TODO: Upload binary to artifactory and update code below
  archive { "${temp_location}/${installation_binary}":
    ensure  => present,
    source  => "/root/ca-wa-install/${installation_binary}",
    extract => false,
    creates => "${temp_location}/${installation_binary}",
    cleanup => false,
  }


#  @TODO: Only install if not already installed (check for custom fact, etc.... )
  exec {'Install CA SSO Web Agent':
    #command     => 'ca-wa-12.52-sp01-cr09-linux-x86-64.bin -f ca-wa-installer.properties -i silent',
    command     => "${installation_binary} -f ${properties_file} -i silent",
    path        => $temp_location,
    user        => root,
#    refreshonly => true,
  }
  #@TODO Cleanup temp dir after install
}
