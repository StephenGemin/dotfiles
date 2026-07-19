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
    return 'develop'
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
    return 'main'
}

# my most used commands
function gac { git add --all; git commit @args }
function gacp { git add -p; git commit @args }
function gacnv { git add --all; git commit --no-verify @args }
function gac! { git add --all; git commit --amend --no-edit @args }
function gace! { git add --all; git commit --amend @args }
function gacfx { param([string]$1); git add --all; git commit --fixup $1 }
function grbo { param([string]$1); git rebase --interactive origin/$1 }
function gacpo! {
    git add --all; git commit --amend --no-edit
    if ($?) {
        git push origin --force-with-lease @args
    } else {
        Write-Host "git commit failed" -ForegroundColor Red
    }
}
function gacnvpo! {
    git add --all; git commit --amend --no-verify --no-edit
    if ($?) {
        git push origin --force-with-lease @args
    } else {
        Write-Host "git commit failed" -ForegroundColor Red
    }
}
function gds { git diff --stat @args }
function gl { param([int]$1=15); git log --oneline --graph -$1 }
function gwip { git add --all; git commit --no-verify -m "[skip ci] WIP" }

function g { git @args }
function ga { git add --all @args }
function gaa { git add @args }  # git add any
function gap { git add -p @args }  # interactive add

function gb { git branch @args }
function gbr { git branch -r @args }
function gbd { git branch -d @args }
# No gbD twin: PowerShell command names are case-insensitive, so it would
# collide with gbd. Force-delete a branch with `gb -D <branch>` instead.
function gco {git checkout @args }
function gcob { git checkout -b @args }
# No gcoB twin: PowerShell command names are case-insensitive, so it would
# collide with gcob. `-b` is the safe option (fails if the branch already
# exists); force-create/reset a branch with `gco -B <branch>` instead.
function gcod { git checkout $(git_develop_branch) }
function gcom { git checkout $(git_main_branch) }

function gcp {git cherry-pick @args }
function gcpa { git cherry-pick --abort }
function gacpc { git add --all; git cherry-pick --continue }

function gc { git commit @args }
function gc! { git commit --amend --no-edit @args }
function gce! { git commit --amend @args }
function gcfx { git commit --fixup @args }
function gcnvfx { git commit --no-verify --fixup @args }

function gd { git diff @args }
function gdn { git add -N --all; git diff @args }  # include untracked files in the diff
function gs { git status @args }
function gsh { git show @args }
function glastsha { git log -1 --pretty="%H" }
function grl { git reflog @args }

function gf { git fetch -v @args }
function gfo { git fetch origin -v @args }
function gfu { git fetch upstream -v @args }
function gpl { git pull -v @args }
function gpl! { git pull --rebase -v @args }

# aliases are set to gg because gp is a protected alias in powershell (Windows)
function gg { git push -v @args }
function ggo { git push -v origin @args }
function ggo! { git push -v origin --force @args }
function ggof { git push -v origin --force-with-lease @args }
function ggu { git push -v upstream @args }

function gma { git merge --abort }
function gmc { git merge --continue }
function gms { git merge --squash @args }
function gmff { git merge --ff-only @args }
function gmom { git merge origin/$(git_main_branch) }
function gmum { git merge upstream/$(git_main_branch) }
function gmod { git merge origin/$(git_develop_branch) }

function grb { git rebase --interactive @args }
function grba { git rebase --abort }
function garbc { git add --all; git rebase --continue }
function grbu { param([string]$1); git rebase --interactive upstream/$1 }
function grbd { git rebase --interactive origin/$(git_develop_branch) }
function grbm { git rebase --interactive origin/$(git_main_branch) }
function grbum { git rebase --interactive upstream/$(git_main_branch) }

function grs { git reset @args }
function grsh { param ([int]$num = 1); git reset HEAD~$num }
function grsh! { param ([int]$num = 1); git reset --hard HEAD~$num }
function grh! { git reset --hard @args }
function gclean! { git clean -fdx @args }

function gsts { git stash push -u @args }
function gstsp { git stash push -p @args }
function gsta { git stash apply @args }
function gstc { git stash clear }
function gstl { git stash list @args }
function gstd {
    param ([int]$Ref = 0)
    if ($Ref -gt 0) {
        git stash drop "@{$Ref}"
    } else {
        git stash drop
    }
}
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
    $CURRENT_BRANCH = git_current_branch
    git checkout $args[0]
    git branch -D $CURRENT_BRANCH
    git pull
}

function gnkfm {
    $CURRENT_BRANCH = git_current_branch
    git checkout $(git_main_branch)
    git branch -D $CURRENT_BRANCH
    git pull
}

function gnkfd {
    $CURRENT_BRANCH = git_current_branch
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
