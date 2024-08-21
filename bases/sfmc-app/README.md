# @{{ service_name }}

## Deployment

Deployments:

- On push to `develop` branch -> Dev
- On push to `integration` branch -> Igr
- On tag `*.*.*` -> Prod

Github Environment `prod` expects the following variables to work:

- `AWS_ACCOUNT_ID`
- `AWS_OIDC_ROLE_ARN`
- `AWS_REGION`
- `IMAGE_NAME`
