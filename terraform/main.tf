module "create_enforcer_service_account" {
  source                       = "./modules/createserviceaccount"
  service_account_id           = "${var.enforcer_service_account_id}"
  service_account_display_name = "${var.enforcer_service_account_name}"
  service_account_project      = "${var.patrol_projectid}"
}

module "create_forseti_service_account" {
  source                       = "./modules/createserviceaccount"
  service_account_id           = "${var.forseti_service_account_id}"
  service_account_display_name = "${var.forseti_service_account_name}"
  service_account_project      = "${var.patrol_projectid}"
}

module "create_apiserver_service_account" {
  source                       = "./modules/createserviceaccount"
  service_account_id           = "${var.apiserver_service_account_id}"
  service_account_display_name = "${var.apiserver_service_account_name}"
  service_account_project      = "${var.patrol_projectid}"
}

module "create_cloudsql_service_account" {
  source                       = "./modules/createserviceaccount"
  service_account_id           = "${var.cloudsql_service_account_id}"
  service_account_display_name = "${var.cloudsql_service_account_name}"
  service_account_project      = "${var.patrol_projectid}"
}


module "create_enforcer_service_account_key" {
  source             = "./modules/createserviceaccountkey"
  service_account_id = "${module.create_enforcer_service_account.id}"
}

module "create_forseti_service_account_key" {
  source             = "./modules/createserviceaccountkey"
  service_account_id = "${module.create_forseti_service_account.id}"
}

module "create_apiserver_service_account_key" {
  source             = "./modules/createserviceaccountkey"
  service_account_id = "${module.create_apiserver_service_account.id}"
}

module "create_cloudsql_service_account_key" {
  source             = "./modules/createserviceaccountkey"
  service_account_id = "${module.create_cloudsql_service_account.id}"
}

module "save_enforcer_service_account_key" {
  source  = "./modules/savebase64contenttofile"
  content = "${module.create_enforcer_service_account_key.content}"
  path    = "${var.patrol_keys_path}/${var.enforcer_service_account_id}.json"
}

module "save_forseti_service_account_key" {
  source  = "./modules/savebase64contenttofile"
  content = "${module.create_forseti_service_account_key.content}"
  path    = "${var.patrol_keys_path}/${var.forseti_service_account_id}.json"
}

module "save_apiserver_service_account_key" {
  source  = "./modules/savebase64contenttofile"
  content = "${module.create_apiserver_service_account_key.content}"
  path    = "${var.patrol_keys_path}/${var.apiserver_service_account_id}.json"
}

module "save_cloudsql_service_account_key" {
  source  = "./modules/savebase64contenttofile"
  content = "${module.create_cloudsql_service_account_key.content}"
  path    = "${var.patrol_keys_path}/${var.cloudsql_service_account_id}.json"
}


module "grant_enforcer_forseti_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles   = "${var.enforcer_forseti_roles}"
  email  = "${module.create_enforcer_service_account.email}"
  providers = {
    google = "google.forseti"
  }
}

module "grant_enforcer_patrol_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles   = "${var.enforcer_patrol_roles}"
  email  = "${module.create_enforcer_service_account.email}"
}

module "grant_forseti_forseti_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles   = "${var.forseti_forseti_roles}"
  email  = "${module.create_forseti_service_account.email}"
  providers = {
    google = "google.forseti"
  }
}

module "grant_forseti_patrol_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles   = "${var.forseti_patrol_roles}"
  email  = "${module.create_forseti_service_account.email}"
}

module "grant_apiserver_patrol_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles   = "${var.apiserver_patrol_roles}"
  email  = "${module.create_apiserver_service_account.email}"
}

module "grant_apiserver_forseti_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles   = "${var.apiserver_forseti_roles}"
  email  = "${module.create_apiserver_service_account.email}"
  providers = {
    google = "google.forseti"
  }
}

module "grant_cloudsql_patrol_service_account_roles" {
  source = "./modules/grantroletoserviceaccount"
  roles   = "${var.cloudsql_patrol_roles}"
  email  = "${module.create_cloudsql_service_account.email}"
}

module "create_patrol_scanner_bucket"{
  source = "./modules/creategcsbucket"
  name = "${var.patrol_scanner_bucket_name}"
  force_destroy = "${var.force_destroy_buckets}"
}

module "create_patrol_cai_bucket"{
  source = "./modules/creategcsbucket"
  name = "${var.patrol_cai_bucket_name}"
  force_destroy = "${var.force_destroy_buckets}"
}

module "create_patrol_enforcer_pubsub_topic"{
  source = "./modules/createpubsubtopic"
  name = "${var.enforcer_pubsub_topic}"
}

module "create_patrol_forseti_pubsub_topic"{
  source = "./modules/createpubsubtopic"
  name = "${var.forseti_pubsub_topic}"
}

module "create_patrol_enforcer_subscription"{
  source = "./modules/createpubsubtopicsubscription"
  name = "${var.enforcer_pubsub_topic_subscription}"
  topic = "${module.create_patrol_enforcer_pubsub_topic.id}"
}

module "create_patrol_forseti_subscription"{
  source = "./modules/createpubsubtopicsubscription"
  name = "${var.forseti_pubsub_topic_subscription}"
  topic = "${module.create_patrol_forseti_pubsub_topic.id}"
}

module "create_private_ip" {
    source = "./modules/createprivateip"
    name = "${var.cloudsql_private_ip_name}"
    network_self_link = "https://www.googleapis.com/compute/v1/projects/${var.patrol_projectid}/global/networks/${var.cloud_sql_instance_network}"
    providers = {
    google = "google-beta"
  }
}

module "createservicenetworkingconnection" {
  source = "./modules/createservicenetworkingconnection"
  network = "${module.create_private_ip.network_link}"
  reserved_peering_ranges = ["${module.create_private_ip.name}"]
  providers = {
    google = "google-beta"
  }
}

module "create_patrol_cloudsql_instance" {

  source = "./modules/createcloudsqlinstance"
  name = "${var.cloud_sql_instance_name}"
  region = "${var.cloud_sql_instance_region}"
  tier = "${var.cloud_sql_instance_tier}"
  private_network_link = "${module.createservicenetworkingconnection.network_link}"
    providers = {
    google = "google-beta"
  }
  
}

module "create_patrol_apiserver_user" {
  source = "./modules/createcloudsqluser"
  name = "${var.patrol_apiserver_user}"
  instance = "${module.create_patrol_cloudsql_instance.name}"
  host = "${var.patrol_apiserver_cloudsql_host}"
}

module "create_patrol_forseti_user" {
  source = "./modules/createcloudsqluser"
  name = "${var.patrol_forseti_user}"
  instance = "${module.create_patrol_cloudsql_instance.name}"
  host = "${var.patrol_forseti_cloudsql_host}"
}
module "create_patrol_apiserver_database"{
  source = "./modules/createcloudsqldatabase"
  name = "${var.patrol_apiserver_cloudsql_database}"
  instance = "${module.create_patrol_cloudsql_instance.name}"
}

module "create_patrol_forseti_database"{
  source = "./modules/createcloudsqldatabase"
  name = "${var.patrol_forseti_cloudsql_database}"
  instance = "${module.create_patrol_cloudsql_instance.name}"
}

module "create_event_trigger_serviceaccount"{
  source = "./modules/createserviceaccount"
  service_account_id = "${var.event_trigger_service_account_name}"
  service_account_display_name = "${var.event_trigger_service_account_name}"
  service_account_project = "${var.patrol_projectid}"
}

module "grant_roles_to_event_trigger_serviceaccount"{
  source = "./modules/grantroletoserviceaccount"
  roles   = "${var.event_trigger_service_account_roles}"
  email  = "${module.create_event_trigger_serviceaccount.email}"
}

module "create_eventtrigger_service_account_key" {
  source             = "./modules/createserviceaccountkey"
  service_account_id = "${module.create_event_trigger_serviceaccount.id}"
}

module "save_eventtrigger_service_account_key" {
  source  = "./modules/savebase64contenttofile"
  content = "${module.create_eventtrigger_service_account_key.content}"
  path    = "${var.patrol_keys_path}/${var.eventtrigger_service_account_id}.json"
}

module "create_event_trigger_topic"{
  source = "./modules/createpubsubtopic"
  name = "${var.event_trigger_topic_name}"
}

module "create_event_trigger_subscription"{
  source = "./modules/createpubsubtopicsubscription"
  name = "${var.event_trigger_subscription_name}"
  topic = "${module.create_event_trigger_topic.id}"
}

module "create_kubernetes_cluster"{
  source = "./modules/createkubernetescluster"
  name = "${var.patrol_gke_cluster_name}"
  network = "${var.patrol_gke_network}"
  location = "${var.patrol_compute_instance_zone}"
  machine_type = "${var.patrol_compute_instance_machine_type}"
}
