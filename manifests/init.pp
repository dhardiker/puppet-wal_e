# == Class: wal_e
#
# Full description of class wal_e here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { wal_e:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
# === Copyright
#
# Copyright 2013 Justin Downing
#
class wal_e (
  $role       = 'slave',
  $rootdir    = '/etc/wal-e.d',
  $pgdata     = '/var/lib/postgresql/9.2/main',
  $pgconf     = '/etc/postgresql/9.2/main',
  $master     = undef,
  $access_key = undef,
  $secret_key = undef,
  $s3_prefix  = undef,
  $master_cron_backup_hour   = '8',
  $master_cron_backup_minute = '0',
  $master_cron_delete_hour   = '9',
  $master_cron_delete_minute = '0',
) {

  if $role == 'master' {
    include wal_e::master
  } else {
    include wal_e::slave
  }

  include wal_e::deps

  package { 'wal-e':
    name     => 'git+https://github.com/wal-e/wal-e',
    provider => 'pip',
    require  => Class['wal_e::deps'],
  }

  file { [$rootdir, "${rootdir}/env"]:
    ensure => directory,
    mode   => '0750',
  }

  file { "${rootdir}/env/AWS_ACCESS_KEY_ID":
    ensure  => file,
    content => $access_key,
    require => File["${rootdir}/env"],
  }

  file { "${rootdir}/env/AWS_SECRET_ACCESS_KEY":
    ensure  => file,
    content => $secret_key,
    require => File["${rootdir}/env"],
  }

  file { "${rootdir}/env/WALE_S3_PREFIX":
    ensure  => file,
    content => $s3_prefix,
    require => File["${rootdir}/env"],
  }

  File {
    owner  => 'root',
    group  => 'postgres',
    mode   => '0640',
  }
}
