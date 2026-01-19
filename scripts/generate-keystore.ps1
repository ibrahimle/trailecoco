<#
.SYNOPSIS
    EcoTrail Keystore Generation Script
    
.DESCRIPTION
    This script generates a Java Keystore (JKS) for signing Android applications.
    It prompts the user for company details and generates the keystore locally.
    
    SECURITY NOTICE:
    - This script does NOT collect any system, user, IP, or location data.
    - This script does NOT auto-fill any values.
    - All inputs are provided manually by the user.
    - The generated keystore should be kept secure and never committed to git.
    
.NOTES
    Author: EcoTrail Team
    Version: 1.0.0
#>

# =============================================================================
# CONFIGURATION
# =============================================================================
$ErrorActionPreference = "Stop"
$OutputKeystore = "ecotrail-release.jks"

# =============================================================================
# BANNER
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     EcoTrail - Android Keystore Generation Script" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will generate a Java Keystore (JKS) for signing" -ForegroundColor White
Write-Host "your Android application releases." -ForegroundColor White
Write-Host ""
Write-Host "PRIVACY NOTICE:" -ForegroundColor Yellow
Write-Host "- This script does NOT collect system information" -ForegroundColor Green
Write-Host "- This script does NOT collect IP addresses" -ForegroundColor Green
Write-Host "- This script does NOT collect location data" -ForegroundColor Green
Write-Host "- This script does NOT auto-fill any values" -ForegroundColor Green
Write-Host "- All inputs are provided manually by you" -ForegroundColor Green
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# CHECK FOR KEYTOOL
# =============================================================================
Write-Host "Checking for Java keytool..." -ForegroundColor White

$keytool = $null

# Check if keytool is in PATH
try {
    $keytool = Get-Command keytool -ErrorAction SilentlyContinue
    if ($keytool) {
        Write-Host "Found keytool in PATH: $($keytool.Source)" -ForegroundColor Green
    }
} catch {
    # Continue to check other locations
}

# Check common Java installation paths if not in PATH
if (-not $keytool) {
    $commonPaths = @(
        "$env:JAVA_HOME\bin\keytool.exe",
        "$env:ProgramFiles\Java\*\bin\keytool.exe",
        "$env:ProgramFiles(x86)\Java\*\bin\keytool.exe",
        "$env:LOCALAPPDATA\Programs\Eclipse Adoptium\*\bin\keytool.exe",
        "$env:ProgramFiles\Eclipse Adoptium\*\bin\keytool.exe",
        "$env:ProgramFiles\Microsoft\jdk-*\bin\keytool.exe"
    )
    
    foreach ($path in $commonPaths) {
        $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $keytool = $found.FullName
            Write-Host "Found keytool at: $keytool" -ForegroundColor Green
            break
        }
    }
}

if (-not $keytool) {
    Write-Host "ERROR: keytool not found!" -ForegroundColor Red
    Write-Host "Please install Java JDK and ensure JAVA_HOME is set." -ForegroundColor Yellow
    Write-Host "Download from: https://adoptium.net/" -ForegroundColor Yellow
    exit 1
}

$keytoolPath = if ($keytool -is [System.Management.Automation.ApplicationInfo]) { $keytool.Source } else { $keytool }

# =============================================================================
# COLLECT USER INPUTS (Company Details - Minimum 6 fields)
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Please provide the following company details:" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Key Alias
Write-Host "1. Key Alias" -ForegroundColor Yellow
Write-Host "   (A unique name to identify this key, e.g., 'ecotrail-release')" -ForegroundColor Gray
$keyAlias = Read-Host "   Enter Key Alias"
if ([string]::IsNullOrWhiteSpace($keyAlias)) {
    Write-Host "ERROR: Key Alias cannot be empty!" -ForegroundColor Red
    exit 1
}

# 2. Common Name (CN) - Your name or company name
Write-Host ""
Write-Host "2. Common Name (CN)" -ForegroundColor Yellow
Write-Host "   (Your full name or company name)" -ForegroundColor Gray
$commonName = Read-Host "   Enter Common Name"
if ([string]::IsNullOrWhiteSpace($commonName)) {
    Write-Host "ERROR: Common Name cannot be empty!" -ForegroundColor Red
    exit 1
}

# 3. Organizational Unit (OU)
Write-Host ""
Write-Host "3. Organizational Unit (OU)" -ForegroundColor Yellow
Write-Host "   (Department or division, e.g., 'Mobile Development')" -ForegroundColor Gray
$orgUnit = Read-Host "   Enter Organizational Unit"
if ([string]::IsNullOrWhiteSpace($orgUnit)) {
    Write-Host "ERROR: Organizational Unit cannot be empty!" -ForegroundColor Red
    exit 1
}

# 4. Organization (O)
Write-Host ""
Write-Host "4. Organization (O)" -ForegroundColor Yellow
Write-Host "   (Company or organization name)" -ForegroundColor Gray
$organization = Read-Host "   Enter Organization"
if ([string]::IsNullOrWhiteSpace($organization)) {
    Write-Host "ERROR: Organization cannot be empty!" -ForegroundColor Red
    exit 1
}

# 5. City/Locality (L)
Write-Host ""
Write-Host "5. City/Locality (L)" -ForegroundColor Yellow
Write-Host "   (City where the organization is located)" -ForegroundColor Gray
$city = Read-Host "   Enter City/Locality"
if ([string]::IsNullOrWhiteSpace($city)) {
    Write-Host "ERROR: City/Locality cannot be empty!" -ForegroundColor Red
    exit 1
}

# 6. State/Province (ST)
Write-Host ""
Write-Host "6. State/Province (ST)" -ForegroundColor Yellow
Write-Host "   (State or province name)" -ForegroundColor Gray
$state = Read-Host "   Enter State/Province"
if ([string]::IsNullOrWhiteSpace($state)) {
    Write-Host "ERROR: State/Province cannot be empty!" -ForegroundColor Red
    exit 1
}

# 7. Country Code (C)
Write-Host ""
Write-Host "7. Country Code (C)" -ForegroundColor Yellow
Write-Host "   (Two-letter country code, e.g., 'US', 'UK', 'DE')" -ForegroundColor Gray
$countryCode = Read-Host "   Enter Country Code (2 letters)"
if ([string]::IsNullOrWhiteSpace($countryCode) -or $countryCode.Length -ne 2) {
    Write-Host "ERROR: Country Code must be exactly 2 letters!" -ForegroundColor Red
    exit 1
}
$countryCode = $countryCode.ToUpper()

# =============================================================================
# COLLECT PASSWORDS
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Password Configuration" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Use strong passwords (min 6 characters)." -ForegroundColor Yellow
Write-Host "Remember these passwords - you'll need them for GitHub Secrets!" -ForegroundColor Yellow
Write-Host ""

# Store Password
Write-Host "8. Keystore Password" -ForegroundColor Yellow
Write-Host "   (Password to protect the keystore file)" -ForegroundColor Gray
$storePasswordSecure = Read-Host "   Enter Keystore Password" -AsSecureString
$storePassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePasswordSecure)
)
if ($storePassword.Length -lt 6) {
    Write-Host "ERROR: Keystore password must be at least 6 characters!" -ForegroundColor Red
    exit 1
}

# Confirm Store Password
$storePasswordConfirmSecure = Read-Host "   Confirm Keystore Password" -AsSecureString
$storePasswordConfirm = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePasswordConfirmSecure)
)
if ($storePassword -ne $storePasswordConfirm) {
    Write-Host "ERROR: Keystore passwords do not match!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Key Password
Write-Host "9. Key Password" -ForegroundColor Yellow
Write-Host "   (Password to protect the key entry)" -ForegroundColor Gray
$keyPasswordSecure = Read-Host "   Enter Key Password" -AsSecureString
$keyPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPasswordSecure)
)
if ($keyPassword.Length -lt 6) {
    Write-Host "ERROR: Key password must be at least 6 characters!" -ForegroundColor Red
    exit 1
}

# Confirm Key Password
$keyPasswordConfirmSecure = Read-Host "   Confirm Key Password" -AsSecureString
$keyPasswordConfirm = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPasswordConfirmSecure)
)
if ($keyPassword -ne $keyPasswordConfirm) {
    Write-Host "ERROR: Key passwords do not match!" -ForegroundColor Red
    exit 1
}

# =============================================================================
# DISPLAY SUMMARY
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Summary of Provided Information" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Key Alias:            $keyAlias" -ForegroundColor White
Write-Host "Common Name:          $commonName" -ForegroundColor White
Write-Host "Organizational Unit:  $orgUnit" -ForegroundColor White
Write-Host "Organization:         $organization" -ForegroundColor White
Write-Host "City/Locality:        $city" -ForegroundColor White
Write-Host "State/Province:       $state" -ForegroundColor White
Write-Host "Country Code:         $countryCode" -ForegroundColor White
Write-Host "Keystore Password:    ********" -ForegroundColor White
Write-Host "Key Password:         ********" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Is this information correct? (yes/no)"
if ($confirm.ToLower() -ne "yes" -and $confirm.ToLower() -ne "y") {
    Write-Host "Aborted by user." -ForegroundColor Yellow
    exit 0
}

# =============================================================================
# GENERATE KEYSTORE
# =============================================================================
Write-Host ""
Write-Host "Generating keystore..." -ForegroundColor White

# Build the distinguished name (DN)
$dname = "CN=$commonName, OU=$orgUnit, O=$organization, L=$city, ST=$state, C=$countryCode"

# Remove existing keystore if present
if (Test-Path $OutputKeystore) {
    Remove-Item $OutputKeystore -Force
}

# Generate keystore using keytool
# Note: keytool writes verbose output to stderr, which is normal behavior
$keytoolArgs = @(
    "-genkeypair",
    "-keystore", $OutputKeystore,
    "-alias", $keyAlias,
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-storepass", $storePassword,
    "-keypass", $keyPassword,
    "-dname", "`"$dname`""
)

# Build the command string for Start-Process
$argString = "-genkeypair -keystore `"$OutputKeystore`" -alias `"$keyAlias`" -keyalg RSA -keysize 2048 -validity 10000 -storepass `"$storePassword`" -keypass `"$keyPassword`" -dname `"$dname`""

# Run keytool using Start-Process to avoid stderr issues
$process = Start-Process -FilePath $keytoolPath -ArgumentList $argString -Wait -PassThru -NoNewWindow -RedirectStandardError "$env:TEMP\keytool_err.txt" -RedirectStandardOutput "$env:TEMP\keytool_out.txt"

# Small delay to ensure file is written
Start-Sleep -Milliseconds 500

# Check if keystore was created successfully
if (Test-Path $OutputKeystore) {
    Write-Host "Keystore generated successfully!" -ForegroundColor Green
    # Clean up temp files
    Remove-Item "$env:TEMP\keytool_err.txt" -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\keytool_out.txt" -ErrorAction SilentlyContinue
} else {
    Write-Host "ERROR: Failed to generate keystore!" -ForegroundColor Red
    if (Test-Path "$env:TEMP\keytool_err.txt") {
        $errorContent = Get-Content "$env:TEMP\keytool_err.txt" -Raw
        if ($errorContent) {
            Write-Host $errorContent -ForegroundColor Red
        }
    }
    # Clean up temp files
    Remove-Item "$env:TEMP\keytool_err.txt" -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\keytool_out.txt" -ErrorAction SilentlyContinue
    exit 1
}

# =============================================================================
# ENCODE KEYSTORE TO BASE64
# =============================================================================
Write-Host ""
Write-Host "Encoding keystore to Base64..." -ForegroundColor White

$keystoreBytes = [System.IO.File]::ReadAllBytes($OutputKeystore)
$keystoreBase64 = [System.Convert]::ToBase64String($keystoreBytes)

Write-Host "Keystore encoded successfully!" -ForegroundColor Green

# =============================================================================
# OUTPUT INSTRUCTIONS
# =============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "     KEYSTORE GENERATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Keystore file: $OutputKeystore" -ForegroundColor White
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     GITHUB SECRETS CONFIGURATION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Add the following secrets to your GitHub repository:" -ForegroundColor Yellow
Write-Host "(Settings > Secrets and variables > Actions > New repository secret)" -ForegroundColor Gray
Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host "Secret Name: ECOTRAIL_KEYSTORE_BASE64" -ForegroundColor Cyan
Write-Host "Secret Value:" -ForegroundColor White
Write-Host ""
Write-Host $keystoreBase64 -ForegroundColor Gray
Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host "Secret Name: ECOTRAIL_KEY_ALIAS" -ForegroundColor Cyan
Write-Host "Secret Value: $keyAlias" -ForegroundColor White
Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host "Secret Name: ECOTRAIL_KEY_PASSWORD" -ForegroundColor Cyan
Write-Host "Secret Value: (the key password you entered)" -ForegroundColor White
Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host "Secret Name: ECOTRAIL_STORE_PASSWORD" -ForegroundColor Cyan
Write-Host "Secret Value: (the keystore password you entered)" -ForegroundColor White
Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "     IMPORTANT SECURITY REMINDERS" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. NEVER commit the keystore file to version control!" -ForegroundColor Red
Write-Host "2. Keep a secure backup of the keystore file!" -ForegroundColor Yellow
Write-Host "3. Store the passwords in a secure password manager!" -ForegroundColor Yellow
Write-Host "4. The keystore is already in .gitignore, but verify!" -ForegroundColor Yellow
Write-Host "5. If you lose the keystore, you cannot update your app!" -ForegroundColor Red
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     VERIFICATION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To verify the keystore, run:" -ForegroundColor White
Write-Host "keytool -list -v -keystore $OutputKeystore" -ForegroundColor Gray
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "     SCRIPT COMPLETED" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

# Clear sensitive variables from memory
$storePassword = $null
$keyPassword = $null
$storePasswordConfirm = $null
$keyPasswordConfirm = $null
[GC]::Collect()
