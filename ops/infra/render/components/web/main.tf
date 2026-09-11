resource "render_web_service" "this" {
  name              = var.name
  plan              = var.instance_type
  region            = var.region
  environment_id    = var.environment_id
  health_check_path = var.health_check_path
  start_command     = var.start_command

  runtime_source = {
    native_runtime = {
      runtime             = "ruby"
      repo_url            = "https://github.com/angelpixel-core/video-clip-store-app"
      branch              = var.branch
      build_command       = var.build_command
      auto_deploy         = var.auto_deploy
      auto_deploy_trigger = var.auto_deploy_trigger
      build_filter = {
        paths = [
          "app/**",
          "bin/**",
          "config/**",
          "db/**",
          "lib/**",
          "public/**",
          "Gemfile",
          "Gemfile.lock",
          "package.json",
          "package-lock.json",
          "vite.config.ts",
          "config/vite.json",
        ]
        ignored_paths = [
          "docs/**",
          "spec/**",
          "*.md",
          "README.md",
          ".github/**",
          "env/**",
          "ops/**",
          ".DS_Store",
        ]
      }
    }
  }

  env_vars = var.env_vars
}
