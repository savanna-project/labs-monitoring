class tools {

   package { 'iostat':
      ensure  => present,
      name    => 'sysstat',
   }

   package { 'bc':
      ensure  => present,
      name    => 'bc',
   }
}
