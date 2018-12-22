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

}
