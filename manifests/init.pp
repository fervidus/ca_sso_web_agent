# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent
class ca_sso_web_agent (
  # @TODO: The install_dir path is hardcoded in the fact that grabs the version. Need to dynamically grab the path in the fact...
  String $install_dir,
  String $properties_file,
  String $temp_location,
  String $version,
) {

  $installed_version = $::facts['ca_sso_web_agent_version']

  if $version != $installed_version {
    #notify { "VERSION MISMATCH!!! ---> CA SSO Web Agent version specified is ${version} and installed version is ${installed_version}": }
    notify { "VERSION MISMATCH!!!": }

    contain ca_sso_web_agent::install
  }
  else {
    #notify { "VERSION MATCH!!! --> version ${version} = installed version ${installed_version}": }
    notify { "VERSION MATCH!!!": }
  }

}
