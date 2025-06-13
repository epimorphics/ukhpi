# Now using githooks for automation

- Pre-commit hook will lint Ruby files before committing and reset[^*] if fails.
- Post-commit hook will run tests after committing and reset[^*] if fails.
- Pre-push hook to build and verify Docker images and prevent push if fails.
- Allows skipping of hooks on specific branches:
  - `hotfix`
  - `rebase`
  - `production`
- You can also manually skip hooks using the `--no-verify` flag on any branch
  commit:

    ```sh
      git commit --no-verify -m "skipping hooks on this commit"
    ```

  or

    ```sh
      git push --no-verify
    ```

## Setup

Use the following commands to enable the hooks to initiate hooks onto your local
copy of the repository, otherwise the hooks will not be triggered to run
automatically:

1. set the path to the hooks in the repository gitconfig:

    ```sh
      git config core.hooksPath '.githooks'
    ```

2. set permissions for the hooks:

    ```sh
      chmod +x .githooks/pre-commit .githooks/post-commit .githooks/pre-push
    ```

### Additional information

- <https://github.com/epimorphics/githooks/blob/main/README.md>
- <https://git-scm.com/docs/githooks>

[^*]: instructs reset to find the first parent ref of `HEAD`
