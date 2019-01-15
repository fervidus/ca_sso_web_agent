# Installs, configures, and registers a CA SSO Web Agent.
#
# @summary Main class, includes all other classes.
#
# @example
#   include ca_sso_web_agent
#
# @param installation_binary
#   The name of the binary the installer uses to install the web agent. Default value: undef.
# @param installation_zip
#   The name of the zip file containing the installation binary. Default value: undef.
# @param install_dir
#   The path to install the web agent. Default value: /opt/ca/webagent
# @param install_source
#   The http(s) or file path to the installation zip. Default value: undef.
# @param policy_servers
#   The policy servers to add to SmHost.conf. Default value: undef.
# @param prereq_packages
#   Prerequisites packages to install prior to installation.
#   Default value: ['binutils', 'gcc', 'keyutils-libs.i686', 'libidn.i686', 'libidn.so.11', 'libstdc++.i686', 'libXext.i686',
#   'libXrender.i686', 'libXtst.i686', 'ncurses-libs.i686', 'unzip']
# @param temp_location
#   The path to the temporary location where the installation files are extracted. Default value: /tmp/ca_sso_web_agent_install
# @param version
#   The version of the web agent to install. If the version specified does not match the installed version, the installed version will be
#   removed and replaced with the version specified through this parameter. Default value: undef.
#   ##### Registration (smreghost) parameters:
#   https://docops.ca.com/ca-single-sign-on/12-52-sp1/en/administrating/register-a-trusted-host-using-the-smreghost-registration-tool
# @param register_trusted_host
#   Whether or not to register this host or just perform installation and configuration. This should only be set to false when running
#   acceptance tests. Default value: true
# @param registration_fips_mode
#   Specifies one of the following FIPS modes. Default value: COMPAT
#
#   COMPAT--Specifies non-FIPS mode, which lets the Policy Server and the Agents read and write information using the existing CA Single
#   Sign-On encryption algorithms. If your organization does not require the use of FIPS-compliant algorithms, the Policy Server and the
#   Agents can operate in non-FIPS mode without further configuration.
#
#   ONLY--Specifies full-FIPS mode, which requires that the Policy Server and Web Agents read and write information using only FIPS 140-2
#   algorithms.
# @param registration_host_config_object
#   The name of the Host Configuration Object configured at the Policy Server. This object must exist on the Policy Server before you can
#   register a trusted host. Default value: undef.
# @param registration_hostname
#   The name of the host to be registered. This can be any name that identifies the host, but it must be unique. After registration, this
#   name is placed in the Trusted Host list in the Administrative UI. Default value: undef.
# @param registration_password
#   The password of the Administrator who is allowed to register a trusted host. Default value: undef.
# @param registration_policy_server_ip
#   The IP address of the Policy Server where you are registering this host. Default value: undef.
# @param registration_username
#   The name of the CA Single Sign-On administrator with the rights to register a trusted host. Default value: undef.
#
#   ##### WebAgent.conf parameters:
#   https://docops.ca.com/ca-single-sign-on/12-52-sp1/en/configuring/web-agent-configuration/list-of-agent-configuration-parameters
# @param agent_config_object
#   Determines which Agent Configuration Object that the agent should use. Default value: undef.
# @param enable_local_config
#   Enables or disables the LocalConfig.conf file, where most of Agent configuration settings reside. Default value: false
# @param enable_web_agent
#   Specifies whether an agent actively protects resources. Default value: false
# @param locale
#   Specifies the language in which HTML pages for login, basic password services, and error responses are displayed. Default value: en-US
# @param server_path
#   Identifies the web server directory to the Agent. Default value: /etc/httpd
#
#   ##### LocalConfig.conf parameters:
# @param enable_log_file
#   Turns Error (High Level) Logging on or off. Default value: false
# @param enable_trace_file
#   Specifies whether the agent writes a trace (Low Level) file. Default value: false
# @param log_file_size
#   Specifies the size limit of the log file in megabytes. Default value: 0 (no rollover)
# @param trace_file_size
#   Specifies (in megabytes) the maximum size of a trace file. Default value: 0 (a new log file is not created)
#
#   ##### WebAgentTrace.conf parameters:
# @param trace_log_components
#   Trace log components to monitor. Default value: AgentFramework, HTTPAgent, WebAgent
# @param trace_log_data
#   Trace message data fields. Default value: Date, Time, Pid, Tid, SrcFile, Function, TransactionID, IPAddr, IPPort, AgentName, Resource,
#   User, Message
class ca_sso_web_agent (
  String $installation_binary,
  String $installation_zip,
  String $install_dir,
  String $install_source,
  Array  $policy_servers,
  Array  $prereq_packages,
  Enum['COMPAT', 'ONLY'] $registration_fips_mode,
  Boolean $register_trusted_host,
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
      notify { 'Installed, but version mismatch or installation directory has changed!': }
      contain ca_sso_web_agent::uninstall
      contain ca_sso_web_agent::preinstall
      contain ca_sso_web_agent::install
      # Call register class prior to config class or SmHost.conf file will be overwritten by registration.
      if $register_trusted_host {
        contain ca_sso_web_agent::register
      }
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
    if $register_trusted_host {
      contain ca_sso_web_agent::register
    }
    contain ca_sso_web_agent::config
  }

}
