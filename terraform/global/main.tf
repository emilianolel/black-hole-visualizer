###############################################################################
# Global — Enables GCP APIs and creates the Terraform Service Account
###############################################################################

locals {
  project_id = var.project_id
  region     = var.region
}

# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset(var.gcp_service_apis)

  project                    = local.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Get current project data (like numeric ID)
data "google_project" "project" {
  project_id = local.project_id
}

# Cloud Composer 2 requires a special permission for its Google-managed Service Agent
# This role allows the agent to manage SAs for the Composer environment nodes.
resource "google_project_iam_member" "composer_agent_v2_ext" {
  project = local.project_id
  role    = "roles/composer.ServiceAgentV2Ext"
  member  = "serviceAccount:service-${data.google_project.project.number}@cloudcomposer-accounts.iam.gserviceaccount.com"

  depends_on = [google_project_service.apis]
}

###############################################################################
# Terraform Administration Service Account
# This SA replaces the use of personal accounts for managing infrastructure.
# It is used via impersonation: your personal account delegates to this SA.
###############################################################################

resource "google_service_account" "terraform_admin" {
  account_id   = "terraform-admin"
  display_name = "Terraform Admin — Data infrastructure management"
  description  = "SA used by Terraform to create and manage all resources in the data project."
  project      = local.project_id
}

# Necessary roles for the SA to manage simplified services
locals {
  terraform_admin_roles = [
    "roles/bigquery.admin",
    "roles/storage.admin",
    "roles/dataproc.admin",
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.securityAdmin",
    "roles/iap.tunnelResourceAccessor",
  ]
}

resource "google_project_iam_member" "terraform_admin_roles" {
  for_each = toset(local.terraform_admin_roles)

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_admin.email}"
}

# Allows your personal account (or group) to impersonate this SA
# Substitute var.terraform_operators with the emails that need access
resource "google_service_account_iam_binding" "impersonation" {
  service_account_id = google_service_account.terraform_admin.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = var.terraform_operators
}

# Allows personal accounts to use IAP tunneling
resource "google_project_iam_member" "iap_tunnel_accessor" {
  for_each = toset(var.terraform_operators)
  project  = local.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = each.value
}
