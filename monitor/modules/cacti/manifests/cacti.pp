# Class to configure cacti on a node.
# Takes a list of sysadmin email addresses as a parameter. Exim will be
# configured to email cron spam and other alerts to this list of admins.
class cacti::cacti (
  $cacti_hosts = [
    'localhost:127.0.0.1',
  ]
) {
  include cacti::update_repo

  notify { 'Installing Cacti...':
    require => Notify['Repo is update'],
  }

  package { 'cacti':
    ensure  => present,
  }

  package { 'cacti-spine':
    ensure  => present,
  }

  notify { 'Cacti is installed':
  }

  Notify['Installing Cacti...'] -> Package['cacti'] -> Package['cacti-spine'] -> Notify['Cacti is installed']

  file { '/usr/local/share/cacti/resource/snmp_queries':
    ensure  => directory,
    owner   => 'root',
    require => Package['cacti'],
  }

  file { '/usr/local/share/cacti/resource/snmp_queries/net-snmp_devio.xml':
    ensure  => present,
    source  => 'puppet:///modules/cacti/net-snmp_devio.xml',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => File['/usr/local/share/cacti/resource/snmp_queries'],
  }

  file { '/var/lib/cacti/linux_host.xml':
    ensure  => present,
    source  => 'puppet:///modules/cacti/linux_host.xml',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => File['/usr/local/share/cacti/resource/snmp_queries/net-snmp_devio.xml'],
  }

  file { '/usr/local/bin/create_graphs.sh':
    ensure => present,
    source => 'puppet:///modules/cacti/create_graphs.sh',
    mode   => '0744',
    owner  => 'root',
    group  => 'root',
  }

  exec { 'cacti_import_xml':
    command => '/usr/bin/php -q /usr/share/cacti/cli/import_template.php --filename=/var/lib/cacti/linux_host.xml --with-template-rras',
    cwd     => '/usr/share/cacti/cli',
    require => File['/var/lib/cacti/linux_host.xml'],
  }

  cacti::cacti_device { $cacti_hosts: }
#  include cacti::install_plugins
}
