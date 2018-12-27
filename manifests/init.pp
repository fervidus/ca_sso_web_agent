# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent
class ca_sso_web_agent (
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

  $installed_version  = $::facts['ca_sso_web_agent_version']
  $web_agent_root_dir = $::facts['ca_sso_web_agent_install_dir']

  if $installed_version {
    if ( $installed_version != $version ) or ( $web_agent_root_dir != $install_dir ) {
      # Installed, but either the version or installation directory has changed.
      notify { "Installed, but version mismatch or installation directory has changed!": }
      contain ca_sso_web_agent::uninstall
      contain ca_sso_web_agent::preinstall
      contain ca_sso_web_agent::install
      # Call register class prior to config class or SmHost.conf file will be overwritten by registration.
      contain ca_sso_web_agent::register
      contain ca_sso_web_agent::config
    }
    elsif $installed_version == $version {
      # Installed and versions match. Ensure desired config is in place.
      contain ca_sso_web_agent::config
    }
  }
  else {
    # $installed_version is not defined. Proceed with fresh installation.
    contain ca_sso_web_agent::preinstall
    contain ca_sso_web_agent::install
    # Call register class prior to config class or SmHost.conf file will be overwritten by registration.
    contain ca_sso_web_agent::register
    contain ca_sso_web_agent::config
  }

}
