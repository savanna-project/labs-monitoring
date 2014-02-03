To set up lab's monitoring you should set all required parameters in the ``deploy.sh`` script and run it. Also, you must be sure, that you can ssh to the VMs without password (using an RSA keypair).

Parameters, which should be set:
*  openstack creds (OS_USERNAME, OS_AUTH_URL, OS_PASSWORD, OS_TENANT_NAME)
*  monitor_ip - this parameter is obligatory ("X.X.X.X")
*  monitor_name - hostname of the monitor (run: hostname -f)
*  openstack_type - the acceptable values are: 0 - single node devstack; 1 - openstack with a controller, cinder, compute; 2 - openstack with a controller, cinder+compute
*  openstack_name - name of your OpenStack installation
*  controller_name - (run: hostname -f)
*  controller_ip
*  compute_name - (run: hostname -f)
*  compute_ip
*  cinder_name - (run: hostname -f)
*  cinder_ip

Parameters 'compute_name', 'compute_ip', 'cinder_name', 'cinder_ip' should be specified as arrays. For example:
*  compute_name = ( "compute-1" )
*  compute_ip = ( "X.X.X.X" )
or
*  compute_name = ( "compute-1", "compute-2" )
*  compute_ip = ( "X.X.X.X", "X.X.X.X" )

If you use openstack_type "0", you can skip 'compute_name', 'compute_ip', 'cinder_name', 'cinder_ip', because all these services run on one node.

If you use openstack_type "2", you can skip 'cinder_name', 'cinder_ip'. In this case it means, that cinder and compute services run on the same node.

Parameters, which are set by default, but you can change them:
*  disable_services - specify services (as array, like 'compute_name'), which you want disable (using 'none' by default). The acceptable values are: 'horizon', 'nova', 'glance', 'heat', 'neutron', 'cinder';
*  log_dir - directory for logs on a VM, where you run ``deploy.sh`` (using '%git-clone-dir%/puppet-log' by default);
*  user - The name of a user, which will install all packages. This user should have your RSA key (using 'root' by default);
*  i_am_monitor - if you want that the VM where you run 'deploy.sh' should be the monitor set this parameter to 'true' (using 'false' by default);
*  nagios_admin - admin nagios user,also it is used on the web UI (using 'nagiosadmin' by default);
*  nagios_password - password for the nagios admin (using 'nagiosadmin' by default);
*  guest_user - guest user fot web UI ('guest' by default);
*  guest_password - password fot guest user ('welcome' by default);
*  admin_email - The e-mail for notifications and alerts (using 'root@localhost' by default);
*  openstack_log_dir - directory, where located logs for openstack. It only uses for devstack, for now (using '/opt/stack/logs/screen' by default);
*  refresh_rate - The interval for services checking (using '30' second by default);
*  command_check_interval - The interval to wait between external command checks (using "10s" by default, 's' is necessary).
