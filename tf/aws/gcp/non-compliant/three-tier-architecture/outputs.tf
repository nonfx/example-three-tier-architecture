output "endpoint" {
  value       = google_cloud_run_service.fe.status[0].url
  description = "The url of the front end which we want to surface to the user"
}
output "sqlservername" {
  value       = google_sql_database_instance.main.name
  description = "The name of the database that we randomly generated."
}

output "neos_toc_url" {
  value       = "https://console.cloud.google.com/products/solutions/deployments?walkthrough_id=panels--sic--three-tier-web-app&project=${var.project_id}"
  description = "The URL to launch the in-console tutorial for the Three Tier App solution"
}
