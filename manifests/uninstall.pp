# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent::uninstall
class ca_sso_web_agent::uninstall {

  #$install_dir        = $::ca_sso_web_agent::install_dir
  $web_agent_root_dir = $::facts['ca_sso_web_agent_install_dir']
  #$install_dir_parent = dirname($web_agent_root_dir)
  $web_agent_root_dir_parent = dirname($web_agent_root_dir)

  exec { 'Uninstall CA SSO Web Agent':
    command => 'ca-wa-uninstall.sh -i silent',
    #path    => $install_dir,
    path    => $web_agent_root_dir,
    user    => 'root',
    before  => File[$web_agent_root_dir_parent],
  }

  #file { $install_dir_parent:
  file { $web_agent_root_dir_parent:
    ensure  => absent,
    force   => true,
    recurse => true,
  }

  notify { "The current version of this module requires two puppet agent runs to perform an uninstall/install cycle. Please run the puppet agent again to perform installation.": }

  class { '::ca_sso_web_agent::config':
    uninstall     => true,
    uninstall_dir => $web_agent_root_dir,
  }

}
