#!/bin/bash
client_path=`pwd`"/client"
monitor_path=`pwd`"/monitor"
log_dir=`pwd`/puppet-logs
user="root"

OS_USERNAME=""
OS_AUTH_URL=""
OS_PASSWORD=""
OS_TENANT_NAME=""

monitor_ip=""
monitor_name=""
i_am_monitor=false
disable_services=( )

openstack_type=""
openstack_name=""
controller_name=""
controller_ip=""
compute_name=( )
compute_ip=( )
cinder_name=( )
cinder_ip=( )

nagios_admin="nagiosadmin"
nagios_password="nagiosadmin"
admin_email="root@localhost"
refresh_rate="30"
command_check_interval="10s"

guest_user="guest"
guest_password="welcome"

send_files () {
   if [ $i_am_monitor ] && [ $4 == "monitor" ]
   then
       puppet apply --verbose --trace --modulepath=$monitor_path/modules $monitor_path/site.pp 2>&1 | tee $log_dir/$monitor_name-$monitor_ip.log
   else
       echo "Send files to $2 ($3)..."
       scp -qr $1 $user@$3:/tmp
       if [ $? -ne 0 ]
       then
           echo "Can't copy files to $2 ($3)"
           exit 3
       fi
       echo "Run puppet on $2 ($3)..."
       ssh $user@$3 "puppet apply --verbose --trace --modulepath='/tmp/$4/modules' /tmp/$4/site.pp" 2>&1 | tee $log_dir/$2-$3.log
   fi
   if [ ${PIPESTATUS[0]} -eq 0 ]
   then
       echo "Installation of puppet-modules on $2 ($3) completed successfully"
   else
       echo "During installation of puppet-modules on $2 ($3) found some problems. Check $2-$3.log"
   fi
}

create_monitor_config () {
   hosts="'$controller_name:$controller_ip',"
   name_computes=""
   ip_computes=""
   name_cinders=""
   ip_cinders=""
   SAVE_IFS=$IFS
   IFS=","
   if [ $openstack_type == "0" ]
   then
       name_computes=$controller_name
       ip_computes=$controller_ip
       name_cinders=$name_computes
       ip_cinders=$ip_computes
   elif [ $openstack_type == "1" ]
   then
       length=${#compute_name[@]}
       for (( i=0; i<${length}; i++ ));
       do
           hosts="$hosts'${compute_name[$i]}:${compute_ip[$i]}',"
       done
       length=${#cinder_name[@]}
       for (( i=0; i<${length}; i++ ));
       do
           hosts="$hosts'${cinder_name[$i]}:${cinder_ip[$i]}',"
       done
       name_computes="${compute_name[*]}"
       ip_computes="${compute_ip[*]}"
       name_cinders="${cinder_name[*]}"
       ip_cinders="${cinder_ip[*]}"
   else
       lenght=${#compute_name[@]}
       for (( i=0; i<${length}; i++ ));
       do
           hosts="$hosts'${compute_name[$i]}:${compute_ip[$i]}',"
       done
       name_computes="${compute_name[*]}"
       ip_computes="${compute_ip[*]}"
       name_cinders=$name_computes
       ip_cinders=$ip_computes
   fi
   IFS=$SAVE_IFS
   echo -e "node '$monitor_name' {
   class { 'cacti::cacti':
       cacti_hosts     => [ $hosts ],
   }
   class { 'nagios::server':
       nagios_user         => \"$nagios_admin\",
       cgi_authorized_user => \"$nagios_admin\",
       nagios_password     => \"$nagios_password\",
       admin_email         => \"$admin_email\",
       refresh_rate        => \"$refresh_rate\",
       command_check_interval => \"$command_check_interval\",
       guest_user          => \"$guest_user\",
       guest_password      => \"$guest_password\",
   }
   \$my_stacks = {
           '$openstack_name'  => {
                        openstack_type  => \"$openstack_type\",
                        openstack_name  => \"$openstack_name\",
                        controller_name => \"$controller_name\",
                        compute_name    => \"$name_computes\",
                        cinder_name     => \"$name_cinders\",
                        controller_ip   => \"$controller_ip\",
                        compute_ip      => \"$ip_computes\",
                        cinder_ip       => \"$ip_cinders\",
                        disable_services => \"$disable_services\",
           },
    }
    class { 'nagios::configs':
       data => \$my_stacks,
    }
    Class['cacti::cacti'] -> Class['nagios::server']
}" > $monitor_path/site.pp
   send_files $monitor_path $monitor_name $monitor_ip "monitor"
}

create_client_config () {
   echo -e "node '$1' {
   include snmpd
   class { 'nagios::client':
       monitor_ip => \"$monitor_ip\",
       node_type  => \"$2\",
       disable_services => \"$disable_services\",
   }\n" > $client_path/site.pp
   if [ $2 == "0" ] || [ $2 == "1" ]
   then
       echo -e "class { 'nagios::creds':
       os_username => \"$OS_USERNAME\",
       os_auth_url => \"$OS_AUTH_URL\",
       os_password => \"$OS_PASSWORD\",
       os_tenant_name => \"$OS_TENANT_NAME\",
   }\n" >> $client_path/site.pp
   fi
   echo -e "Class['snmpd'] -> Class['nagios::client']
}" >> $client_path/site.pp
   send_files $client_path $1 $3 "client"
}

check_access () {
   ssh $user@$2 -qo StrictHostKeyChecking=no "uname" > /dev/null
   if [ $? -ne 0 ]
   then
       echo "Access denied to $1"
       exit 3
   else
       echo "Access granted to $1"
   fi
}

func () {
   if [ $1 == "0" ]
   then
       create_client_config $controller_name "0" $controller_ip
   elif [ $1 == "1" ]
   then
       create_client_config $controller_name "1" $controller_ip
   elif [ $1 == "2" ] || [ $1 == "2-3" ]
   then
       length=${#compute_name[@]}
       for (( i=0; i<${length}; i++ ));
       do
           create_client_config ${compute_name[$i]} "$1" ${compute_ip[$i]}
       done
   elif [ $1 == "3" ]
   then
       length=${#cinder_name[@]}
       for (( i=0; i<${length}; i++ ));
       do
           create_client_config ${cinder_name[$i]} "3" ${cinder_ip[$i]}
       done
   fi
}

if ! [ -d $log_dir ]
then
    mkdir $log_dir
fi
if [ -z $OS_USERNAME ] || [ -z $OS_PASSWORD ] || [ -z $OS_AUTH_URL ] || [ -z $OS_TENANT_NAME ]
then
    echo "Some of Openstack credentials is not specified."
    exit 3
fi
if [ -z $monitor_ip ]
then
    echo "Parameter 'monitor_ip' is not specified."
    exit 3
fi
if [ -z $monitor_name ]
then
    echo "Parameter 'monitor_name' is not specified."
    exit 3
fi
if [ -z $nagios_password ] || [ -z $admin_email ] || [ -z $refresh_rate ] || [ -z $command_check_interval ] || [ -z $nagios_admin ]
then
    echo "Some of default parameter 'nagios_admin', 'nagios_password', 'admin_email', 'refresh_rate', 'command_check_interval' is not specified."
    exit 3
fi

if [ -z $controller_ip ]
then
    echo "Parameter 'controller_ip' is not specified."
    exit 3
fi
if [ -z $controller_name ]
then
    echo "Parameter 'controller_name' is not specified."
    exit 3
fi
if [ -z $openstack_name ]
then
    echo "Parameter 'openstack_name' is not specified."
    exit 3
fi

if ! [ $i_am_monitor ]
then
    check_access $monitor_name $monitor_ip
fi
check_access $controller_name $controller_ip
if [ $openstack_type == "0" ]
then
    func "0"
elif [ $openstack_type == "1" ]
then
    if [ ${#compute_name[@]} != ${#compute_ip[@]} ]
    then
        echo "Length lists of compute's name and compute's ip is mismatch"
        exit 3
    fi
    if [ ${#cinder_name[@]} != ${#cinder_ip[@]} ]
    then
        echo "Length lists of cinder's name and cinder's ip is mismatch"
        exit 3
    fi
    length=${#compute_name[@]}
    for (( i=0; i<${length}; i++ ));
    do
        check_access ${compute_name[$i]} ${compute_ip[$i]}
    done
    length=${#cinder_name[@]}
    for (( i=0; i<${length}; i++ ));
    do
        check_access ${cinder_name[$i]} ${cinder_ip[$i]}
    done
    func "1"
    func "2"
    func "3"
elif [ $openstack_type == "2" ]
then
    if [ ${#compute_name[@]} != ${#compute_ip[@]} ]
    then
        echo "Length lists of compute's name and compute's ip is mismatch"
        exit 3
    fi
    length=${#compute_name[@]}
    for (( i=0; i<${length}; i++ ));
    do
        check_access ${compute_name[$i]} ${compute_ip[$i]}
    done
    func "1"
    func "2-3"
elif [ -z $openstack_type ]
then
    echo "Parameter 'openstack_type' is not specified."
    exit 3
else
    echo "Wrong type of Openstack: ${openstack_type}. See README"
    exit 3
fi
create_monitor_config
