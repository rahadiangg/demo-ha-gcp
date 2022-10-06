terraform {
    required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.88.0"
    }
  }
}

provider "google" {
  # credentials = file("file_credensial_gcp.json") # atau bisa juga menggunakan command 'gcloud auth application-default login
  project = var.project_id
}

provider "google-beta" {
  # credentials = file("file_credensial_gcp.json") # atau bisa juga menggunakan command 'gcloud auth application-default login
  project = var.project_id
}

resource "random_id" "suffix" {
  byte_length = 4
}

// ============================== Start VPC =====================================
# resource "google_compute_network" "default" {
#     auto_create_subnetworks         = true
#     delete_default_routes_on_create = false
#     name                            = "default"
#     routing_mode                    = "REGIONAL"
# }

resource "google_compute_network" "private_network" {
  provider = google-beta

  name = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

// ============================== End VPC =====================================


// ============================== Start CloudSql =====================================

# google_sql_database_instance.users-service:
resource "google_sql_database_instance" "users-service-master" {
    name                          = "users-service-master-${random_id.suffix.hex}"
    region                        = "asia-southeast2"
    database_version              = "MYSQL_8_0"
    deletion_protection           = false

    depends_on = [google_service_networking_connection.private_vpc_connection]

    settings {
        tier                        = "db-f1-micro"
        availability_type           = "REGIONAL"
        ip_configuration {
            ipv4_enabled    = false
            private_network = google_compute_network.private_network.id
        }

        location_preference {
            zone = "asia-southeast2-a"
        }

        backup_configuration {
          binary_log_enabled             = true
          enabled                        = true
          # location                       = "asia"
        }
    }
}

resource "google_sql_user" "users-service" {
  name     = "root"
  instance = google_sql_database_instance.users-service-master.name
  password = "rahadiangg"
}

resource "google_sql_database" "users-service" {
  name     = "demo_ha_gcp"
  instance = google_sql_database_instance.users-service-master.name
}

resource "google_sql_database_instance" "users-service-replica-id" {
  name                 = "users-service-replica-id-${random_id.suffix.hex}"
  master_instance_name = "${google_sql_database_instance.users-service-master.name}"
  region               = "asia-southeast2"
  database_version     = "MYSQL_8_0"
  deletion_protection  = false

  depends_on = [google_service_networking_connection.private_vpc_connection]

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
    }
    location_preference {
      zone = "asia-southeast2-b"
    }
  }
}

resource "google_sql_database_instance" "users-service-replica-us" {
  name                 = "users-service-replica-us-${random_id.suffix.hex}"
  master_instance_name = "${google_sql_database_instance.users-service-master.name}"
  region               = "us-central1"
  database_version     = "MYSQL_8_0"
  deletion_protection  = false

  depends_on = [google_service_networking_connection.private_vpc_connection]

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
    }
    location_preference {
      zone = "us-central1-a"
    }
  }
}

# # google_sql_database_instance.payments-service-id:
resource "google_sql_database_instance" "payments-service-id-master" {
    name                          = "payments-service-id-master-${random_id.suffix.hex}"
    region                        = "asia-southeast2"
    database_version              = "MYSQL_8_0"
    deletion_protection           = false

    depends_on = [google_service_networking_connection.private_vpc_connection]

    settings {
        tier                        = "db-f1-micro"
        availability_type           = "REGIONAL"
        ip_configuration {
            ipv4_enabled    = false
            private_network = google_compute_network.private_network.id
        }

        location_preference {
            zone = "asia-southeast2-a"
        }

        backup_configuration {
          binary_log_enabled             = true
          enabled                        = true
          # location                       = "asia"
        }
    }
}

resource "google_sql_user" "payments-service-id" {
  name     = "root"
  instance = google_sql_database_instance.payments-service-id-master.name
  password = "rahadiangg"
}

resource "google_sql_database" "payments-service-id" {
  name     = "demo_ha_gcp"
  instance = google_sql_database_instance.payments-service-id-master.name
}

# resource "google_sql_database_instance" "payments-service-id-replica" {
#   name                 = "payments-service-id-replica-${random_id.suffix.hex}"
#   master_instance_name = "${google_sql_database_instance.payments-service-id-master.name}"
#   region               = "asia-southeast2"
#   database_version     = "MYSQL_8_0"
#   deletion_protection  = false

#   replica_configuration {
#     failover_target = false
#   }

#   settings {
#     tier              = "db-f1-micro"
#     availability_type = "ZONAL"
#     ip_configuration {
#       ipv4_enabled    = false
#       private_network = google_compute_network.private_network.id
#     }
#     location_preference {
#       zone = "asia-southeast2-b"
#     }
#   }
# }

# google_sql_database_instance.payments-service-us:
resource "google_sql_database_instance" "payments-service-us-master" {
    name                          = "payments-service-us-master-${random_id.suffix.hex}"
    region                        = "us-central1"
    database_version              = "MYSQL_8_0"
    deletion_protection           = false

    depends_on = [google_service_networking_connection.private_vpc_connection]

    settings {
        tier                        = "db-f1-micro"
        availability_type           = "REGIONAL"
        ip_configuration {
            ipv4_enabled    = false
            private_network = google_compute_network.private_network.id
        }

        location_preference {
            zone = "us-central1-a"
        }

        backup_configuration {
          binary_log_enabled             = true
          enabled                        = true
          # location                       = "asia"
        }
    }
}

resource "google_sql_user" "payments-service-us" {
  name     = "root"
  instance = google_sql_database_instance.payments-service-us-master.name
  password = "rahadiangg"
}

resource "google_sql_database" "payments-service-us" {
  name     = "demo_ha_gcp"
  instance = google_sql_database_instance.payments-service-us-master.name
}

# resource "google_sql_database_instance" "payments-service-us-replica" {
#   name                 = "payments-service-us-replica-${random_id.suffix.hex}"
#   master_instance_name = "${google_sql_database_instance.payments-service-us-master.name}"
#   region               = "us-central1"
#   database_version     = "MYSQL_8_0"
#   deletion_protection  = false

#   replica_configuration {
#     failover_target = false
#   }

#   settings {
#     tier              = "db-f1-micro"
#     availability_type = "ZONAL"
#     ip_configuration {
#       ipv4_enabled    = false
#       private_network = google_compute_network.private_network.id
#     }
#     location_preference {
#       zone = "us-central1-b"
#     }
#   }
# }


// ============================== End CloudSql =====================================


// ============================== Start Setup Locust =====================================
# Define container metadata
module "gce-container-locust-id" {
  source = "github.com/terraform-google-modules/terraform-google-container-vm"

  container = {
    image= var.locust_load_test
    env = [
      {
        name = "COUNTRY_CODE"
        value = "id"
      },
    ]
  }

  restart_policy = "Always"
}

module "gce-container-locust-us" {
  source = "github.com/terraform-google-modules/terraform-google-container-vm"

  container = {
    image= var.locust_load_test
    env = [
      {
        name = "COUNTRY_CODE"
        value = "us"
      },
    ]
  }

  restart_policy = "Always"
}

# # google_compute_instance.locust-id:
resource "google_compute_instance" "locust-id" {
    name                 = "locust-indonesia"
    machine_type         = "g1-small"
    zone                 = "asia-southeast2-c"
    tags                 = [
        "locust",
    ]
    metadata             = {
      gce-container-declaration = module.gce-container-locust-id.metadata_value
      google-logging-enabled    = "true"
      google-monitoring-enabled = "true"
    }

    boot_disk {
      initialize_params {
        image = module.gce-container-locust-id.source_image
      }
    }

    network_interface {
        network           = google_compute_network.private_network.self_link
        access_config {
          network_tier = "PREMIUM"
        }
    }

    service_account {
      email  = var.email_service_account
      scopes = [
          "https://www.googleapis.com/auth/cloud-platform"
        ]
      }
}

# # google_compute_instance.locust-us:
resource "google_compute_instance" "locust-us" {
    name                 = "locust-us"
    machine_type         = "g1-small"
    zone                 = "us-central1-c"
    tags                 = [
        "locust",
    ]
    metadata             = {
      gce-container-declaration = module.gce-container-locust-us.metadata_value
      google-logging-enabled    = "true"
      google-monitoring-enabled = "true"
    }

    boot_disk {
      initialize_params {
        image = module.gce-container-locust-us.source_image
      }
    }

    network_interface {
        network           = google_compute_network.private_network.id
        access_config {
          network_tier = "PREMIUM"
        }
    }

    service_account {
      email  = var.email_service_account
      scopes = [
          "https://www.googleapis.com/auth/cloud-platform"
        ]
      }
}

# // ============================== End Setup Locust =====================================




# google_compute_health_check.http-health-check:
resource "google_compute_health_check" "http-health-check" {
    check_interval_sec  = 10
    healthy_threshold   = 2
    name                = "root-http-health-check"
    timeout_sec         = 5
    unhealthy_threshold = 3

    http_health_check {
        port         = 8080
        proxy_header = "NONE"
        request_path = "/"
    }
}





# // ============================== Start Users Service =====================================


# // Indonesia
module "gce-container-users-service-id" {
  source = "github.com/terraform-google-modules/terraform-google-container-vm"

  container = {
    image= var.app_image
    env = [
      {
        name = "DB_NAME"
        value = google_sql_database.users-service.name
      },
      {
        name = "DB_USER"
        value = google_sql_user.users-service.name
      },
      {
        name = "DB_PASS"
        value = google_sql_user.users-service.password
      },
      {
        name = "DB_WRITE_HOST"
        value = google_sql_database_instance.users-service-master.private_ip_address
      },
      {
        name = "DB_READ_HOST"
        value = google_sql_database_instance.users-service-replica-id.private_ip_address
      },
      {
        name = "COUNTRY_CODE"
        value = "id"
      },
      {
        name = "APP_PORT"
        value = 8080
      },
      {
        name = "DB_DIALECT"
        value = "mysql"
      },
    ]
  }

  restart_policy = "Always"
}


# # google_compute_instance_template.users-service-id-template:
resource "google_compute_instance_template" "users-service-id-template" {
    machine_type         = "f1-micro"
    metadata             = {
      gce-container-declaration = module.gce-container-users-service-id.metadata_value
      google-logging-enabled    = "true"
      google-monitoring-enabled = "true"
    }
    name                 = "users-service-id-template"
    tags                 = [
        "http-server", "health-check"
    ]

    confidential_instance_config {
        enable_confidential_compute = false
    }

    disk {
      source_image = module.gce-container-users-service-id.source_image
    }

    network_interface {
      network = google_compute_network.private_network.self_link
      access_config {
        network_tier = "PREMIUM"
      }
    }

    scheduling {
        automatic_restart   = true
        on_host_maintenance = "MIGRATE"
    }

    service_account {
        email  = var.email_service_account
        scopes = [
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring.write",
            "https://www.googleapis.com/auth/service.management.readonly",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/trace.append",
        ]
    }
}

resource "google_compute_region_instance_group_manager" "users-service-mig-id" {
  name = "users-service-id"

  base_instance_name         = "users-service-id"
  region                     = "asia-southeast2"
  distribution_policy_zones  = ["asia-southeast2-a", "asia-southeast2-b"]

  version {
    instance_template = google_compute_instance_template.users-service-id-template.id
  }

  target_pools = []
  target_size  = 3 

  named_port {
    name = "http"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http-health-check.self_link
    initial_delay_sec = 300
  }
}



// US
module "gce-container-users-service-us" {
  source = "github.com/terraform-google-modules/terraform-google-container-vm"

  container = {
    image= var.app_image
    env = [
      {
        name = "DB_NAME"
        value = google_sql_database.users-service.name
      },
      {
        name = "DB_USER"
        value = google_sql_user.users-service.name
      },
      {
        name = "DB_PASS"
        value = google_sql_user.users-service.password
      },
      {
        name = "DB_WRITE_HOST"
        value = google_sql_database_instance.users-service-master.private_ip_address
      },
      {
        name = "DB_READ_HOST"
        value = google_sql_database_instance.users-service-replica-us.private_ip_address
      },
      {
        name = "COUNTRY_CODE"
        value = "us"
      },
      {
        name = "APP_PORT"
        value = 8080
      },
      {
        name = "DB_DIALECT"
        value = "mysql"
      },
    ]
  }

  restart_policy = "Always"
}

# google_compute_instance_template.users-service-us-template:
resource "google_compute_instance_template" "users-service-us-template" {
    machine_type         = "f1-micro"
    metadata             = {
      gce-container-declaration = module.gce-container-users-service-us.metadata_value
      google-logging-enabled    = "true"
      google-monitoring-enabled = "true"
    }
    name                 = "users-service-us-template"
    tags                 = [
        "http-server", "health-check"
    ]

    confidential_instance_config {
        enable_confidential_compute = false
    }

    disk {
      source_image = module.gce-container-users-service-us.source_image
    }

    network_interface {
      network = google_compute_network.private_network.self_link
      access_config {
        network_tier = "PREMIUM"
      }
    }

    scheduling {
        automatic_restart   = true
        on_host_maintenance = "MIGRATE"
    }

    service_account {
        email  = var.email_service_account
        scopes = [
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring.write",
            "https://www.googleapis.com/auth/service.management.readonly",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/trace.append",
        ]
    }
}

resource "google_compute_region_instance_group_manager" "users-service-mig-us" {
  name = "users-service-us"

  base_instance_name         = "users-service-us"
  region                     = "us-central1"
  distribution_policy_zones  = ["us-central1-a", "us-central1-b"]

  version {
    instance_template = google_compute_instance_template.users-service-us-template.id
  }

  target_pools = []
  target_size  = 0 #simulate region outage

  named_port {
    name = "http"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http-health-check.self_link
    initial_delay_sec = 300
  }
}


// ============================== End Users Service =====================================





# // ============================== Start Setup VPC Access Connector =====================================

resource "google_vpc_access_connector" "asia-southeast2-connector" {
    provider = google-beta
    ip_cidr_range  = "10.8.0.0/28"
    name           = "asia-southeast2-connector"
    network        = google_compute_network.private_network.name
    region         = "asia-southeast2"
    machine_type = "f1-micro"
    max_instances = 3
    min_instances = 2
}

resource "google_vpc_access_connector" "us-central1-connector" {
    provider = google-beta
    ip_cidr_range  = "10.9.0.0/28"
    name           = "us-central1-connector"
    network        = google_compute_network.private_network.name
    region         = "us-central1"
    machine_type = "f1-micro"
    max_instances = 3
    min_instances = 2
}

// ============================== End Setup VPC Access Connector =====================================





// ============================== Start Payment Service =====================================
// Indonesia
resource "google_cloud_run_service" "payments-service-id" {
  name     = "payments-service-id"
  location = "asia-southeast2"
  project = var.project_id

  template {
    spec {
      containers {
        image = var.app_image

        env {
          name = "DB_NAME"
          value = google_sql_database.payments-service-id.name
        }
        env {
          name = "DB_USER"
          value = google_sql_user.payments-service-id.name
        }
        env {
          name = "DB_PASS"
          value = google_sql_user.payments-service-id.password
        }
        env {
          name = "DB_WRITE_HOST"
          value = google_sql_database_instance.payments-service-id-master.private_ip_address
        }
        env {
          name = "DB_READ_HOST"
          value = google_sql_database_instance.payments-service-id-master.private_ip_address
        }
        env {
          name = "COUNTRY_CODE"
          value = "id"
        }
        env {
          name = "DB_DIALECT"
          value = "mysql"
        }
        env {
          name = "APP_PORT"
          value = 8080
        }
      }
    }

    metadata {
        annotations = {
          "autoscaling.knative.dev/maxScale"        = "2"
          "autoscaling.knative.dev/minScale"        = "1"
          "run.googleapis.com/client-name"          = "cloud-console"
          "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.asia-southeast2-connector.self_link
          "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_vpc_access_connector.asia-southeast2-connector
  ]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  service     = google_cloud_run_service.payments-service-id.name
  location    = google_cloud_run_service.payments-service-id.location
  project     = google_cloud_run_service.payments-service-id.project

  policy_data = data.google_iam_policy.noauth.policy_data
}


// US
resource "google_cloud_run_service" "payments-service-us" {
  name     = "payments-service-us"
  location = "us-central1"
  project = var.project_id

  template {
    spec {
      containers {
        image = var.app_image

        env {
          name = "DB_NAME"
          value = google_sql_database.payments-service-us.name
        }
        env {
          name = "DB_USER"
          value = google_sql_user.payments-service-us.name
        }
        env {
          name = "DB_PASS"
          value = google_sql_user.payments-service-us.password
        }
        env {
          name = "DB_WRITE_HOST"
          value = google_sql_database_instance.payments-service-us-master.private_ip_address
        }
        env {
          name = "DB_READ_HOST"
          value = google_sql_database_instance.payments-service-us-master.private_ip_address
        }
        env {
          name = "COUNTRY_CODE"
          value = "us"
        }
        env {
          name = "DB_DIALECT"
          value = "mysql"
        }
        env {
          name = "APP_PORT"
          value = 8080
        }
      }
    }

    metadata {
        annotations = {
          "autoscaling.knative.dev/maxScale"        = "2"
          "autoscaling.knative.dev/minScale"        = "1"
          "run.googleapis.com/client-name"          = "cloud-console"
          "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.us-central1-connector.self_link
          "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_vpc_access_connector.us-central1-connector
  ]
}

resource "google_cloud_run_service_iam_policy" "noauth-us" {
  service     = google_cloud_run_service.payments-service-us.name
  location    = google_cloud_run_service.payments-service-us.location
  project     = google_cloud_run_service.payments-service-us.project

  policy_data = data.google_iam_policy.noauth.policy_data
}


// ============================== End Payment Service =====================================




// ============================== Start Network Endpoint Group =====================================
resource "google_compute_region_network_endpoint_group" "payments_service_id_asia_southeast2_neg" {
  provider              = google-beta
  name                  = "payments-service-id-asia-southeast2-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "asia-southeast2"
  cloud_run {
    service = google_cloud_run_service.payments-service-id.name
  }
}

resource "google_compute_region_network_endpoint_group" "payments_service_us_us_central1_neg" {
  provider              = google-beta
  name                  = "payments-service-us-us-central1-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = google_cloud_run_service.payments-service-us.name
  }
}



// ============================== End Network Endpoint Group =====================================




// ============================== Start Load Balancer =====================================

// Indonesia
resource "google_compute_backend_service" "payments_service_id_backend_service" {
  provider = google-beta
  project = var.project_id
  name = "payments-service-id-backend"

  description = null
  connection_draining_timeout_sec = null
  enable_cdn = false
  custom_request_headers = []

  backend {   
    group = google_compute_region_network_endpoint_group.payments_service_id_asia_southeast2_neg.id   
  }
  
  security_policy                 = null    
  log_config {
    enable      = false
    sample_rate = null
  }
}

# // US
resource "google_compute_backend_service" "payments_service_us_backend_service" {
  provider = google-beta
  project = var.project_id
  name = "payments-service-us-backend"

  description = null
  connection_draining_timeout_sec = null
  enable_cdn = false
  custom_request_headers = []

  backend {   
    group = google_compute_region_network_endpoint_group.payments_service_us_us_central1_neg.id   
  }
  
  security_policy                 = null    
  log_config {
    enable      = false
    sample_rate = null
  }
}


resource "google_compute_global_address" "geprek_kun_global_address" {
  name = "geprek-kun-load-balancer"
}


resource "google_compute_url_map" "urlmap" {
  name            = "geprek-kun-urlmap"
  default_service = module.gce-lb-https.backend_services["default"].self_link

  host_rule {
    hosts        = ["geprek-kun.rahadian.dev"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = module.gce-lb-https.backend_services["default"].self_link

    path_rule {
      paths = [
        "/users/*"
      ]
      service = module.gce-lb-https.backend_services["default"].self_link
    }

    path_rule {
      paths = [
        "/payments/id"
      ]
      service = google_compute_backend_service.payments_service_id_backend_service.self_link
    }


    path_rule {
      paths = [        
        "/payments/us"        
      ]
      service = google_compute_backend_service.payments_service_us_backend_service.self_link
    }
  }
}


module "gce-lb-https" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "~> 4.4"

  name    = "lb-geprek-kun"
  project = var.project_id
  
  target_tags = [
    "health-check"
  ]

  firewall_networks = [google_compute_network.private_network.name]
  url_map           = google_compute_url_map.urlmap.self_link
  create_url_map    = false
  
  ssl               = true
  managed_ssl_certificate_domains  = ["geprek-kun.rahadian.dev"]
  use_ssl_certificates = false

  create_address = false
  address = google_compute_global_address.geprek_kun_global_address.self_link

  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port                            = 8080
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 8080
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        { 
          group                        = google_compute_region_instance_group_manager.users-service-mig-id.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
        {
          group                        = google_compute_region_instance_group_manager.users-service-mig-us.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }

}