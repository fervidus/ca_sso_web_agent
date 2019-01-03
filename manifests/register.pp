# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent::register
class ca_sso_web_agent::register {
  $install_dir      = $::ca_sso_web_agent::install_dir
  $cf               = $::ca_sso_web_agent::registration_fips_mode
  $host_config_file = "${install_dir}/config/SmHost.conf"
  $hc               = $::ca_sso_web_agent::registration_host_config_object
  $hn               = $::ca_sso_web_agent::registration_hostname
  $password         = $::ca_sso_web_agent::registration_password
  $path             = "${install_dir}/bin"
  $policy_server_ip = $::ca_sso_web_agent::registration_policy_server_ip
  $policy_servers   = $::ca_sso_web_agent::policy_servers
  $user             = $::ca_sso_web_agent::registration_username

  exec {'Register CA SSO Web Agent':
    command     => "smreghost -i ${policy_server_ip} -hn ${hn} -u ${user} -p ${password} -hc ${hc} -f ${host_config_file} -cf ${cf} -o",
    environment => [ "LD_LIBRARY_PATH=${install_dir}/bin:${install_dir}/bin/thirdparty:\${LD_LIBRARY_PATH}", "CAPKIHOME=${install_dir}/CAPKI" ],
    path        => $path,
    user        => root,
  }

  # Add policy servers not added during registration
  $policy_servers.each | String $policy_server | {
    file_line { "Add ${policy_server} to SmHost.conf":
      ensure => present,
      after  => '#Add additional bootstrap policy servers here for fault tolerance.',
      path   => "${install_dir}/config/SmHost.conf",
      line   => $policy_server,
    }
  }

}
