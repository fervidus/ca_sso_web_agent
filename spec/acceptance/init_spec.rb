require 'spec_helper_acceptance'
require 'beaker/testmode_switcher/dsl'

agent_config_object             = 'my_proxy_conf'
install_dir                     = '/opt/ca/webagent'
install_source                  = '/tmp/ca-wa-12.52-sp01-cr09a-linux-x86-64.zip'
policy_servers                  = ['policyserver="192.168.20.11,44441,44442,44443"', 'policyserver="192.168.30.139,44441,44442,44443"', 'policyserver="192.168.40.12,44441,44442,44443"', 'policyserver="192.168.50.140,44441,44442,44443"']
register_trusted_host           = false
registration_host_config_object = 'EXAMPLE_CLUSTERHOST_GLOBAL_MP'
registration_hostname           = 'example_webagent01.example.com'
registration_password           = 'Str0ngP@$$word!'
registration_policy_server_ip   = '192.168.30.139'
registration_username           = 'registrar'
version                         = '12.52.109.2620'

describe 'Declare ca_sso_web_agent class:', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'With required parameters and defaults' do
    pp = <<-MANIFEST
      class { 'ca_sso_web_agent':
        agent_config_object             => '#{agent_config_object}',
        install_dir                     => '#{install_dir}',
        install_source                  => '#{install_source}',
        policy_servers                  => #{policy_servers},
        register_trusted_host           => #{register_trusted_host},
        registration_host_config_object => '#{registration_host_config_object}',
        registration_hostname           => '#{registration_hostname}',
        registration_password           => '#{registration_password}',
        registration_policy_server_ip   => '#{registration_policy_server_ip}',
        registration_username           => '#{registration_username}',
        version                         => '#{version}',
      }
    MANIFEST
    it 'applies without error' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'is idempotent' do
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'after applying ca_sso_web_agent class' do
    prereq_packages = ['binutils', 'gcc', 'keyutils-libs.i686', 'libidn', 'libidn.i686', 'libstdc++.i686', 'libXext.i686', 'libXrender.i686', 'libXtst.i686', 'ncurses-libs.i686', 'unzip']
    prereq_packages.each do |package|
      describe package(package) do
        it { is_expected.to be_installed }
      end
    end
    describe file('/usr/local/bin/smreghost') do
      it { is_expected.to exist }
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to "#{install_dir}/bin/smreghost" }
    end
    describe file("#{install_dir}/config/LocalConfig.conf") do
      it { is_expected.to exist }
      it { is_expected.to contain('LogFile="NO"').before(%r{^LogFileName=}) }
      it { is_expected.to contain("LogFileName=\"#{install_dir}/log/WebAgent.log\"").after(%r{^LogFile="NO"}) }
      it { is_expected.to contain('LogFileSize="0"').after(%r{^LogFileName=}) }
      it { is_expected.to contain('TraceFile="NO"').after(%r{^LogFileSize=}) }
      it { is_expected.to contain("TraceFileName=\"#{install_dir}/log/WebAgentTrace.log\"").after(%r{^TraceFile=}) }
      it { is_expected.to contain('TraceFileSize="0"').after(%r{^TraceFileName=}) }
      it { is_expected.to contain("TraceConfigFile=\"#{install_dir}/config/WebAgentTrace.conf\"").after(%r{^TraceFileSize}) }
    end
    describe file("#{install_dir}/config/WebAgent.conf") do
      it { is_expected.to exist }
      it { is_expected.to contain 'LOCALE=en-US' }
      it { is_expected.to contain("HostConfigFile=\"#{install_dir}/config/SmHost.conf\"").before(%r{^AgentConfigObject=}) }
      it { is_expected.to contain('AgentConfigObject="my_proxy_conf"').after(%r{^HostConfigFile=}) }
      it { is_expected.to contain('EnableWebAgent="NO"').after(%r{^AgentConfigObject=}) }
      it { is_expected.to contain('ServerPath="/etc/httpd"').after(%r{^EnableWebAgent=}) }
      it { is_expected.to contain("#localconfigfile=\"#{install_dir}/config/LocalConfig.conf\"").after(%r{^ServerPath=}) }
      it { is_expected.to contain("LoadPlugin=\"#{install_dir}/bin/libHttpPlugin.so\"").after(%r{^#localconfigfile}) }
    end
    describe file("#{install_dir}/config/WebAgentTrace.conf") do
      it { is_expected.to exist }
      it { is_expected.to contain('components:  AgentFramework, HTTPAgent, WebAgent').before(%r{^data:}) }
      it { is_expected.to contain('data: Date, Time, Pid, Tid, SrcFile, Function, TransactionID, IPAddr, IPPort, AgentName, Resource, User, Message').after(%r{^components:}) }
    end
    describe file('/etc/sysconfig/httpd') do
      it { is_expected.to exist }
      it { is_expected.to contain("NETE_WA_ROOT=#{install_dir}").before(%r{^NETE_WA_PATH}) }
      it { is_expected.to contain("NETE_WA_PATH=#{install_dir}/bin").after(%r{^NETE_WA_ROOT=}) }
      it { is_expected.to contain("CAPKIHOME=#{install_dir}/CAPKI").after(%r{^NETE_WA_PATH=}) }
      it { is_expected.to contain("LD_LIBRARY_PATH=#{install_dir}/bin:#{install_dir}/bin/thirdparty:${LD_LIBRARY_PATH}").after(%r{^CAPKIHOME=}) }
      it { is_expected.to contain("PATH=#{install_dir}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin").after(%r{^LD_LIBRARY_PATH=}) }
    end
    describe file('/etc/httpd/conf.d/35-ca_sso_web_agent.conf') do
      it { is_expected.to exist }
      it { is_expected.to contain 'PassEnv CAPKIHOME' }
      it { is_expected.to contain "LoadModule sm_module #{install_dir}/bin/libmod_sm24.so" }
      it { is_expected.to contain "SmInitFile #{install_dir}/config/WebAgent.conf" }
    end
    describe service('httpd') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end
  context 'With local config enabled, web agent enabled, log and trace files enabled' do
    pp = <<-MANIFEST
      class { 'ca_sso_web_agent':
        agent_config_object             => '#{agent_config_object}',
        enable_local_config             => true,
        enable_log_file                 => true,
        enable_trace_file               => true,
        enable_web_agent                => true,
        install_dir                     => '#{install_dir}',
        install_source                  => '#{install_source}',
        policy_servers                  => #{policy_servers},
        register_trusted_host           => #{register_trusted_host},
        registration_host_config_object => '#{registration_host_config_object}',
        registration_hostname           => '#{registration_hostname}',
        registration_password           => '#{registration_password}',
        registration_policy_server_ip   => '#{registration_policy_server_ip}',
        registration_username           => '#{registration_username}',
        version                         => '#{version}',
      }
    MANIFEST
    it 'applies without error' do
      apply_manifest(pp, catch_failures: true)
    end
    describe file("#{install_dir}/config/WebAgent.conf") do
      it { is_expected.to exist }
      it { is_expected.to contain 'LOCALE=en-US' }
      it { is_expected.to contain("HostConfigFile=\"#{install_dir}/config/SmHost.conf\"").before(%r{^AgentConfigObject=}) }
      it { is_expected.to contain('AgentConfigObject="my_proxy_conf"').after(%r{^HostConfigFile=}) }
      it { is_expected.to contain('EnableWebAgent="YES"').after(%r{^AgentConfigObject=}) }
      it { is_expected.to contain('ServerPath="/etc/httpd"').after(%r{^EnableWebAgent=}) }
      it { is_expected.to contain("localconfigfile=\"#{install_dir}/config/LocalConfig.conf\"").after(%r{^ServerPath=}) }
      it { is_expected.to contain("LoadPlugin=\"#{install_dir}/bin/libHttpPlugin.so\"").after(%r{^localconfigfile}) }
    end
    describe file("#{install_dir}/config/LocalConfig.conf") do
      it { is_expected.to exist }
      it { is_expected.to contain('LogFile="YES"').before(%r{^LogFileName=}) }
      it { is_expected.to contain("LogFileName=\"#{install_dir}/log/WebAgent.log\"").after(%r{^LogFile="YES"}) }
      it { is_expected.to contain('LogFileSize="0"').after(%r{^LogFileName=}) }
      it { is_expected.to contain('TraceFile="YES"').after(%r{^LogFileSize=}) }
      it { is_expected.to contain("TraceFileName=\"#{install_dir}/log/WebAgentTrace.log\"").after(%r{^TraceFile=}) }
      it { is_expected.to contain('TraceFileSize="0"').after(%r{^TraceFileName=}) }
      it { is_expected.to contain("TraceConfigFile=\"#{install_dir}/config/WebAgentTrace.conf\"").after(%r{^TraceFileSize}) }
    end
  end
end
