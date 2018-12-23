# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent
class ca_sso_web_agent (
  # @TODO: The install_dir path is hardcoded in the fact that grabs the version. Need to dynamically grab the path in the fact...
  String $install_dir,
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

}
