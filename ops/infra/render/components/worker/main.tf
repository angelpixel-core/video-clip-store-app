resource "render_background_worker" "this" {
  name          = var.name
  plan          = var.instance_type
  region        = var.region
  start_command = var.start_command

  runtime_source = {
    native_runtime = {
      runtime       = "ruby"
      repo_url      = "https://github.com/angelpixel-core/video-project-submission-app"
      branch        = var.branch
      build_command = "bundle install"
    }
  }

  env_vars = merge({
    RAILS_ENV = {
      value = var.environment
    }
  }, var.env_vars)
}
