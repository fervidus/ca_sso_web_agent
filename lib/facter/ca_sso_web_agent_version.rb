install_dir = Facter.value(:ca_sso_web_agent_install_dir)

if File.file? "#{install_dir}/install_config_info/ca-wa-version.info"
  Facter.add(:ca_sso_web_agent_version) do
    confine kernel: 'Linux'
    setcode do
      Facter::Core::Execution.exec("grep -i fullversion #{install_dir}/install_config_info/ca-wa-version.info | awk -F = '{print $2}'")
    end
  end
end
