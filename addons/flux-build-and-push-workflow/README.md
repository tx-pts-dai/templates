# flux-buld-and-push-workflow

Github workflow to build an application image, tag it and push it to an ECR repository

It's designed for repositories were build and push are triggered by:

- commits on `develop` branch (image tagged with `dev-/sha256/-/date/`)
- commits on `integration` branch (image tagged with `igr-/sha256/-/date/`)
- semver tagging (image tagged with the semver tag)

which is the case of repos deploying to our "flux" clusters

## Inputs

The parameters of this addon are:

- tbd
