variable project_id {
  default     = "rahadiangg-demo-ha-temp"
}

variable email_service_account {
  default = "terraform@rahadiangg-demo-ha-temp.iam.gserviceaccount.com"
}
variable locust_load_test {
  default = "asia.gcr.io/rahadiangg-demo-ha-temp/load-test-locust"
}

variable app_image {
  default = "asia.gcr.io/rahadiangg-demo-ha-temp/app-nodejs:latest"
}