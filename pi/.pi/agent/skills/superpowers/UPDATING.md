# Updating superpowers from upstream

This is the process for moving this vendored copy to a newer
`obra/superpowers` release without losing the local customizations.
[UPSTREAM.md](UPSTREAM.md) records the current base commit and what's customized.

Written so a person or an agent can follow it cold. Tools that may be missing
from PATH: `nix shell nixpkgs#rsync -c rsync ...`.

## Idea

Let git do a three-way merge in a scratch clone of upstream:

- **base**: the upstream commit recorded in UPSTREAM.md
- **ours**: base + a commit containing this directory's current contents
- **theirs**: the new upstream release

Upstream changes to text we never touched merge cleanly, and conflicts only
show up where both sides edited the same lines. The result then gets copied
back here.

## Variables

```bash
DOT=~/dotfiles
SP=$DOT/pi/.pi/agent/skills/superpowers   # this directory
UP=/tmp/superpowers-upstream               # scratch clone
BASE=<Commit from UPSTREAM.md>             # full SHA
NEW=<target tag or SHA>                    # e.g. v6.5.0; see step 1
```

## Steps

### 0. Start clean

```bash
cd $DOT && git status --short          # should be clean
git checkout -b superpowers-$NEW
```

### 1. Clone upstream and pick the target

```bash
rm -rf $UP && git clone https://github.com/obra/superpowers $UP && cd $UP
git tag --sort=-creatordate | head      # latest releases
git log --oneline $BASE..$NEW -- skills | wc -l   # how much changed
```

Read upstream's `RELEASE-NOTES.md` / release commit messages for `$BASE..$NEW`
before merging, especially for changes to `using-superpowers` (platform
mapping), `executing-plans`, `subagent-driven-development`, `writing-plans`,
and `brainstorming`.

### 2. Check that the recorded base is right

The local copy minus our customizations should match `$BASE` exactly:

```bash
rm -rf /tmp/sp-base && mkdir /tmp/sp-base
git -C $UP archive $BASE skills | tar -x -C /tmp/sp-base
diff -ru -x UPSTREAM.md -x UPDATING.md /tmp/sp-base/skills $SP
```

The diff should contain **only** the customizations listed in UPSTREAM.md.
If it has other changes, someone edited things without recording them. Decide
whether to keep each one (add it to UPSTREAM.md) or drop it.

If the base in UPSTREAM.md is missing or wrong, find it by picking the upstream
commit whose `skills/` differs least from this directory:

```bash
cd $UP
for c in $(git log --format=%h -- skills | head -300); do
  rm -rf /tmp/sp-c && mkdir /tmp/sp-c && git archive $c skills | tar -x -C /tmp/sp-c
  echo "$(diff -r -x UPSTREAM.md -x UPDATING.md /tmp/sp-c/skills $SP | wc -l) $c"
done | sort -n | head -3
```

### 3. Build "ours" and merge "theirs"

```bash
cd $UP
git checkout -b local $BASE
rsync -a --delete --exclude UPSTREAM.md --exclude UPDATING.md $SP/ skills/
git add -A skills && git -c user.name=local -c user.email=local commit -m "local customizations"
git merge --no-edit $NEW
git status --short | grep -E '^(UU|AA|DU|UD)'   # conflicts
```

Resolve each conflict:

- **Keep the intent, not the old text.** Upstream often rewrites whole
  sections. Take upstream's new version, then reapply our customization to
  it (UPSTREAM.md says what each one is for).
- If upstream renames or moves a file we customized, move the customization
  with it.
- Then `git add -A && git commit --no-edit`.

### 4. Check what the merge couldn't catch

Clean merges can still leave customizations incomplete. Check these every time:

```bash
cd $UP/skills
# 1. Planning paths: new upstream mentions of the default location.
#    Expected leftovers: only illustrative examples in executing-plans,
#    subagent-driven-development, requesting-code-review.
grep -rn 'docs/superpowers' .
# 2. Todo mapping: anything that bypasses the generic "todo" wording.
grep -rn -i 'TodoWrite\|TODO\.md\|write_todos' . | grep -v references/
# 3. The Pi reference file is still wired in, and still ours.
grep -n 'pi-tools.md' using-superpowers/SKILL.md
grep -n 'beads' using-superpowers/references/pi-tools.md
# 4. Anything else in the pi config pointing at files upstream deleted/renamed.
git -C $UP diff --name-status $BASE $NEW -- skills | grep -E '^(D|R)'
grep -rn --include='*.md' --include='*.ts' -E '<names from the line above>' \
  $DOT/pi/.pi/agent --exclude-dir=sessions --exclude-dir=superpowers
```

Also check:
- **Platform mapping mechanism.** If upstream stops using
  `references/pi-tools.md` (renames it, or folds it into `SKILL.md`), move the
  beads mapping to the new place and update the pointer in
  `pi/.pi/agent/AGENTS.md`.
- **Workspace scripts vs. out-of-repo plans.** Our plans live outside the
  project repo. `subagent-driven-development/scripts/sdd-workspace` accepts
  absolute plan paths outside the repo (as of v6.4.1). If new scripts take a
  `PLAN_FILE`, make sure they still do.
- **New skills.** List what `$NEW` adds (`git diff --name-status $BASE $NEW -- skills | grep ^A`)
  and look over any new skill for a todo tool, plan/spec paths, or a harness
  assumption that needs the same customizations.

### 5. Copy the result back

Do it in two commits, so the diff against upstream stays easy to see in dotfiles history:

```bash
cd $DOT
# 5a. Pristine upstream
rm -rf /tmp/sp-new && mkdir /tmp/sp-new && git -C $UP archive $NEW skills | tar -x -C /tmp/sp-new
rsync -a --delete --exclude UPSTREAM.md --exclude UPDATING.md /tmp/sp-new/skills/ $SP/
git add -A $SP && git commit -m "superpowers: import upstream $NEW unmodified"

# 5b. Merged result (= upstream + customizations)
rsync -a --delete --exclude UPSTREAM.md --exclude UPDATING.md $UP/skills/ $SP/
git add -A $SP && git diff --cached --stat    # should be only the customizations
```

Check it: `git diff --cached` should read like the customization list in
UPSTREAM.md, nothing more.

### 6. Update UPSTREAM.md (don't skip)

In UPSTREAM.md:
- **Current base**: new tag, full commit SHA (`git -C $UP rev-parse $NEW`),
  upstream release date (`git -C $UP log -1 --format=%ad --date=short $NEW`),
  and today's date as **Updated**.
- **Local customizations**: update file names, sections, and the
  "left alone on purpose" notes if anything moved or was added or removed.
- **History**: add a row: date, base, and a one-line summary of notable
  upstream changes and anything done differently this time.

If this process itself changed (new checks, new pitfalls), update this file too.

```bash
git add -A $SP pi/.pi/agent/AGENTS.md
git commit -m "superpowers: reapply local customizations on $NEW"
```

### 7. Try it and merge

- Run `/reload` in pi (or restart) and confirm the superpowers skills
  still list with no load warnings.
- Quick smoke test: in some repo, ask for a small plan. It should save under
  `~/work/precog/planning/<repo>/plans/` and track tasks with `br`.
- Merge the branch into `master`, delete it, and `rm -rf $UP /tmp/sp-*`.
