class cacti::update_repo {
   
   if ($::osfamily == 'Debian') {
     exec { 'add-repo':
       command => '/usr/bin/apt-add-repository ppa:micahg/ppa',
     }

     notify { 'Updating repo...':
     }

     exec { 'update-repo':
       command => '/usr/bin/apt-get update',
     }

     notify { 'Repo is update':
     }

     Exec['add-repo'] -> Notify['Updating repo...'] -> Exec['update-repo'] -> Notify['Repo is update']
   }
}
