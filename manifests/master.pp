# == Class: wal_e::master
class wal_e::master {

  cron { 'wal_e-backup-push':
    command => "/usr/bin/envdir ${wal_e::rootdir}/env /usr/local/bin/wal-e backup-push ${wal_e::pgdata}",
    user    => 'postgres',
    minute  => $wal_e::master_cron_backup_minute,
    hour    => $wal_e::master_cron_backup_hour,
  }
  cron { 'wal_e-delete-retain':
    command => "/usr/bin/envdir ${wal_e::rootdir}/env /usr/local/bin/wal-e delete --confirm retain 5",
    user    => 'postgres',
    minute  => $wal_e::master_cron_delete_minute,
    hour    => $wal_e::master_cron_delete_hour,
  }

  file_line { 'postgres_conf_1':
    path => "${wal_e::pgconf}/postgresql.conf",
    line => 'wal_level = archive # hot_standby in 9.0+ is also acceptable',
  } ->
  file_line { 'postgres_conf_2':
    path => "${wal_e::pgconf}/postgresql.conf",
    line => 'archive_mode = on',
  } ->
  file_line { 'postgres_conf_3':
    path => "${wal_e::pgconf}/postgresql.conf",
    line => 'archive_command = \'envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-push %p\'',
  } ->
  file_line { 'postgres_conf_4':
    path => "${wal_e::pgconf}/postgresql.conf",
    line => 'archive_timeout = 60',
    notify => Service["postgresql"]
  }
}
