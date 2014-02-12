class iostat {

   package { 'iostat':
      ensure  => present,
      name    => 'sysstat',
   }
}
