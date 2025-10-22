# This resource archives the application source code to generate a hash.
# This hash is used as a trigger for the build and as the image tag.
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/../../src"
  output_path = "${path.module}/source.zip"
}

# This resource triggers a new Cloud Build whenever the source code hash changes.
resource "null_resource" "gcloud_build" {
  triggers = {
    source_hash = data.archive_file.source.output_sha
  }

  provisioner "local-exec" {
    command = "gcloud builds submit --tag us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.app_name}:${data.archive_file.source.output_sha} --project ${var.project_id} ${path.module}/../../"
  }
}
