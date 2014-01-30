class nagios::creds (
  os_username="",
  os_auth_url="",
  os_password="",
  os_tenant_name="",
) inherits params {
  file { "/usr/$::nagios::params::plugins_dir/nagios/plugins/check_openstack":
    mode    => '0755',
    content => template('nagios/check_openstack.erb'),
    require => Package['nagios-plugins'],
  }
}
