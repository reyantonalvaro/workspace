# ==================================================================================================================== #
#  Python Environment Setup Script
# ==================================================================================================================== #

# Define the minimum required Python version.
$pythonMinimumVersion = [version]"3.9.0"

# ==================================================================================================================== #

# Get the script directory and set it as the current location.
Set-Location -Path $PSScriptRoot
Write-Host "[WORKSPACE]:".PadRight(20) -NoNewline; Write-Host "Workspace initialized"

# ==================================================================================================================== #

# Check Python installation and version.
Write-Host "[WORKSPACE]:".PadRight(20) -NoNewline; Write-Host "Checking Python version..."
try {
    # Get the system Python version.
    $pythonVersion = [version]((python --version 2>&1) -replace 'Python ')
    Write-Host "[WORKSPACE]:".PadRight(20) -NoNewline; Write-Host "Detected Python version $pythonVersion"
    # Check if system Python meets the minimum version requirement.
    if ($pythonVersion -lt $pythonMinimumVersion) {
        Write-Host "[WORKSPACE]:".PadRight(20) -NoNewline;
        Write-Host "Error: Python $pythonMinimumVersion or higher is required" -ForegroundColor Red
        Write-Host ""
        return
    }
} catch {
    Write-Host "[WORKSPACE]:".PadRight(20) -NoNewline;
    Write-Host "Error: Python is not installed or not available in the system PATH" -ForegroundColor Red
    Write-Host ""
    return
}

# ==================================================================================================================== #

# Check if requirements.txt file exists.
if (-not (Test-Path "requirements.txt")) {
    Write-Host "[WORKSPACE]:".PadRight(20) -NoNewline;
    Write-Host "Error: requirements.txt file not found" -ForegroundColor Red
    Write-Host ""
    return
}

# ==================================================================================================================== #

# Check if virtual environment already exists.
if (-not (Test-Path "venv")) {
    Write-Host "[WORKSPACE]:".PadRight(20) -NoNewline; Write-Host "Creating virtual environment..."
    # Create a new virtual environment.
    Write-Host ""
    python -m venv venv
    . .\venv\Scripts\Activate.ps1
    # Install required packages.
    python -m pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --upgrade pip
    python -m pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt
    # Save the hash after initial installation.
    $reqHash = (Get-FileHash requirements.txt).Hash
    $reqHash | Out-File -FilePath venv\.requirements_hash -NoNewline
    Write-Host ""
} else {
    Write-Host "[WORKSPACE]:".PadRight(20) -NoNewline; Write-Host "Virtual environment already created"
    # Activate the virtual environment.
    . .\venv\Scripts\Activate.ps1
    # Check if requirements.txt has changed and update packages if necessary.
    $reqHash = (Get-FileHash requirements.txt).Hash
    $oldHash = Get-Content venv\.requirements_hash -Raw
    if ($reqHash -ne $oldHash) {
        Write-Host "[WORKSPACE]:".PadRight(20) -NoNewline; Write-Host "Updating packages..."
        Write-Host ""
        python -m pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --upgrade pip
        python -m pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt
        $reqHash | Out-File -FilePath venv\.requirements_hash -NoNewline
        Write-Host ""
    }
}

# ==================================================================================================================== #

# Change the current location to the workspace root directory.
Set-Location -Path (Resolve-Path (Join-Path $PSScriptRoot "..\..\"))

# ==================================================================================================================== #