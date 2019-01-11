require 'spec_helper_acceptance'
require 'beaker/testmode_switcher/dsl'

describe 'Declare ca_sso_web_agent class:', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'With required parameters' do
    pp = <<-MANIFEST
      class { 'ca_sso_web_agent':
        # General params
        installation_binary             => 'ca-wa-12.52-sp01-cr09-linux-x86-64.bin',
        installation_zip                => 'ca-wa-12.52-sp01-cr09a-linux-x86-64.zip',
        install_dir                     => '/opt/ca/webagent',
        install_source                  => '/tmp/ca-wa-12.52-sp01-cr09a-linux-x86-64.zip',
        #registration_fips_mode          => $registration_fips_mode,
        registration_host_config_object => 'EXAMPLE_CLUSTERHOST_GLOBAL_MP',
        registration_hostname           => 'example_webagent01.example.com',
        registration_password           => 'Str0ngP@$$word!',
        registration_policy_server_ip   => '192.168.30.139',
        registration_username           => 'registrar',
        version                         => '12.52.109.2620',
        #
        # Parameters for WebAgent.conf template
        agent_config_object             => 'my_proxy_conf',
        #enable_local_config             => $enable_local_config,
        #enable_web_agent                => $enable_web_agent,
        #locale                          => $locale,
        policy_servers                  => ['policyserver="192.168.20.11,44441,44442,44443"', 'policyserver="192.168.30.139,44441,44442,44443"', 'policyserver="192.168.40.12,44441,44442,44443"', 'policyserver="192.168.50.140,44441,44442,44443"'],
        #server_path                     => $server_path,
        #
        # Parameters for LocalConfig.conf template
        #enable_log_file                 => $enable_log_file,
        #enable_trace_file               => $enable_trace_file,
        #log_file_size                   => $log_file_size,
        #trace_file_size                 => $trace_file_size,
      }
    MANIFEST
    it 'applies without error' do
      # execute_manifest(pp, catch_failures: true)
      # execute_manifest(pp, catch_changes: true )
      apply_manifest(pp, catch_failures: true)
    end

    it 'is idempotent' do
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'after applying ca_sso_web_agent class' do
    describe service('httpd') do
      it { should be_running}
      it { should be_enabled}
    end
  end
end
