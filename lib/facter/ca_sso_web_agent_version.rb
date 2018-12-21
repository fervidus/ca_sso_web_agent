if File.file? '/app/CA/webagent/install_config_info/ca-wa-version.info'
  Facter.add(:ca_sso_web_agent_version) do
    confine kernel: 'Linux'
    setcode do
      Facter::Core::Execution.exec("grep -i fullversion /app/CA/webagent/install_config_info/ca-wa-version.info | awk -F = '{print $2}'")
    end
  end
end
