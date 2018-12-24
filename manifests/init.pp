# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent
class ca_sso_web_agent (
  # @TODO: The install_dir path is hardcoded in the fact that grabs the version. Need to dynamically grab the path in the fact...
  String $install_dir,
  Array  $policy_servers,
  Array  $prereq_packages,
  String $properties_file,
  String $temp_location,
  String $version,

  # Variables for WebAgent.conf template
  String $agent_config_object,
  #String $agent_id_file,
  Boolean $enable_local_config,
  Boolean $enable_web_agent,
  #String $host_config_file,
  #String $load_plugin,
  #String $local_config_file,
  String $locale,
  String $server_path,
  #String $web_agent_config_file,
  #
  # Variables for LocalConfig.conf template
  Boolean $enable_log_file,
  Boolean $enable_trace_file,
  #String $log_file,
  String $log_file_size,
  #String $trace_config_file,
  #String $trace_file,
  String $trace_file_size,
  #
  # Variables for WebAgentTrace.conf template
  String $trace_log_components,
  String $trace_log_data,
  
) {

  $configured_policy_servers   = $::facts['ca_sso_web_agent_policy_servers']
  $host_config_file            = "${install_dir}/config/SmHost.conf"
  $installed_version           = $::facts['ca_sso_web_agent_version']
  $load_plugin                 = "${install_dir}/bin/libHttpPlugin.so"
  $local_config_file           = "${install_dir}/config/LocalConfig.conf"
  $log_file                    = "${install_dir}/log/WebAgent.log"
  $trace_config_file           = "${install_dir}/config/WebAgentTrace.conf"
  $trace_file                  = "${install_dir}/log/WebAgentTrace.log"
  $web_agent_config_file       = "${install_dir}/config/WebAgent.conf"


  if $version != $installed_version {
    contain ca_sso_web_agent::preinstall
    contain ca_sso_web_agent::install
    contain ca_sso_web_agent::config
  }
  #else {
    #notify { "VERSION MATCH!!! --> version ${version} = installed version ${installed_version}": }
    #notify { "VERSION MATCH!!!": }
  #}

  file { '/usr/local/bin/smreghost':
    ensure => link,
    target => "${install_dir}/bin/smreghost",
  }

  # WebAgent.conf
  file { $web_agent_config_file:
    ensure  => file,
#    mode    => $settings_file_mode,
#    owner   => $settings_file_owner,                                                                                                   
#    group   => $settings_file_group,
    content => template('ca_sso_web_agent/WebAgent.conf.erb'),
  }
  # LocalConfig.conf
  file { $local_config_file:
    ensure  => file,
#    mode    => $settings_file_mode,
#    owner   => $settings_file_owner,                                                                                                   
#    group   => $settings_file_group,
    content => template('ca_sso_web_agent/LocalConfig.conf.erb'),
  }
  # WebAgentTrace.conf
  file { $trace_config_file:
    ensure  => file,
#    mode    => $settings_file_mode,
#    owner   => $settings_file_owner,                                                                                                   
#    group   => $settings_file_group,
    content => template('ca_sso_web_agent/WebAgentTrace.conf.erb'),
  }

  $configured_policy_servers.each | String $configured_policy_server | {
    if ! ( $configured_policy_server in $policy_servers ) {
      # Configured policy server in SmHost.conf does not match desired policy server. Need to delete... 
      #notify { "DELETE from SmHost.conf ==> No match for ${configured_policy_server} in ${policy_servers}": }
      notify { "Deleting ${configured_policy_server} from SmHost.conf": }
      file_line { "SmHost.conf-${configured_policy_server}":
        ensure => absent,
        path   => "${install_dir}/config/SmHost.conf",
        line   => $configured_policy_server,
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
