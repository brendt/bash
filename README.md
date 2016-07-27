# Bash script collection

```sh
source ~/.bash/colors.sh
source ~/.bash/ps1.sh
source ~/.bash/git-completion.sh
source ~/.bash/versionbump.sh
source ~/.bash/issue.sh
```

## Versionbump

The versionbump script adds three commands.

- patch
- minor
- major

Ech will create a version update respectively their name. By default, these commands will:

- Update master and develop branches from upstream.
- Bump the current version by updating the tag, and optionally the composer version, if set.
- Create a new release branch and merge it into master.

There's the ``--no-release`` option to prevent the last step from happening. Which is useful in early development, to create patch of minor updates without merging them into master.
