# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent::uninstall
class ca_sso_web_agent::uninstall {

  $web_agent_root_dir        = $::facts['ca_sso_web_agent_install_dir']
  $web_agent_root_dir_parent = dirname($web_agent_root_dir)

  exec { 'Uninstall CA SSO Web Agent':
    command => 'ca-wa-uninstall.sh -i silent',
    path    => $web_agent_root_dir,
    user    => 'root',
    before  => File[$web_agent_root_dir_parent],
  }

  file { $web_agent_root_dir_parent:
    ensure  => absent,
    force   => true,
    recurse => true,
  }

}
