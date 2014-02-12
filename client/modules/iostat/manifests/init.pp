class iostat {
   notify { 'Installing sysstat tools..':
      before => Package['iostat'],
   }

   package { 'iostat':
      ensure => present,
      name => 'sysstat',
   }
}
