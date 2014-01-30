class nagios::configs (
    $data,
) {
    notify { 'Create hosts conf files...':
       require => Package['nagios3'],
    }

    create_resources('create_configs', $data)
}

define create_configs (
    $openstack_type,
    $openstack_name,
    $controller_name,
    $compute_name,
    $cinder_name,
    $controller_ip,
    $compute_ip,
    $cinder_ip,
    $disable_services,
    $group_name = $name,
) {
    file { "/etc/nagios3/conf.d/openstack/openstack_${name}_hosts.cfg":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('nagios/openstack_configs/openstack_hosts.cfg.erb'),
        notify  => Service['nagios3'],
        require => [ Package['nagios3'], File['/etc/nagios3/conf.d/openstack'], Notify['Create hosts conf files...'] ]
    }

    file { "/etc/nagios3/conf.d/openstack/openstack_${name}_hostgroup.cfg":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('nagios/openstack_configs/openstack_hostgroup.cfg.erb'),
        notify  => Service['nagios3'],
        require => [ Package['nagios3'], File['/etc/nagios3/conf.d/openstack'], Notify['Create hosts conf files...'] ]
    }

    file { "/etc/nagios3/conf.d/openstack/openstack_${name}_services.cfg":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('nagios/openstack_configs/openstack_services.cfg.erb'),
        notify  => Service['nagios3'],
        require => [ Package['nagios3'], File['/etc/nagios3/conf.d/openstack'], Notify['Create hosts conf files...'] ]
    }
}
