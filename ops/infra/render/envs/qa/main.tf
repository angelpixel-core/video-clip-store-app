module "web" {
  source              = "../../components/web"
  name                = "video-project-submission-app-qa"
  branch              = "development"
  build_command       = "bundle install && npm ci && bundle exec vite build"
  start_command       = "bundle exec puma -C config/puma.rb"
  health_check_path   = "/up"
  instance_type       = "free"
  region              = "oregon"
  environment_id      = var.adopted_environment_id
  auto_deploy         = true
  auto_deploy_trigger = "checksPass"
  env_vars            = local.app_env_vars
}

locals {
  base_app_env_vars = {
    DATABASE_URL = {
      value = module.database.connection_info.internal_connection_string
    }
    AWS_ACCESS_KEY_ID = {
      value = var.aws_access_key_id
    }
    AWS_SECRET_ACCESS_KEY = {
      value = var.aws_secret_access_key
    }
    AWS_REGION = {
      value = var.aws_region
    }
    AWS_BUCKET = {
      value = var.aws_bucket
    }
    AWS_FORCE_PATH_STYLE = {
      value = tostring(var.aws_force_path_style)
    }
    RAILS_LOG_TO_STDOUT = {
      value = "true"
    }
    RAILS_MASTER_KEY = {
      value = var.rails_master_key
    }
  }

  app_env_vars = var.aws_endpoint == null ? local.base_app_env_vars : merge(local.base_app_env_vars, {
    AWS_ENDPOINT = {
      value = var.aws_endpoint
    }
  })
}

module "worker" {
  count = var.enable_worker ? 1 : 0

  source        = "../../components/worker"
  name          = "video-project-submission-app-qa-worker"
  environment   = "qa"
  branch        = "development"
  start_command = "bundle exec rails solid_queue:start"
  instance_type = "free"
  region        = "oregon"
  env_vars      = local.app_env_vars
}

module "database" {
  source           = "../../components/database"
  name             = "video-project-submission-app-qa-db"
  environment      = "qa"
  database_name    = "video_project_submission_app_qa"
  database_user    = "video_project_submission_app_qa"
  plan             = "free"
  postgres_version = "18"
  region           = "oregon"
  ip_allow_list = [
    {
      cidr_block  = "0.0.0.0/0"
      description = "everywhere"
    }
  ]
}
