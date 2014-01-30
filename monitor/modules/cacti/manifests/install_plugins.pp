class cacti::install_plugins (
  $thold_url = "http://docs.cacti.net/_media/plugin:thold-v0.5.0.tgz",
  $thold = "thold-v0.5.0.tgz",
  $settings_url = "http://docs.cacti.net/_media/plugin:settings-v0.71-1.tgz",
  $settings = "settings-v0.71-1.tgz",
  $plugins_dir = "/usr/share/cacti/site/plugins",
) {

  notify { 'Installing plugins...':
    require => Notify['Cacti is installed'],
  }

  exec { 'thold':
    command => "wget --content-disposition $cacti::install_plugins::thold_url && tar xvf $cacti::install_plugins::thold",
    cwd     => $plugins_dir,
    path    => ["/usr/bin", "/bin"],
    require => Notify['Installing plugins...']
  }

  exec { 'settings':
    command => "wget --content-disposition $cacti::install_plugins::settings_url && tar xvf $cacti::install_plugins::settings",
    cwd     => $plugins_dir,
    path    => ["/usr/bin", "/bin"],
    require => Exec['thold'],
  }

  file { "$plugins_dir/patch-paths.sh":
    ensure  => present,
    source  => 'puppet:///modules/cacti/patch-paths.sh',
    mode    => '0744',
    owner   => 'root',
    group   => 'root',
    require => Package['cacti'],
  }

#  exec { 'patch-paths':
#    command => "$plugins_dir/patch-paths.sh",
#    require => [ Exec['settings'], File["$plugins_dir/patch-paths.sh"] ],
#  }

#  notify { 'Plugins is installed':
#    require => Exec['patch-paths'],
#  }
}
