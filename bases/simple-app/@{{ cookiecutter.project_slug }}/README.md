# foo

## Folder structure

* Application source code is stored in the [`@{{ cookiecutter.app_name }}/`](./@{{ cookiecutter.app_name }}/) folder
* Terraform code to perform infrastructure deployments is stored in the [`deploy/`](./deploy/) folder.
  * [`deploy/infra/`](./deploy/infra/) for all the app-related infrastructure.
  * [`deploy/app/`](./deploy/app/) for the Helm release that will deploy new versions of your application.

## Deployment

This project uses [GitHub Actions](https://docs.github.com/en/actions) to deploy the application and infrastructure.

The workflow is defined in [`.github/workflows/app.yaml`](.github/workflows/app.yaml) which uses a reusable workflow that is loaded from [Tamedia shared workflows](https://github.com/tx-pts-dai/github-workflows).

All the environments are deployed sequentially when pushing to the `main` branch. Please modify the workflows if you want to change the triggers. You can follow examples like [ai-tools](https://github.com/DND-IT/discovery-ai-tools) or [fuw-factsheets](https://github.com/DND-IT/fuw-factsheets).

## Testing

### Infrastructure

Testing infrastructure changes is performed on each feature branch ( `terraform plan` is run)

### Application

Manual deployment to staging environments can be performed in Github through "Actions" -> "Application" -> "Run workflow" button. Example [ai-tools](https://github.com/DND-IT/discovery-ai-tools/actions/workflows/application.yaml)
