# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent::install
class ca_sso_web_agent::install {

  include ::ca_sso_web_agent
  # archive module is used to download packages
  include ::archive

  $install_dir      = $::ca_sso_web_agent::install_dir
  $install_source   = $::ca_sso_web_agent::install_source
  $installation_zip = basename($install_source)
  $properties_file  = 'ca-wa-installer.properties'
  $temp_location    = $::ca_sso_web_agent::temp_location
  $version          = $::ca_sso_web_agent::version

  file { $temp_location:
    ensure => directory,
  }

  file { "${temp_location}/${properties_file}":
    content => "USER_INSTALL_DIR=${install_dir}\n",
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

  exec {'Rename installation binary':
    command => "mv ${temp_location}/*.bin ${temp_location}/install.bin",
    path    => ['/bin', '/usr/bin',],
    user    => 'root',
    before  => Exec['Install CA SSO Web Agent'],
  }

  exec {'Install CA SSO Web Agent':
    command => "install.bin -f ${properties_file} -i silent",
    path    => $temp_location,
    user    => root,
    before  => Exec['Cleanup installation files'],
  }

  exec {'Cleanup installation files':
    command => "rm -rf ${temp_location}",
    path    => ['/bin', '/usr/bin',],
    user    => 'root',
  }

}
