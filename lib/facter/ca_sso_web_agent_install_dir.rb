Facter.add(:ca_sso_web_agent_install_dir) do
  confine kernel: 'Linux'
  setcode do
    if Facter::Util::Resolution.which('smreghost')
      smreghost = Facter::Util::Resolution.which('smreghost')
      #Facter::Core::Execution.exec("realpath #{smreghost}")
      Facter::Core::Execution.exec("ls -l #{smreghost} | awk '{print $NF}' | cut -d/ -f-4")
    end
  end
end
