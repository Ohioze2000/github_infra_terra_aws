terraform {
    backend "remote" {
        hostname = "app.terraform.io"
        organization = "SlimeCloud"
        workspaces {
          name = "github_terra_infra_deploy_to_aws"
        }
    }
}