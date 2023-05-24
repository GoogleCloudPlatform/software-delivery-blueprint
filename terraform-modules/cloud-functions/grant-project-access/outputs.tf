output "function_id" {
  value = google_cloudfunctions_function.function.id
  description = "Id of the function."
}

output "function_gcs" {
  value = google_storage_bucket.function_bucket.url
  description = "URL of the bucket hosting cloud function's code."
}

output "trigger_gcs" {
  value = google_storage_bucket.trigger_bucket.url
  description = "URL of the bucket that triggers the cloud function."
}
