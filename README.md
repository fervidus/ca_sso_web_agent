
# ca_sso_web_agent

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with ca_sso_web_agent](#setup)
    * [What ca_sso_web_agent affects](#what-ca_sso_web_agent-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ca_sso_web_agent](#beginning-with-ca_sso_web_agent)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - Parameter reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module installs, configures, and registers the CA SSO Web Agent.

## Setup

### What ca_sso_web_agent affects

This module will manage the entire installation and configuration of the CA SSO Web Agent. Manual modification to the configuration files is not supported, as this module will overwrite such changes. All changes must occur through this module.

### Setup Requirements

This module must be used in conjunction with the [puppetlabs/apache](https://forge.puppet.com/puppetlabs/apache) module.

### Beginning with ca_sso_web_agent

`include ca_sso_web_agent` is NOT enough to get you up and running as default values for items such as policy servers, registration parameters, etc. are not feasable. See the [Usage](#usage) section below for examples of using this module with sample hiera data.

## Usage

Below is a sample reverse proxy role using the Puppet roles and profiles method - https://puppet.com/docs/pe/2019.0/the_roles_and_profiles_method.html

```
class role::reverse_proxy {
  include ::profile
  include ::profile::apache
  include ::profile::ca_sso_web_agent

  Class['::profile']
  -> Class['::profile::apache']
  -> Class['::profile::ca_sso_web_agent']
}
```

Below is a sample ca_sso_web_agent profile module instantiating the ca_sso_web_agent component module:

```
class profile::ca_sso_web_agent (
  String $install_dir,
  String $install_source,
  Enum['COMPAT', 'ONLY'] $registration_fips_mode,
  String $registration_host_config_object,
  String $registration_hostname,
  String $registration_password,
  String $registration_policy_server_ip,
  String $registration_username,
  Array  $policy_servers,
  String $version,
  #
  # Parameters for WebAgent.conf template
  String $agent_config_object,
  Optional[Boolean] $enable_local_config = undef,
  Optional[Boolean] $enable_web_agent    = undef,
  Optional[String] $locale               = undef,
  Optional[String] $server_path          = undef,
  #
  # Parameters for LocalConfig.conf template
  Optional[Boolean] $enable_log_file     = undef,
  Optional[Boolean] $enable_trace_file   = undef,
  Optional[String] $log_file_size        = undef,
  Optional[String] $trace_file_size      = undef,
) {

  class { '::ca_sso_web_agent':
    # General params
    install_dir                     => $install_dir,
    install_source                  => $install_source,
    registration_fips_mode          => $registration_fips_mode,
    registration_host_config_object => $registration_host_config_object,
    registration_hostname           => $registration_hostname,
    registration_password           => $registration_password,
    registration_policy_server_ip   => $registration_policy_server_ip,
    registration_username           => $registration_username,
    version => $version,
    #
    # Parameters for WebAgent.conf template
    agent_config_object             => $agent_config_object,
    enable_local_config             => $enable_local_config,
    enable_web_agent                => $enable_web_agent,
    locale                          => $locale,
    policy_servers                  => $policy_servers,
    server_path                     => $server_path,
    #
    # Parameters for LocalConfig.conf template
    enable_log_file                 => $enable_log_file,
    enable_trace_file               => $enable_trace_file,
    log_file_size                   => $log_file_size,
    trace_file_size                 => $trace_file_size,
  }

}
```

Sample hiera data accompanying the above profile::ca_sso_web_agent module:

```
---
profile::ca_sso_web_agent::agent_config_object: 'my_proxy_conf'
profile::ca_sso_web_agent::enable_local_config: true
profile::ca_sso_web_agent::enable_log_file: true
profile::ca_sso_web_agent::enable_trace_file: true
profile::ca_sso_web_agent::enable_web_agent: true
profile::ca_sso_web_agent::install_dir: '/app/ca/webagent'
profile::ca_sso_web_agent::install_source: 'https://artifactory.example.com/artifactory/application-release-local/ca-wa-12.52-sp01-cr09a-linux-x86-64.zip'
profile::ca_sso_web_agent::log_file_size: '100'
profile::ca_sso_web_agent::trace_file_size: '100'
profile::ca_sso_web_agent::policy_servers:
  - 'policyserver="192.168.20.11,44441,44442,44443"'
  - 'policyserver="192.168.30.139,44441,44442,44443"'
  - 'policyserver="192.168.40.12,44441,44442,44443"'
  - 'policyserver="192.168.50.140,44441,44442,44443"'
profile::ca_sso_web_agent::registration_host_config_object: 'EXAMPLE_CLUSTERHOST_GLOBAL_MP'
profile::ca_sso_web_agent::registration_hostname: 'example_webagent01.example.com'
profile::ca_sso_web_agent::registration_fips_mode: 'ONLY'
profile::ca_sso_web_agent::registration_password: 'Str0ngP@$$word!'
profile::ca_sso_web_agent::registration_policy_server_ip: '192.168.30.139'
profile::ca_sso_web_agent::registration_username: 'registrar'
profile::ca_sso_web_agent::version: '12.52.109.2620'

```

## Reference
Parameter documentation has been generated using `puppet strings generate manifests/init.pp --format markdown`

See [REFERENCE.md](REFERENCE.md)

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

### Syntax Checking
Using PDK:

```
pdk validate
```

Alternatively, using rake:
```
bundle exec rake rubocop
bundle exec rake lint
bundle exec rake validate
```
### Unit Testing
Using PDK:

```
pdk test unit
```

Alternatively, using rake:

```
bundle exec rake spec
```

### Acceptance Testing
Copy `ca-wa-12.52-sp01-cr09a-linux-x86-64.zip` to `spec/acceptance/nodesets/docker/`

>**NOTE**: The `ca-wa-12.52-sp01-cr09a-linux-x86-64.zip` file is not included with this module. You must obtain this file and copy to the `spec/acceptance/nodesets/docker/` manually.

Build the docker image used for testing:

```
docker build spec/acceptance/nodesets/docker -t mycentos:7
```

Install dependencies and run tests:

```
bundle install
bundle exec rake beaker
```

> **TIP:** Set `BEAKER_destroy=onpass` to keep the docker container running in the event of a test failure.
```
BEAKER_destroy=onpass bundle exec rake beaker
```

Alternatively, use the dev node set to speed up the test writing/run cycles:

```
docker build -f spec/acceptance/nodesets/docker/Dockerfile-mycentos-dev spec/acceptance/nodesets/docker/ -t mycentos:dev
bundle exec rake beaker:dev
```

>**NOTE: The dev node set uses an image with packages and modules pre-installed. This should not be used for final acceptance testing.**

### Troubleshooting
If you receive the following error, remove the `Gemfile.lock` file and try again.
```
pdk (FATAL):
/opt/puppetlabs/pdk/private/ruby/2.5.1/lib/ruby/site_ruby/2.5.0/rubygems.rb:289:in `find_spec_for_exe': can't find gem bundler (>= 0.a) with executable bundle (Gem::GemNotFoundException)
        from /opt/puppetlabs/pdk/private/ruby/2.5.1/lib/ruby/site_ruby/2.5.0/rubygems.rb:308:in `activate_bin_path'
        from /opt/puppetlabs/pdk/private/ruby/2.5.1/bin/bundle:23:in `<main>'

pdk (FATAL): Unable to resolve Gemfile dependencies.
```

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
