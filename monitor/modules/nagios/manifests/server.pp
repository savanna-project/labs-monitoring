class nagios::server (
    $passwordfile_path = "/etc/nagios3/htpasswd.users",
    $nagios_user = "nagiosadmin",
    $cgi_authorized_user = "nagiosadmin",
    $nagios_password = "nagiosadmin",
    $check_external_commands = "1",
    $command_check_interval = "10s",
    $refresh_rate = "30",
    $contact_name = "admin",
    $admin_email = "root@localhost",
    $admin_pager = "pageroot@localhost",
) 
{
    notify { 'Installing Nagios...':
       before => Package['nagios3'],
    }

    package { [
         'nagios3',
         'nagios-plugins',
         'nagios-nrpe-plugin',
         ]:
       ensure => present,
    }

    service { 'nagios3':
       ensure  => running,
       enable  => true,
       require => Package['nagios3'],
    }

    notify { 'Nagios is installed':
       require => Package['nagios3'],
    }

    exec { 'create_password':
       command => "htpasswd -cb ${passwordfile_path} ${nagios_user} ${nagios_password}",
       path    => "/usr/bin",
       require => Package['nagios3'],
    }


    ##########################
    # Move Nagios conf files #
    ##########################

    file { '/etc/nagios3/nagios.cfg':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('nagios/nagios.cfg.erb'),
        notify  => Service['nagios3'],
        require => Package['nagios3'],
    }

    file { '/etc/nagios3/cgi.cfg':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('nagios/cgi.cfg.erb'),
        require => Package['nagios3'],
    }

    ###################
    # Set permissions #
    ###################

    file { "/var/lib/nagios3/rw":
       ensure  => "directory",
       owner   => "nagios",
       group   => "www-data",
       mode    => 2710,
       require => Package['nagios3'],
       notify  => Service['nagios3'],
    }

    file { "/var/lib/nagios3":
       ensure => "directory",
       owner  => "nagios",
       group  => "nagios",
       mode   => 751,
       require => Package['nagios3'],
       notify  => Service['nagios3'],
    }

    #################################
    # Set default openstack configs #
    #################################

    file { '/etc/nagios3/conf.d/openstack':
        ensure => "directory",
    }

    file { "/etc/nagios3/conf.d/openstack/openstack_contacts.cfg":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('nagios/openstack_configs/openstack_contacts.cfg.erb'),
        notify  => Service['nagios3'],
        require => [ Package['nagios3'], File['/etc/nagios3/conf.d/openstack'] ],
    }

    file { "/etc/nagios3/conf.d/openstack/openstack_host.cfg":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('nagios/openstack_configs/openstack_host.cfg.erb'),
        notify  => Service['nagios3'],
        require => [ Package['nagios3'], File['/etc/nagios3/conf.d/openstack'] ]
    }

    file { "/etc/nagios3/conf.d/openstack/openstack_generic-service.cfg":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('nagios/openstack_configs/openstack_generic-service.cgf.erb'),
        notify  => Service['nagios3'],
        require => [ Package['nagios3'], File['/etc/nagios3/conf.d/openstack'] ]
    }
}
