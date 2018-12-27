# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent
class ca_sso_web_agent (
  #Hash $apache_conf,
  String $install_dir,
  String $install_source,
  Array  $policy_servers,
  Array  $prereq_packages,
  String $properties_file,
  Enum['COMPAT', 'ONLY'] $registration_fips_mode,
  String $registration_host_config_object,
  String $registration_hostname,
  String $registration_password,
  String $registration_policy_server_ip,
  String $registration_username,
  String $temp_location,
  String $version,

  # Variables for WebAgent.conf template
  String $agent_config_object,
  Boolean $enable_local_config,
  Boolean $enable_web_agent,
  String $locale,
  String $server_path,
  #
  # Variables for LocalConfig.conf template
  Boolean $enable_log_file,
  Boolean $enable_trace_file,
  String $log_file_size,
  String $trace_file_size,
  #
  # Variables for WebAgentTrace.conf template
  String $trace_log_components,
  String $trace_log_data,
  
) {

  $configured_policy_servers = $::facts['ca_sso_web_agent_policy_servers']
  $installed_version         = $::facts['ca_sso_web_agent_version']
  $load_plugin               = "${install_dir}/bin/libHttpPlugin.so"
  $log_file                  = "${install_dir}/log/WebAgent.log"
  $trace_file                = "${install_dir}/log/WebAgentTrace.log"

  #notify { "version specified: ${version} installed version: ${installed_version}": }

  if $installed_version {
    if $installed_version != $version {
      # Installed, but doesn't match the version specified in hiera
      notify { "Installed, but version mismatch": }
      contain ca_sso_web_agent::uninstall
      contain ca_sso_web_agent::preinstall
      contain ca_sso_web_agent::install
      contain ca_sso_web_agent::config
      contain ca_sso_web_agent::register
    }
    elsif $installed_version == $version {
      # Installed and versions match. Make sure config is in place.
      #notify { "Installed, and versions match": }
      contain ca_sso_web_agent::config
    }
  }
  else {
    #notify { "Installed version (${installed_version}) is NOT defined": }
    # Fresh installation
    contain ca_sso_web_agent::preinstall
    contain ca_sso_web_agent::install
    contain ca_sso_web_agent::config
    contain ca_sso_web_agent::register
  }

}
