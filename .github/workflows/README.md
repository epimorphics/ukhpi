# github-workflows

This repository is intended to hold common github workflow scripts.

Each customer installation has its own branch. There is also a branch `expt` for publishing to our own ECR registry.

The workflow should be installed into a applications repository using
git-subrepo. See https://github.com/ingydotnet/git-subrepo#installation-instructions.


To copy this subrepo into an application's repository:
```
git subrepo clone git@github.com:epimorphics/github-workflows.git .github/workflows -b hmlr
```

To update this subrepo in an application's repository:
```
git subrepo pull .github/workflows
```

## Requirements

### Makefile 

This sub-repository makes certain requirements of the application `Makefile`.

|Target|Result|
|---|---|
| tag | Output the docker tag of the image to be published or deployed |
| image | Build the docker image |
| publish | Write the docker image to ECR |

### deployment.yaml

The mapping of application source repository branch/tag to published ECR location and deployed environment is controlled by the `deployment.yaml` configuration file. For the specification of this file see [here](https://github.com/epimorphics/deployment-mapper#version-2).
