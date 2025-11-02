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
    source_hash      = data.archive_file.source.output_sha
    manual_build_tag = var.manual_build_tag
  }

  provisioner "local-exec" {
    command = <<-EOT
      gcloud builds submit --tag us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.app_name}:${var.manual_build_tag} --project ${var.project_id} ${path.module}/../../
      gcloud artifacts docker images describe "us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.app_name}:${var.manual_build_tag}" --format='get(image_summary.digest)' > ${path.module}/image_digest.txt
    EOT
  }
}

data "local_file" "image_digest" {
  filename   = "${path.module}/image_digest.txt"
  depends_on = [null_resource.gcloud_build]
}
