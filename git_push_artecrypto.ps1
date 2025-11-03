# git_push_artecrypto.ps1
# Helper PowerShell script to commit local changes and push to the remote GitHub repo
# Usage (PowerShell pwsh.exe):
# 1) Open a PowerShell session
# 2) cd 'c:\Users\Danny\Desktop\Proyecto Baeses II V4'
# 3) ./git_push_artecrypto.ps1

param(
    [string]$RemoteUrl = 'https://github.com/Dan0162/Artecrypto.git',
    [string]$BranchName = 'fix/puja-validations',
    [string]$CommitMessage = 'Fix: enforce minimum bid and prevent lowering previous bid; add test data scripts'
)

Write-Host "Working directory: $(Get-Location)"

# Ensure Git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git command not found. Please install Git and make it available in PATH."
    exit 1
}

# Basic git setup (user can skip if already configured)
# Uncomment and edit the following lines if you need to set committer info for this machine
# git config user.name "Your Name"
# git config user.email "you@example.com"

# Initialize repo if needed
if (-not (Test-Path .git)) {
    Write-Host "No git repo found in this folder. Initializing..."
    git init
}

# Add remote if it doesn't exist or update URL if different
$existing = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Adding remote origin => $RemoteUrl"
    git remote add origin $RemoteUrl
} elseif ($existing -ne $RemoteUrl) {
    Write-Host "Remote origin exists but points to $existing. Setting to $RemoteUrl"
    git remote set-url origin $RemoteUrl
} else {
    Write-Host "Remote origin already configured: $existing"
}

# Create and switch to branch
Write-Host "Creating/switching to branch $BranchName"
git checkout -B $BranchName

# Stage changes
Write-Host "Staging all changes..."
git add -A

# Show status before commit
git status --porcelain

# Commit
Write-Host "Committing with message: $CommitMessage"
git commit -m "$CommitMessage"
if ($LASTEXITCODE -ne 0) {
    Write-Host "No changes to commit or commit failed. Exiting."
    exit 0
}

# Push to remote (force-with-lease to be safe if branch exists remotely)
Write-Host "Pushing branch $BranchName to origin..."
# If the remote is protected, you may need to authenticate (Personal Access Token) or use SSH remote.
git push --set-upstream origin $BranchName --verbose

if ($LASTEXITCODE -eq 0) {
    Write-Host "Push succeeded. Branch: $BranchName -> $RemoteUrl"
} else {
    Write-Warning "Push failed. Check credentials or remote permissions. If using HTTPS, create a Personal Access Token and use a credential manager or provide token when prompted."
}
