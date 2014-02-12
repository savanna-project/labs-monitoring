class iostat {
   notify { 'Installing sysstat tools..':
   }

   package { 'iostat':
      ensure  => present,
      name    => 'sysstat',
      require => Notify['Installing sysstat tools..'],
   }
}
