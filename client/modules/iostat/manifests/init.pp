class iostat {

   package { 'iostat':
      ensure  => present,
      name    => 'sysstat',
      require => Notify['Installing sysstat tools..'],
   }
}
