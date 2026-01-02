# Configure the Google Cloud provider
provider "google" {
  # The GCP project to use
  project = var.GOOGLE_PROJECT
  # The GCP region to deploy resources in
  region = var.GOOGLE_REGION
}

# Create the GKE (Google Kubernetes Engine) cluster
resource "google_container_cluster" "this" {
  name     = var.GKE_CLUSTER_NAME
  location = var.GOOGLE_REGION

  initial_node_count       = 1
  remove_default_node_pool = true

  # Workload Identity configuration for GKE
  workload_identity_config {
    workload_pool = "${var.GOOGLE_PROJECT}.svc.id.goog"
  }

  # Node configuration for metadata
  node_config {
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

# Create a custom node pool for the GKE cluster
resource "google_container_node_pool" "this" {
  cluster    = google_container_cluster.this.name
  location   = google_container_cluster.this.location
  name       = var.GKE_POOL_NAME
  node_count = var.GKE_NUM_NODES
  project    = google_container_cluster.this.project

  # Node configuration
  node_config {
    machine_type = var.GKE_MACHINE_TYPE
  }
}

# Module to authenticate with GKE cluster using native Terraform module
module "gke_auth" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version = ">= 42.0.0"

  cluster_name = google_container_cluster.this.name
  location     = var.GOOGLE_REGION
  project_id   = var.GOOGLE_PROJECT

  depends_on = [
    google_container_cluster.this
  ]
}

# Data source to retrieve the current Google client configuration
data "google_client_config" "current" {}

# Data source to fetch details about the created GKE cluster
data "google_container_cluster" "main" {
  name     = google_container_cluster.this.name
  location = var.GOOGLE_REGION
}
