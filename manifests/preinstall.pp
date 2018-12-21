# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ca_sso_web_agent::preinstall
class ca_sso_web_agent::preinstall {

  $prereq_packages = $::ca_sso_web_agent::prereq_packages
  package { $prereq_packages:
    ensure  => present,
  }

}
