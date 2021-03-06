class scstack::scstack_apache(
  $domain,
  $ip,
  $cert_apache,
  $key_apache,
  $cacert_apache,
  $adminmail,
  $installFolder
) {
    
  include apache

  apache::mod {"ldap":}
  apache::mod {"authnz_ldap":}
  apache::mod {"rewrite":}
  apache::mod {"proxy":}
  apache::mod {"proxy_http":}
  apache::mod {"ssl":}

  file { "/etc/hosts":
    content => template('scstack/apache/hosts.erb'),
  }

  file { "/etc/apache2/ports.conf":
    content => template('scstack/apache/ports.conf.erb'),
  }

  file { "/etc/apache2/sites-available/configProjects":
    ensure => present,
    require => Package['httpd'],
  }

  file { "/etc/apache2/sites-available/configProjects-ssl":
    ensure => present,
    require => Package['httpd'],
  }

  exec { "disable-other-hosts":
    command => "/bin/rm /etc/apache2/sites-enabled/000-default",
    onlyif => "/usr/bin/test -f /etc/apache2/sites-enabled/000-default",
    require => Package['httpd'],
  }
  
  file { "/etc/apache2/sites-available/apache.domain":
    replace => true,
    content => template('scstack/apache/apache.domain.erb'),
    require => [Exec["disable-other-hosts"],File["/etc/apache2/sites-available/configProjects"],File["/etc/apache2/sites-available/configProjects-ssl"]],
  }

  file { "/etc/apache2/sites-available/apache.domain-ssl":
    replace => true,
    content => template('scstack/apache/apache.domain-ssl.erb'),
    require => [
  Exec["disable-other-hosts"],
  File["/etc/apache2/sites-available/configProjects"],
  File["/etc/apache2/sites-available/configProjects-ssl"],
  ],
  }

  exec { "enable-default-host":
    command => "/usr/sbin/a2ensite apache.domain",
    notify => Service['httpd'],
    require => [File["/etc/apache2/sites-available/apache.domain"],Package['httpd']],
  }

  exec { "enable-ssl-host":
    command => "/usr/sbin/a2ensite apache.domain-ssl",
    notify => Service['httpd'],
    require => [File["/etc/apache2/sites-available/apache.domain-ssl"],Package['httpd']],
  }

  
}
