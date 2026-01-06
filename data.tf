# Data source to retrieve the current Google client configuration
data "google_client_config" "current" {}

# Data source to fetch details about the created GKE cluster
data "google_container_cluster" "main" {
  name     = google_container_cluster.this.name
  location = var.GOOGLE_REGION
}
