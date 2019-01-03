# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent
#
# @param installation_binary
#   The name of the binary the installer uses to install the web agent.
# @param installation_zip
#   The name of the zip file containing the installation binary.
# @param install_dir
#   The path to install the web agent.
# @param install_source
#   The http(s) or file path to the installation zip.
# @param policy_servers
#   The policy servers to add to SmHost.conf.
# @param prereq_packages
#   Prerequisites packages to install prior to installation.
# @param properties_file
#   The name of the properties file to use for unattended installation.
# @param temp_location
#   The path to the temporary location where the installation files are extracted.
# @param version
#   The version of the web agent to install. If the version specified does not match the installed version, the installed version will be
#   removed and replaced with the version specified through this parameter.
#   ##### Registration (smreghost) parameters:
#   https://docops.ca.com/ca-single-sign-on/12-52-sp1/en/administrating/register-a-trusted-host-using-the-smreghost-registration-tool
# @param registration_fips_mode
#   Specifies one of the following FIPS modes:
#
#   COMPAT--Specifies non-FIPS mode, which lets the Policy Server and the Agents read and write information using the existing CA Single
#   Sign-On encryption algorithms. If your organization does not require the use of FIPS-compliant algorithms, the Policy Server and the
#   Agents can operate in non-FIPS mode without further configuration.
#
#   ONLY--Specifies full-FIPS mode, which requires that the Policy Server and Web Agents read and write information using only FIPS 140-2
#   algorithms.
# @param registration_host_config_object
#   The name of the Host Configuration Object configured at the Policy Server. This object must exist on the Policy Server before you can
#   register a trusted host.
# @param registration_hostname
#   The name of the host to be registered. This can be any name that identifies the host, but it must be unique. After registration, this
#   name is placed in the Trusted Host list in the Administrative UI.
# @param registration_password
#   The password of the Administrator who is allowed to register a trusted host.
# @param registration_policy_server_ip
#   The IP address of the Policy Server where you are registering this host.
# @param registration_username
#   The name of the CA Single Sign-On administrator with the rights to register a trusted host.
#
#   ##### WebAgent.conf parameters:
# @param agent_config_object
#   WebAgent.conf
# @param enable_local_config
#   WebAgent.conf
# @param enable_web_agent
#   WebAgent.conf
# @param locale
#   WebAgent.conf
# @param server_path
#   WebAgent.conf
#
#   ##### LocalConfig.conf parameters:
# @param enable_log_file
#   LocalConfig.conf
# @param enable_trace_file
#   LocalConfig.conf
# @param log_file_size
#   LocalConfig.conf
# @param trace_file_size
#   LocalConfig.conf
#
#   ##### WebAgentTrace.conf parameters:
# @param trace_log_components
#   WebAgentTrace.conf
# @param trace_log_data
#   WebAgentTrace.conf
class ca_sso_web_agent (
  String $installation_binary,
  String $installation_zip,
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
  Optional[String] $temp_location,
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
      notify { 'Installed, but version mismatch or installation directory has changed!': }
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
