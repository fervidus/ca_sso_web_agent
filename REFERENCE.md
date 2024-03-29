# Reference
<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

**Classes**

* [`ca_sso_web_agent`](#ca_sso_web_agent): Main class, includes all other classes.

## Classes

### ca_sso_web_agent

Installs, configures, and registers a CA SSO Web Agent.

#### Examples

##### 

```puppet
include ca_sso_web_agent
```

#### Parameters

The following parameters are available in the `ca_sso_web_agent` class.

##### `install_dir`

Data type: `String`

The path to install the web agent. Default value: /opt/ca/webagent

##### `install_source`

Data type: `String`

The http(s) or file path to the installation zip. Default value: undef.

##### `policy_servers`

Data type: `Array`

The policy servers to add to SmHost.conf. Default value: undef.

##### `prereq_packages`

Data type: `Array`

Prerequisites packages to install prior to installation.
Default value: ['binutils', 'gcc', 'keyutils-libs.i686', 'libidn.i686', 'libidn.so.11', 'libstdc++.i686', 'libXext.i686',
'libXrender.i686', 'libXtst.i686', 'ncurses-libs.i686', 'unzip']

##### `temp_location`

Data type: `String`

The path to the temporary location where the installation files are extracted. Default value: /tmp/ca_sso_web_agent_install

##### `version`

Data type: `String`

The version of the web agent to install. If the version specified does not match the installed version, the installed version will be
removed and replaced with the version specified through this parameter. Default value: undef.
##### Registration (smreghost) parameters:
https://docops.ca.com/ca-single-sign-on/12-52-sp1/en/administrating/register-a-trusted-host-using-the-smreghost-registration-tool

##### `register_trusted_host`

Data type: `Boolean`

Whether or not to register this host or just perform installation and configuration. This should only be set to false when running
acceptance tests. Default value: true

##### `registration_fips_mode`

Data type: `Enum['COMPAT', 'ONLY']`

Specifies one of the following FIPS modes. Default value: COMPAT

COMPAT--Specifies non-FIPS mode, which lets the Policy Server and the Agents read and write information using the existing CA Single
Sign-On encryption algorithms. If your organization does not require the use of FIPS-compliant algorithms, the Policy Server and the
Agents can operate in non-FIPS mode without further configuration.

ONLY--Specifies full-FIPS mode, which requires that the Policy Server and Web Agents read and write information using only FIPS 140-2
algorithms.

##### `registration_host_config_object`

Data type: `String`

The name of the Host Configuration Object configured at the Policy Server. This object must exist on the Policy Server before you can
register a trusted host. Default value: undef.

##### `registration_hostname`

Data type: `String`

The name of the host to be registered. This can be any name that identifies the host, but it must be unique. After registration, this
name is placed in the Trusted Host list in the Administrative UI. Default value: undef.

##### `registration_password`

Data type: `String`

The password of the Administrator who is allowed to register a trusted host. Default value: undef.

##### `registration_policy_server_ip`

Data type: `String`

The IP address of the Policy Server where you are registering this host. Default value: undef.

##### `registration_username`

Data type: `String`

The name of the CA Single Sign-On administrator with the rights to register a trusted host. Default value: undef.

##### WebAgent.conf parameters:
https://docops.ca.com/ca-single-sign-on/12-52-sp1/en/configuring/web-agent-configuration/list-of-agent-configuration-parameters

##### `agent_config_object`

Data type: `String`

Determines which Agent Configuration Object that the agent should use. Default value: undef.

##### `enable_local_config`

Data type: `Boolean`

Enables or disables the LocalConfig.conf file, where most of Agent configuration settings reside. Default value: false

##### `enable_web_agent`

Data type: `Boolean`

Specifies whether an agent actively protects resources. Default value: false

##### `locale`

Data type: `String`

Specifies the language in which HTML pages for login, basic password services, and error responses are displayed. Default value: en-US

##### `server_path`

Data type: `String`

Identifies the web server directory to the Agent. Default value: /etc/httpd

##### LocalConfig.conf parameters:

##### `enable_log_file`

Data type: `Boolean`

Turns Error (High Level) Logging on or off. Default value: false

##### `enable_trace_file`

Data type: `Boolean`

Specifies whether the agent writes a trace (Low Level) file. Default value: false

##### `log_file_size`

Data type: `String`

Specifies the size limit of the log file in megabytes. Default value: 0 (no rollover)

##### `trace_file_size`

Data type: `String`

Specifies (in megabytes) the maximum size of a trace file. Default value: 0 (a new log file is not created)

##### WebAgentTrace.conf parameters:

##### `trace_log_components`

Data type: `String`

Trace log components to monitor. Default value: AgentFramework, HTTPAgent, WebAgent

##### `trace_log_data`

Data type: `String`

Trace message data fields. Default value: Date, Time, Pid, Tid, SrcFile, Function, TransactionID, IPAddr, IPPort, AgentName, Resource,
User, Message

