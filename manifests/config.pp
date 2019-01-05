# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent::config
class ca_sso_web_agent::config {

  include ::apache
  include ::ca_sso_web_agent

  $install_dir               = $::ca_sso_web_agent::install_dir
  $agent_config_object       = $::ca_sso_web_agent::agent_config_object
  $configured_policy_servers = $::facts['ca_sso_web_agent_policy_servers']
  $enable_local_config       = $::ca_sso_web_agent::enable_local_config
  $enable_log_file           = $::ca_sso_web_agent::enable_log_file
  $enable_trace_file         = $::ca_sso_web_agent::enable_trace_file
  $enable_web_agent          = $::ca_sso_web_agent::enable_web_agent
  $host_config_file          = "${install_dir}/config/SmHost.conf"
  $load_plugin               = "${install_dir}/bin/libHttpPlugin.so"
  $local_config_file         = "${install_dir}/config/LocalConfig.conf"
  $locale                    = $::ca_sso_web_agent::locale
  $log_file                  = "${install_dir}/log/WebAgent.log"
  $log_file_size             = $::ca_sso_web_agent::log_file_size
  $policy_servers            = $::ca_sso_web_agent::policy_servers
  $server_path               = $::ca_sso_web_agent::server_path
  $trace_config_file         = "${install_dir}/config/WebAgentTrace.conf"
  $trace_file                = "${install_dir}/log/WebAgentTrace.log"
  $trace_file_size           = $::ca_sso_web_agent::trace_file_size
  $trace_log_components      = $::ca_sso_web_agent::trace_log_components
  $trace_log_data            = $::ca_sso_web_agent::trace_log_data
  $web_agent_config_file     = "${install_dir}/config/WebAgent.conf"


  # /etc/httpd/conf.d/35-ca_sso_web_agent.conf
  $apache_conf_str = "PassEnv CAPKIHOME\nLoadModule sm_module ${install_dir}/bin/libmod_sm24.so\nSmInitFile ${install_dir}/config/WebAgent.conf\n"
  apache::custom_config { 'ca_sso_web_agent':
    content       => $apache_conf_str,
    priority      => '35',
    verify_config => false,
  }
  file_line { 'etc-sysconfig-httpd-NETE_WA_ROOT':
    ensure => present,
    path   => '/etc/sysconfig/httpd',
    line   => "NETE_WA_ROOT=${install_dir}",
    match  => '^NETE_WA_ROOT=',
  }
  file_line { 'etc-sysconfig-httpd-NETE_WA_PATH':
    ensure => present,
    path   => '/etc/sysconfig/httpd',
    line   => "NETE_WA_PATH=${install_dir}/bin",
    match  => '^NETE_WA_PATH=',
  }
  file_line { 'etc-sysconfig-httpd-CAPKIHOME':
    ensure => present,
    path   => '/etc/sysconfig/httpd',
    line   => "CAPKIHOME=${install_dir}/CAPKI",
    match  => '^CAPKIHOME=',
  }
  file_line { 'etc-sysconfig-httpd-LD_LIBRARY_PATH':
    ensure => present,
    path   => '/etc/sysconfig/httpd',
    line   => "LD_LIBRARY_PATH=${install_dir}/bin:${install_dir}/bin/thirdparty:\${LD_LIBRARY_PATH}",
    match  => '^LD_LIBRARY_PATH=',
  }
  file_line { 'etc-sysconfig-httpd-PATH':
    ensure => present,
    path   => '/etc/sysconfig/httpd',
    line   => "PATH=${install_dir}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin",
    match  => '^PATH=',
  }

  file { '/usr/local/bin/smreghost':
    ensure => link,
    target => "${install_dir}/bin/smreghost",
  }
  file { $host_config_file:
    owner  => 'apache',
  }
  file { $log_file:
    owner  => 'apache',
  }
  file { $trace_file:
    owner  => 'apache',
  }

  # WebAgent.conf
  file { $web_agent_config_file:
    ensure  => file,
    content => epp('ca_sso_web_agent/WebAgent.conf.epp'),
  }
  # LocalConfig.conf
  file { $local_config_file:
    ensure  => file,
    content => epp('ca_sso_web_agent/LocalConfig.conf.epp'),
  }
  # WebAgentTrace.conf
  file { $trace_config_file:
    ensure  => file,
    content => epp('ca_sso_web_agent/WebAgentTrace.conf.epp'),
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
