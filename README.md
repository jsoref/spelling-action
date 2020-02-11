# Spell Checker GitHub Actions

[![Spell checking](../../workflows/Spell%20checking/badge.svg?branch=master)](https://github.com/jsoref/spelling-action/actions?query=workflow%3A%22Spell+checking%22+branch%3Amaster)

## test-spelling-unknown-words based on fchurn

[fchurn](https://github.com/jsoref/spelling/blob/master/fchurn) is the tool that I personally use to
scan repositories for misspellings. It's designed so that I can correct misspellings in a repository,
and then come back in a year and only look at new misspellings. Essentially, that's the design that
is deployed by `test-spelling-unknown-words`.

[More information](https://github.com/jsoref/spelling#overview)

### Required Configuration Variables


| Variable | Description |
| ------------- | ------------- |
| bucket | a `gsutil` or `curl` compatible url for which the tool has read access to a couple of files. |
| project      | a folder within `bucket`. This allows you to share common items across projects. |
| spellchecker | The directory where the spell checker lives -- this is where `exclude` lives |

The dictionary used is currently hard coded. It isn't terribly hard to replace as the script itself doesn't care.

## Behavior

1. This action will automatically comment on PRs with its opinion.
1. If you push a commit w/o a PR, the action will run and just leave a text report in the action (along w/ a check/fail).
