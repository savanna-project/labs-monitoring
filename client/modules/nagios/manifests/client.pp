class nagios::client (
  $monitor_ip = "127.0.0.1",
  $node_type = "1",
  $send_args = "1",
  $logs_dir = "/opt/stack/logs/screen",
  $url = $::nagios::params::url,
  $disable_services=( "none" ),
  $plugins_dir = $::nagios::params::plugins_dir
) inherits nagios::params {

  notify { 'Installing Nagios NRPE Daemon...':
    before => Package['nagios-nrpe-server'],
  }

  package { $::nagios::params::nrpe_package_name:
    ensure => present,
    alias  => "nagios-nrpe-server",
  }

  package { $::nagios::params::nagios_plugins_name:
    ensure => present,
    alias  => "nagios-plugins",
  }

  service { $::nagios::params::nrpe_package_name:
     ensure  => running,
     enable  => true,
     require => Package['nagios-nrpe-server'],
     alias   => "nagios-nrpe-server",
  }

  notify {'Set up NRPE config...':
     before => File['/etc/nagios/nrpe_local.cfg'],
     require => Package['nagios-nrpe-server'],
  }

  file { '/etc/nagios/nrpe_local.cfg':
     owner   => 'root',
     group   => 'root',
     mode    => '0644',
     content => template('nagios/nrpe_local.cfg.erb'),
     notify  => Service['nagios-nrpe-server'],
     require => Package['nagios-nrpe-server'],
  }

  if $node_type == "0" {
      file { '$::nagios::client::plugins_dir/check_logs':
         ensure  => present,
         source  => 'puppet:///modules/nagios/check_logs',
         mode    => '0755',
         require => Package['nagios-plugins'],
      }

      exec { 'check_logs':
         command => '$::nagios::client::plugins_dir/check_logs ${logs_dir}',
         require => File['$::nagios::client::plugins_dir/check_logs'],
      }
  }

  if $::osfamily == 'RedHat' {
     exec { 'iptables -I INPUT -p tcp -m tcp --dport 5666 -j ACCEPT && service iptables save':
        path    => "/sbin",
        require => Package['nagios-nrpe-server'],
     }

     exec { 'echo "include=/etc/nagios/nrpe_local.cfg" >> /etc/nagios/nrpe.cfg':
        path   => "/bin",
        notify => Service['nagios-nrpe-server'],
        require => Package['nagios-nrpe-server'],
     }
  }

}
  
