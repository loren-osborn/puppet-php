# = Define: php::ini
#
define php::ini (
    $value          = '',
    $template       = 'extra-ini.erb',
    $target         = 'extra.ini',
    $service        = $php::service,
    $config_dir     = $php::config_dir,
    $web_config_dir = $php::web_config_dir
) {

  include php

  file { "${web_config_dir}/conf.d/${target}":
    ensure  => 'present',
    content => template("php/${template}"),
    require => Package['php'],
    notify  => Service[$service],
  }

  file { "${config_dir}/cli/conf.d/${target}":
    ensure  => 'present',
    content => template("php/${template}"),
    require => Package['php'],
  }

}
