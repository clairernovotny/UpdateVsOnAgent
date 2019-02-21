$ErrorActionPreference = "Stop"

Function UpdateVS
{
  Param
  (
    [String]$Sku,
    [String] $VSBootstrapperURL
  )

  $exitCode = -1

  try
  {
    Write-Host "Downloading Bootstrapper ..."
    Invoke-WebRequest -Uri $VSBootstrapperURL -OutFile "${env:Temp}\vs_$Sku.exe"

    $FilePath = "${env:Temp}\vs_$Sku.exe"
    $Arguments = ('/c', $FilePath, '--update', '--quiet', '--wait' )

    Write-Host "Updating the Visual Studio Installer ..."
    $process = Start-Process -FilePath cmd.exe -ArgumentList $Arguments -Wait -PassThru
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0 -or $exitCode -eq 3010)
    {
      Write-Host -Object 'Visual Studio Updater update successful'

      $InstallPath = &"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -prerelease -property installationPath
      
      Write-Host -Object "Found installation at '$InstallPath'"

      $Arguments = ('/c', $FilePath, 'update', '--passive', '--quiet', '--norestart', '--wait', '--installPath', '`"$InstallPath`"' )

      Write-Host "Updating the Visual Studio ..."
      $process = Start-Process -FilePath cmd.exe -ArgumentList $Arguments -Wait -PassThru
      $exitCode = $process.ExitCode
      
      if ($exitCode -eq 0 -or $exitCode -eq 3010)
      {
        Write-Host -Object 'Visual Studio update successful'
        return $exitCode
      }
      else
      {
        Write-Host -Object "Non zero exit code returned by the installation process : $exitCode."  
        exit $exitCode
      }
    }
    else
    {
      Write-Host -Object "Non zero exit code returned by the installation process : $exitCode."

      # this wont work because of log size limitation in extension manager
      # Get-Content $customLogFilePath | Write-Host

      exit $exitCode
    }
  }
  catch
  {
    Write-Host -Object "Failed to update Visual Studio. Check the logs for details in $customLogFilePath"
    Write-Host -Object $_.Exception.Message
    exit -1
  }
}

$Sku = 'Enterprise'
$VSBootstrapperURL = 'https://aka.ms/vs/16/pre/vs_Enterprise.exe'

$ErrorActionPreference = 'Stop'

# Update VS
$exitCode = UpdateVS -Sku $Sku -VSBootstrapperURL $VSBootstrapperURL

# Find the version of VS installed for this instance
# Only supports a single instance
$vsProgramData = Get-Item -Path "C:\ProgramData\Microsoft\VisualStudio\Packages\_Instances"
$instanceFolders = Get-ChildItem -Path $vsProgramData.FullName

if($instanceFolders -is [array])
{
    Write-Host "More than one instance installed"
    exit 1
}

$catalogContent = Get-Content -Path ($instanceFolders.FullName + '\catalog.json')
$catalog = $catalogContent | ConvertFrom-Json
$version = $catalog.info.id
Write-Host "Visual Studio version" $version "installed"

exit $exitCode