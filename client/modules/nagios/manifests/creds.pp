class nagios::creds (
  $os_username="",
  $os_auth_url="",
  $os_password="",
  $os_tenant_name="",
  $ceph_auth="",
) inherits params {
  file { "${plugins_dir}/check_openstack":
    mode    => '0755',
    content => template('nagios/check_openstack.erb'),
    require => Package['nagios-plugins'],
  }
}
