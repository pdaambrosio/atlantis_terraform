resource "local_sensitive_file" "private_key" {
  content         = var.local_file_content
  filename        = var.local_file_filename
  file_permission = var.local_file_permission
}