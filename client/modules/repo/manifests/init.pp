class repo {
  case $::osfamily {
    'RedHat': {

      file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6':
        mode    => '0644',
        source  => 'puppet:///modules/repo/RPM-GPG-KEY-EPEL-6',
      }

      file { '/etc/yum.repos.d/centos.repo':
        source  => 'puppet:///modules/repo/centos.repo',
        require => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6'],
      }

      exec {'update-repo':
       	command => '/usr/bin/yum clean all',
        require => File['/etc/yum.repos.d/centos.repo'],
      }
    }
    'Debian': {
      file { '/etc/apt/sources.list.d/sources.list':
        source  => 'puppet:///modules/repo/sources.list',
      }

      exec { 'update-repo':
        command => '/usr/bin/apt-get update',
        require => File['/etc/apt/sources.list.d/sources.list'],
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}.")
    }
  }

}
