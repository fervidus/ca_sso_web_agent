if File.file? '/app/CA/webagent/config/SmHost.conf'
  Facter.add(:ca_sso_web_agent_policy_servers) do
    confine kernel: 'Linux'
    setcode do
      policy_servers = Facter::Core::Execution.exec('grep -i policyserver= /app/CA/webagent/config/SmHost.conf')
      policy_servers.split("\n")
    end
  end
end
