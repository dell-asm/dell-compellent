transport { "compellent":
  provider => device_file
}

compellent_cluster_server_map { "folderclusterobject":
  ensure    => present,
  cluster_server_name => "folderclusterobject",
  folder    => "folder1",
  server_name => "FolderTestObject",
  transport => Transport["compellent"],
}
