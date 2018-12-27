# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent::config
class ca_sso_web_agent::config (
  Boolean $uninstall = false,
  Optional[String] $uninstall_dir = '',

) {

#  $install_dir               = $::ca_sso_web_agent::install_dir
  $configured_policy_servers = $::ca_sso_web_agent::configured_policy_servers
#  $local_config_file         = "${install_dir}/config/LocalConfig.conf"
  $policy_servers            = $::ca_sso_web_agent::policy_servers
#  $trace_config_file         = "${install_dir}/config/WebAgentTrace.conf"
#  $web_agent_config_file     = "${install_dir}/config/WebAgent.conf"

  if $uninstall {
    $ensure         = absent
    $smreghost_link = absent

    $install_dir               = $uninstall_dir
    $host_config_file          = "${install_dir}/config/SmHost.conf"
    $local_config_file         = "${install_dir}/config/LocalConfig.conf"
    $trace_config_file         = "${install_dir}/config/WebAgentTrace.conf"
    $web_agent_config_file     = "${install_dir}/config/WebAgent.conf"
  }
  else {
    $ensure         = present
    $smreghost_link = link

    $install_dir               = $::ca_sso_web_agent::install_dir
    $host_config_file          = "${install_dir}/config/SmHost.conf"
    $local_config_file         = "${install_dir}/config/LocalConfig.conf"
    $trace_config_file         = "${install_dir}/config/WebAgentTrace.conf"
    $web_agent_config_file     = "${install_dir}/config/WebAgent.conf"

    # /etc/httpd/conf.d/35-ca_sso_web_agent.conf
    $apache_conf_str = "PassEnv CAPKIHOME\nLoadModule sm_module ${install_dir}/bin/libmod_sm24.so\nSmInitFile ${install_dir}/config/WebAgent.conf\n"
    apache::custom_config { 'ca_sso_web_agent':
      content       => $apache_conf_str,
      priority      => '35',
      verify_config => false,
    }
  }
  
  file_line { 'etc-sysconfig-httpd-NETE_WA_ROOT':
    ensure => $ensure,
    path   => '/etc/sysconfig/httpd',
    line   => "NETE_WA_ROOT=${install_dir}",
    match  => '^NETE_WA_ROOT=',
  }
  file_line { 'etc-sysconfig-httpd-NETE_WA_PATH':
    ensure => $ensure,
    path   => '/etc/sysconfig/httpd',
    line   => "NETE_WA_PATH=${install_dir}/bin",
    match  => '^NETE_WA_PATH=',
  }
  file_line { 'etc-sysconfig-httpd-CAPKIHOME':
    ensure => $ensure,
    path   => '/etc/sysconfig/httpd',
    line   => "CAPKIHOME=${install_dir}/CAPKI",
    match  => '^CAPKIHOME=',
  }
  file_line { 'etc-sysconfig-httpd-LD_LIBRARY_PATH':
    ensure => $ensure,
    path   => '/etc/sysconfig/httpd',
    line   => "LD_LIBRARY_PATH=${install_dir}/bin:${install_dir}/bin/thirdparty:\${LD_LIBRARY_PATH}",
    match  => '^LD_LIBRARY_PATH=',
  }
  file_line { 'etc-sysconfig-httpd-PATH':
    ensure => $ensure,
    path   => '/etc/sysconfig/httpd',
    line   => "PATH=${install_dir}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin",
    match  => '^PATH=',
  }

  file { '/usr/local/bin/smreghost':
    ensure => $smreghost_link,
    target => "${install_dir}/bin/smreghost",
  }
  file { "${host_config_file}":
#    ensure => $ensure,
    owner  => 'apache',
  }

  # WebAgent.conf
  file { $web_agent_config_file:
    #ensure  => file,
    ensure  => $ensure,
    content => template('ca_sso_web_agent/WebAgent.conf.erb'),
  }
  # LocalConfig.conf
  file { $local_config_file:
    #ensure  => file,
    ensure  => $ensure,
    content => template('ca_sso_web_agent/LocalConfig.conf.erb'),
  }
  # WebAgentTrace.conf
  file { $trace_config_file:
    #ensure  => file,
    ensure  => $ensure,
    content => template('ca_sso_web_agent/WebAgentTrace.conf.erb'),
  }

  if $configured_policy_servers {
    $configured_policy_servers.each | String $configured_policy_server | {
      if ! ( $configured_policy_server in $policy_servers ) {
        # Configured policy server in SmHost.conf does not match desired policy server. Need to delete... 
        notify { "Deleting ${configured_policy_server} from SmHost.conf": }
        file_line { "SmHost.conf-${configured_policy_server}":
          ensure => absent,
          path   => "${install_dir}/config/SmHost.conf",
          line   => $configured_policy_server,
        }
      }
    }
  }
  $policy_servers.each | String $policy_server | {
    if ! ( $policy_server in $configured_policy_servers ) {
      # Policy server is not present in SmHost.conf. Need to add... 
      notify { "Adding ${policy_server} to ${install_dir}/config/SmHost.conf": }
      file_line { "SmHost.conf-${policy_server}":
        ensure => present,
        after  => '#Add additional bootstrap policy servers here for fault tolerance.',
        path   => "${install_dir}/config/SmHost.conf",
        line   => $policy_server,
      }
    }
  }

}
