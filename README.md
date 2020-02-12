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

See the [workflows](#workflows) section for how these tools are usually used
together.
See the [tools](#tools) section for a description of each tool and sample usage.

## Path Overview
These tools are designed to live in `~/bin`, I haven't spent the time to have
them fish for their own locations. I'm not a huge fan of `bash` and would rather
use either portable `sh` or `perl`.

They're built on top of `hg`, but you could probably make an `hg`
script / symlink that runs `git` w/ minimal effort.

## Tools

f:

- Finds potentially misspelled words in a repository/directory:
  * `f repository`
- Runs `w` on files (excludes repositories / certain file types)

fchurn:

- Find newly misspelled words in a repository since the last run:
  * `fchurn repository`

dchurn:

- Find newly misspelled words in a diff:
  * `d|dchurn`

rediff:

- Find word changes from a diff:
  * `d -U0 -c.|rediff`

w:

- Generate a list of tokens that might be misspelled
- You will need to feed this to another tool (`Google Suggest`, `MS Word`, ..., or
  your head) to decide what's actually a misspelling

g:

- Find instances of token in corpus (including as substrings of other words):
  * `g woord`

ge:

- Find instances of word in corpus (this excludes substring word matches):
  * `ge exclu`

gl:

- Extract filenames from file prefixed grep output:
  * `g 'something' | gl` ~ `grep -ilr something . `

rs:

- Replace and commit spelling fix:
  * `rs teh the` ~ `r 's{teh}{the}' $(g teh -l); s the`
  * `rs 'thi s' 'this ' this` ~ `r 's{thi s}{this }' $(g 'thi s' -l); s this`

r:

- Run replace token with correction on FILES:
  * `r s/woord/word/ FILES`

s:

- Commit a spelling fix:
  * `s word`

b:

- Commit a brand fix:
  * `b JavaScript`

d:

- Diff:
  * `d -U0 -c.`

dn:

- Select only new lines from diff output:
  * `d | dn | w`

hesort:

- Sort spelling commits:
  * `EDITOR=hesort hg histedit ignore`
  * `EDITOR=hesort hg histedit -r 'spelling % ignore'`

chore-spelling:

- Prefix spelling: commits with chore:
  * `chore-spelling 'spelling % master'`

signed-off-by:

- Add 'signed-off-by: user@address':
  * `SIGNED_OFF_BY="Signed-off-by: user <user@example.com>" signed-off-by 'spelling % master'`

splitter:

- Convert patches (standard input or arguments) into numbered patch files

hgfileexts:

- Report file extensions in repository

hgfilesample:

- Run `less` with one file for each file type from `hgfileexts`
- Use this to identify binary file types to be excluded

hgmv:

- Rename files:
  * `hgmv Javascript JavaScript`

hgrmjunk:

- Delete files that should not be spellchecked

convertpatch-to:

- Convert existing Mercurial commits into other commands
- this is mostly used for transplanting or replaying a common set of replacements against another repository:

    ```
    # working directory is terraform-provider-google
    # sibling directory is magic-modules
    # Input is a sequence of commits here:
    #   https://github.com/terraform-providers/terraform-provider-google/pull/4235
    # Output is a sequence of commits here:
    #   https://github.com/GoogleCloudPlatform/magic-modules/pull/2183
    # This gets a list of commits (in ascending order) on the spelling branch starting past the master commit
    for a in $(hg log -T '{rev} ' -r spelling%master); do
      # this line calls convertpatch-to and asks for an `rs` command
      X="$(MODE=rs convertpatch-to -c$a)";
      (
        cd ../magic-modules/;
        # this line runs that command in the magic-modules directory
        sh -c "$X"
      ) 2>&1
    done |perl -ne 'next if /^Required ruby|^To install do/;print'
    # the last perl is because `magic-modules/.ruby-version` triggers annoying warnings that I don't care about
    ```

wdiff:

- Compare misspellings in two files:
  * `wdiff file.orig file`

wreview:

- See potentially misspelled words highlighted from each file:
  * `wreview FILE`

## Prerequisites
* find
* grep
* hg
* less
* perl
* sh
* sort
* uniq
* xargs

## Workflows

### Short workflow

* Browse output of `f` in one window (word list).
* Have a Terminal ready for commits (edit stream).
*  Have a window for getting spelling corrections (Browser URL bar)

1. Start with the word list.
1. Copy a token (`acecss`).
1. Switch to edit stream terminal.
1. `g `(paste)`acecss`↵
1. `rs acecss  ` (including a trailing space).
1. Switch to web browser (focussing URL Bar or a text editor).
1. (paste)`acecss`
1. Get suggested corrected spelling (e.g. down arrow).
1. Copy
1. Switch back to edit stream terminal.
1. Paste:
  `rs acecss access` ↵
1. Switch back to tokenlist window and repeat process.

### Detailed workflow

I tend to do:

```sh
hg clone git@github.com:jsoref/spelling.git
# get a repository to work on
cd spelling
hg bookmark ignore
# exclude content that shouldn't be spellchecked
hg rm vendor ...
# upstream content
hgrmjunk
# various file types including pictures
hgfilesample
hg rm `hg locate '*.dmg'` ...
# binary content
hg commit -m ignore
hg bookmark spelling
# mark our work
f > ../spelling.txt
# build token list
less ../spelling.txt &
# start looking at the list
ge absolut # because `g absolut` would find `absolute`
# look for a whole misspelled word
rs 'absolut ' 'absolute ' absolute
# correct it
g Actualy
# look for substring
rs Actualy Actually
# correct it
g addess
# look for substring
rs addess address
rs Addess Address
rs ADDESS ADDRESS
# correct each variant
EDITOR=hesort hg histedit ignore
# collapse the fixes
...
# JavaScirpt
g Scirpt
rs Scirpt Script
# JaveScript
g Jave
rs Jave Java
g Javascript
r s/Javascript/JavaScript/g $(g Javascript -l)
b JavaScript
# tag branding fix differently (it will sort elsewhere)
...
ge thi
r 's/thi s/this /g' $(ge thi|gl)
d
# verify the change didn't mess something else up
s this
# commit
...
hg rebase -r 'spelling % ignore' -d master
# exclude the ignore commit(s) and return to master
```

### Dev workflow
If you're reviewing patches:

```sh
fchurn repository
patch -d repository -p1 < proposed-commit
fchurn repository
```

If you're trying to catch typos before you commit:

```sh
fchurn repository
pushd repository
# make changes
...
popd
fchurn repository
```

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
