# -*-mode:powershell-*- vim:ft=powershell

# =============================================================================
# PowerShell functions sourced by `$profile`.
# This is a shell -> pwsh conversion
# Give the same cmd feel in pwsh as shell

function __git_prompt_git {
    $env:GIT_OPTIONAL_LOCKS = 0
    git @Args
    Remove-Item Env:\GIT_OPTIONAL_LOCKS -ErrorAction SilentlyContinue
}

function git_current_branch {
    try {
        $ref = __git_prompt_git symbolic-ref --quiet HEAD 2>$null
    } catch {
        # If not a git repo or symbolic ref fails, fallback
        $ref = __git_prompt_git rev-parse --short HEAD 2>$null
        if (-not $ref) { return }
    }
    return $ref -replace 'refs/heads/', ''
}

function git_develop_branch {
    if (-not (git rev-parse --git-dir 2>$null)) { return }

    $branches = @('dev', 'devel', 'develop', 'development')
    foreach ($branch in $branches) {
        if (git show-ref --verify "refs/heads/$branch" 2>$null) {
            return $branch
        }
    }
    return -1
}

function git_main_branch {
    if (-not (git rev-parse --git-dir 2>$null)) { return }

    $scopes = @("heads", "remotes/origin", "remotes/upstream")
    $branches = @("main", "master", "trunk", "mainline", "default", "stable")

    foreach ($scope in $scopes) {
        foreach ($branch in $branches) {
            if (git show-ref --verify "refs/$scope/$branch" 2>$null) {
                return $branch
            }
        }
    }
    return -1
}

# my most used commands
function gac { git add --all; git commit --verbose }
function gac! { git add --all; git commit --verbose --amend }
function gacfx { param([string]$1); git add --all; git commit --verbose --fixup $1 }
function grbo { param([string]$1); git rebase --interactive origin/$1 }
function gacpo { git add --all; git commit --verbose; git push origin }
function gacpo! { $b = git rev-parse --abbrev-ref HEAD; git add --all; git commit --amend; git push --force-with-lease origin --set-upstream $b }
function gacnvpo! { $b = git rev-parse --abbrev-ref HEAD; git add --all; git commit --amend --no-verify; git push origin --force-with-lease --set-upstream $b }
function gds { git diff --stat }
function gl { param([int]$1=15); git log --oneline -$1 }
function gwip { git add --all; git commit -v -m "[skip-ci] WIP" }

function g { git @args }
function ga { git add --all }
function gaa { git add @args }  # git add any

function gb { git branch @args }
function gbr { git branch -r }
function gbl { git branch -l }
function gco {git checkout @args }
function gcob { git checkout -b @args }
function gcoB {git checkout -B @args }
function gcod { git checkout $(git_develop_branch) }
function gcom { git checkout $(git_main_branch) }

function gcp {git cherry-pick @args }
function gcpa { git cherry-pick --abort }
function gcpc { git cherry-pick --continue }
function gacpc { git add --all; git cherry-pick --continue }

function gc { git commit --verbose }
function gc! { git commit --verbose --amend }
function gcfx { param([string]$1); git commit --verbose --fixup $1 }

function gd { git diff }
function gs { git status }
function gsh { git show }
function glastsha { git log -1 --pretty="%H" }

function gf { git fetch -v }
function gfo { git fetch origin }
function gfu { git fetch upstream }
function gpl { git pull -v }
function gplr { git pull --rebase -v }

# aliases are set to gg because gp is a protected alias in powershell (Windows)
function gg { git push -v @args }
function ggo { git push -v origin @args }
function ggo! { git push -v origin --force }
function ggof { git push -v origin --force-with-lease }
function ggu { git push -v upstream }

function gm { git merge @args }
function gma { git merge --abort }
function gmc { git merge --continue }
function gms { git merge --squash }
function gmff { git merge --ff-only }
function gmom { git merge origin/$(git_main_branch) }
function gmum { git merge upstream/$(git_main_branch) }
function gmod { git merge origin/$(git_develop_branch) }

function grb { git rebase --interactive @args }
function grba { git rebase --abort }
function grbc { git rebase --continue }
function garbc { git add --all; git rebase --continue }
function grbu { param([string]$1); git rebase --interactive upstream/$1 }
function grbd { git rebase --interactive origin/$(git_develop_branch) }
function grbm { git rebase --interactive origin/$(git_main_branch) }
function grbum { git rebase --interactive upstream/$(git_main_branch) }

function grs { git reset @args }
function grsh { param ([int]$num = 1); git reset HEAD~$num @args }

function gsts { git stash save }
function gstc { git stash clear }
function gstd {
    param ([int]$Ref = 0)
    if ($Ref -gt 0) {
        git stash drop "@{$Ref}"
    } else {
        git stash drop
    }
}
function gstl { git stash list }
function gstp {
    param ([int]$Ref = 0)
    if ($Ref -gt 0) {
        git stash pop "@{$Ref}"
    } else {
        git stash pop
    }
}

# more personal aliases & functions
# nkf family -> checkout to branch, nuke previous local branch, then pull
function gnkf {
    $CURRENT_BRANCH = git rev-parse --abbrev-ref HEAD;
    git checkout $args[0]
    git branch -D $CURRENT_BRANCH
    git pull
}

function gnkfm {
    $CURRENT_BRANCH = git rev-parse --abbrev-ref HEAD;
    git checkout $(git_main_branch)
    git branch -D $CURRENT_BRANCH
    git pull
}

function gnkfd {
    $CURRENT_BRANCH = git rev-parse --abbrev-ref HEAD;
    git checkout $(git_develop_branch)
    git branch -D $CURRENT_BRANCH
    git pull
}

# add-hoc
function migrate-origin {
    param([string]$NewOrigin, [string]$Branch);
    git remote remove origin
    git remote add origin $NewOrigin
    git fetch
    git checkout $Branch
    git branch --set-upstream-to=origin/$Branch $Branch
    git fetch
}
