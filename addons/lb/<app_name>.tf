module "@{{ app_name }}_lb" {
  source               = "github.com/tx-pts-dai/terraform-aws-lb"
  app_url              = "@{{ app_subdomain }}"
  name                 = "@{{ app_name }}"
  vpc_id               = @{{ vpc_id }}
  subnets              = @{{ subnets }}
  zone_id              = @{{ zone_id }}
  default_target_group = {
    name = "client"
    protocol = "HTTP"
    port = 80
    health_check = {
      path = "/health"
      port = "traffic-port"
      protocol = "HTTP"
      matcher = "200"
    }
    tags = {
      Name = "Client"
      GithubRepo = "@{{ github_repo }}"
      Environmnet = "@{{ environment }}"
    }
  }
}
