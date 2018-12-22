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
  String $agent_id_file,
  Boolean $enable_local_config,
  Optional[String] $enable_web_agent,
  String $host_config_file,
  String $load_plugin,
  String $local_config_file,
  Optional[String] $locale,
  String $server_path,
  
) {

  $installed_version = $::facts['ca_sso_web_agent_version']

  if $version != $installed_version {
    contain ca_sso_web_agent::preinstall
    contain ca_sso_web_agent::install
    contain ca_sso_web_agent::config
  }
  #else {
    #notify { "VERSION MATCH!!! --> version ${version} = installed version ${installed_version}": }
    #notify { "VERSION MATCH!!!": }
  #}
  file { "${server_path}/WebAgent.conf":
    ensure  => file,
#    mode    => $settings_file_mode,
#    owner   => $settings_file_owner,                                                                                                   
#    group   => $settings_file_group,
    content => template('ca_sso_web_agent/WebAgent.conf.erb'),
  }

}
