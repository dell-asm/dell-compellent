transport { "compellent":
  provider => device_file
}

compellent_cluster_server { "sample_cluster_server":
  ensure    => present,
  folder    => "",
  operatingsystem => "VMWare ESX 5.1",
  transport => Transport["compellent"],
}
