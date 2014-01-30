class nagios::params {
    case $::osfamily {
       'RedHat': {
          $nrpe_package_name = 'nrpe'
          $nagios_plugins_name = 'nagios-plugins-all'
          $plugins_dir = 'lib64'
          $url = '/dashboard'
        }
        'Debian': {
          $nrpe_package_name = 'nagios-nrpe-server'
          $nagios_plugins_name = 'nagios-plugins'
          $plugins_dir = 'lib'
          $url = '/'
        }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'nagios-client' module only supports osfamily Debian or RedHat (slaves only).")
    }
  }

}
