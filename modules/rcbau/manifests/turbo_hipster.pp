# == Class: rcbau::turbo_hipster
#
class rcbau::turbo_hipster (
  $th_repo = 'https://git.openstack.org/stackforge/turbo-hipster',
  $th_repo_destination = '/home/th/turbo-hipster',
  $th_dataset_path = "/var/lib/turbo-hipster/",
  $th_user = "th",
  $th_test_user = "nova",
  $th_test_pass = "tester",
  $th_test_host = "%",
  $th_databases = [
    "nova_dataset_20130910_devstack_applied_to_150",
    "nova_dataset_20131007_devstack",
    "nova_dataset_trivial_500",
    "nova_dataset_trivial_6000",
    "nova_datasets_user_001",
    "nova_dataset_user_002",
  ],
  $gearman_server = "",
  $gearman_port = 4730,
  $database_engine_package = "mysql-server",
  $database_engine = "mysql",
  $mysql_root_password = "master",
  $pypi_mirror = "http://pypi.python.org",
  $ssh_private_key = "",
  $dataset_host =  "",
  $dataset_path = "",
  $dataset_user = "",
  $rs_cloud_user = "",
  $rs_cloud_pass = "",
  $manage_start_script = true,
  $plugin = "db_migration",
  $stop_puppet = true,
  $iptables_rules4 = [
    "-p tcp --dport 3306 ! -d 172.16.0.1 -j DROP",
    "-p tcp --dport 3306  -d 172.16.0.1 -j ACCEPT",
  ],
  $shutdown_check = true,
  $shutdown_th = 'true',
  $debug_str   = '',
) {
  include openstack_project

  class { 'rcbau::server':
    iptables_public_tcp_ports => [80, 443],
    iptables_rules4           => $iptables_rules4,
    sysadmins                 => $sysadmins,
    stop_puppet               => $stop_puppet,
  }

  class { '::turbo_hipster':
    th_repo                  => $th_repo,
    th_repo_destination      => $th_repo_destination,
    th_dataset_path          => $th_dataset_path,
    th_user                  => $th_user,
    gearman_server           => $gearman_server,
    gearman_port             => $gearman_port,
    pypi_mirror              => $pypi_mirror,
    ssh_private_key          => $ssh_private_key,
    rs_cloud_user            => $rs_cloud_user,
    rs_cloud_pass            => $rs_cloud_pass,
    manage_start_script      => $manage_start_script,
    shutdown_check           => $shutdown_check,
  }

  if ($plugin == "db_migration") {
    class { '::turbo_hipster::db_migration':
      th_dataset_path         => $th_dataset_path,
      th_test_user            => $th_test_user,
      th_test_pass            => $th_test_pass,
      th_test_host            => $th_test_host,
      th_databases            => $th_databases,
      th_user                 => $th_user,
      database_engine         => $database_engine,
      database_engine_package => $database_engine_package,
      mysql_root_password     => $mysql_root_password,
      shutdown_th             => $shutdown_th,
      debug_str                => $debug_str,
    }
  }

  if ($plugin == "cookbooks_ci") {
    class { '::turbo_hipster::cookbooks_ci': }
  }
}
