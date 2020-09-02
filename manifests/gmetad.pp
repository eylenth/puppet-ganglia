# @summary ganglia::gmetad
#   All of the required bits to install
#
# @param all_trusted
# @param clusters
# @param gridname
# @param rras
# @param trusted_hosts
# @param gmetad_package_name
# @param gmetad_service_name
# @param gmetad_service_config
# @param gmetad_user
# @param gmetad_hostnames_case
# @param gmetad_status_command
#
# @see https://puppet.com/docs/puppet/6.17/style_guide.html#parameter-defaults
# @see https://puppet.com/docs/puppet/6.17/hiera_migrate.html#module_data_params
#
class ganglia::gmetad (
  Enum['on', 'off'] $all_trusted       = 'off',
  Tuple $clusters                      = [{ 'name' => 'my cluster', 'address' => 'localhost' }],
  $gridname                            = undef,
  $rras                                = $ganglia::params::rras,
  Array $trusted_hosts                 = [],
  String $gmetad_package_name          = $ganglia::params::gmetad_package_name,
  String $gmetad_service_name          = $ganglia::params::gmetad_service_name,
  String $gmetad_service_config        = $ganglia::params::gmetad_service_config,
  String $gmetad_user                  = $ganglia::params::gmetad_user,
  Integer[0, 1] $gmetad_hostnames_case = $ganglia::params::gmetad_hostnames_case,
  String $gmetad_status_command        = $ganglia::params::gmetad_status_command,

) inherits ganglia::params {

  ganglia_validate_rras($rras)

  if $gmetad_status_command {
    $hasstatus = false
  } else {
    $hasstatus = true
  }

  if versioncmp($::puppetversion, '3.6.0') > 0 {
    package { $gmetad_package_name:
      ensure        => present,
      allow_virtual => false,
    }
  } else {
    package { $gmetad_package_name:
      ensure => present,
    }
  }

  file { $gmetad_service_config:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($::ganglia::params::gmetad_service_erb),
    require => Package[$gmetad_package_name],
    notify  => Service[$gmetad_service_name],
  }
  service { $gmetad_service_name:
    ensure     => running,
    hasstatus  => $hasstatus,
    hasrestart => true,
    enable     => true,
    status     => $gmetad_status_command,
  }
}
