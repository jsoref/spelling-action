# Spelling tools

## Overview

Everyone makes typos. This includes people writing documentation and comments,
but it also includes programmers naming variables, functions, apis, classes,
and filenames.

Often, programmers will use `InitialCapitalization`, `camelCase`,
`ALL_CAPS`, or `IDLCase` when naming their things. When they do this, it makes
it much harder for naive spelling tools to recognize misspellings, and as such,
with a really high false-positive rate, people don't tend to enable spellchecking
at all.

This repository's tools are capable of tolerating all of those variations.
Specifically, `w` understands enough about how programmers name things that it
can split the above conventions into word-like things for checking against a
dictionary.

See the [workflows](workflows.md) section for how these tools are usually used
together.
See the [tools](#tools) section for a description of each tool and sample usage.

## Path Overview
These tools are designed to live in `~/bin`, I haven't spent the time to have
them fish for their own locations. I'm not a huge fan of `bash` and would rather
use either portable `sh` or `perl`.

They're built on top of `hg`, but you could probably make an `hg`
script / symlink that runs `git` w/ minimal effort.

## Tools

See [tools](tools.md)

## Prerequisites

See [prerequisites](prerequisites.md)

## CI Integration
It is possible to integrate this with your favorite CI. I'm slowly working on this.
My initial work was done for the [checkstyle](https://github.com/checkstyle/checkstyle/) project.
See the [Travis hook](https://github.com/checkstyle/checkstyle/blob/master/.ci/test-spelling-unknown-words.sh).

## Spell Checker GitHub Actions

[![Spell checking](https://github.com/jsoref/spelling/workflows/Spell%20checking/badge.svg?branch=master)](https://github.com/jsoref/spelling/actions?query=workflow%3A%22Spell+checking%22+branch%3Amaster)

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

# License

MIT
