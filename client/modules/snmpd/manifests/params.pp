# Class: snmpd::params
#
# This class holds parameters that need to be
# accessed by other classes.
class snmpd::params {
  case $::osfamily {
    'RedHat': {
      $package_name = 'net-snmp'
      file { '/etc/yum.repos.d/centos.repo':
        source  => 'puppet:///modules/snmpd/centos.repo',
      }

      file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6':
        mode    => '0644',
        source  => 'puppet:///modules/snmpd/RPM-GPG-KEY-EPEL-6',
      }
    }
    'Debian': {
      $package_name = 'snmpd'
      file { '/etc/apt/source.list.d/sources.list':
        source  => 'puppet:///modules/snmpd/sources.list',
      }

      exec { 'update-repo':
        command => '/usr/bin/apt-get update',
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'snmpd' module only supports osfamily Debian or RedHat (slaves only).")
    }
  }
}
