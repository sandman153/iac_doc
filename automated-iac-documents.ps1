

<#
==========================================
AUTHOR: Sarath Boppudi
DATE: 18/07/2023
NAME: generateBicepReadme.ps1
VERSION: 1
COMMENT: Generate README.md for Bicep templates in automated fashion
==========================================
#>

#region cmdlets
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Template Path.")]
    [ValidateScript({Test-Path $_ -PathType leaf })][String]$templatePath
)
#endregion cmdlets

#region functions

#endregion functions

Function ValidateMetadata {
    [CmdletBinding()]
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory = $true)][string]$metadataPath            
    )
    $bValidMetadata = $true

    $requiredAttributes = 'itemDisplayName', 'description', 'summary'

    if (Test-Path $metadataPath) {

        <# Action to perform if the condition is true #>
        try {
            $metadata = Get-Content -Raw $metadataPath  | ConvertFrom-Json
            foreach ($attribute in $requiredAttributes) {
                <# $attribute is in $requiredAttributes in  #>
                if (!$($metadata.$attribute) -or $($($metadata.$attribute).length) -eq 0) {
                    Write-Error "Metadata is missing attributes: $attribute or $attribute is empty"
                    $bValidMetadata = $false
                    break
                }
            }
        }
        catch {
            $bValidMetadata = $false
        }
    }
    else {
        $bValidMetadata = $false
    }
    $bValidMetadata 
}

function BicepBuild {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$bicepPath        
    )
    $bicepDir = (Get-Item -Path $bicepPath).DirectoryName
    $bicepFileBaseName = (Get-Item -Path $bicepPath).BaseName
    $outputFile = Join-Path $bicepDir "$bicepFileBaseName`.json"
    #Write-Output "outputFN: $outputFile"
    Write-Verbose "Building ARM template $outputFile from Bicep file $bicepPath"
    az bicep Build --file $bicepPath --outfile $outputFile
    $outputFile
        
}

#endregion functions

#region main
$docName = "README"
$currentDir = "$PWD"
Write-Output "Current Working Directory '$currentDir' "
$templateDir = (Get-Item -Path $templatePath).DirectoryName;

Write-Verbose "Template Directory '$templateDir'"
Set-Location $templateDir

Write-Verbose "Detecting git root collection"

$gitRootDir = Invoke-Expression 'git rev-parse --show-toplevel' -ErrorAction SilentlyContinue
if ($gitRootDir.length -gt 0) {
    Write-Verbose "Git root directory $gitRootDir"
} else {
    Write-Verbose "Not a git repository"
}

Set-Location $currentDir
Import-Module PSDocs.Azure;

$metadataPath = Join-Path $templateDir 'metadata.json'
Write-Verbose "Metadata JSON file path:  '$metadataPath'"
#validate metadata
$ValidMetadata = ValidateMetadata -metadataPath $metadataPath

# Convert Bicep templates to ARM template
$removeARM = $false
Write-Output "templatePath: $templatePath"
#Write-Output "Valid Path: if((Get-Item $templatePath).Extension -eq '.bicep')"
$a = (Get-Item $templatePath).Extension
Write-Output "Extention: $a"
if ((Get-Item $templatePath).Extension -eq '.bicep') {
    Write-Verbose "Compiling bicep file $templatePath to ARM Template"
    $tempPath = BicepBuild -bicepPath $templatePath
    #$tempPath = $templatePath
    $removeARM = $false
}
else {
    $tempPath = $templatePath
}

Write-Verbose "Generating document for $tempPath"
Write-Output "tempPath: $tempPath"
if ($ValidMetadata) {
    $b = Get-AzDocTemplateFile -Path $tempPath
    Write-Output "Template File: $b"
    Get-AzDocTemplateFile -Path $tempPath | ForEach-Object  {
        #generate a standard name of the markdown file i.e. <name>_<version>.md
        $template = Get-Item -Path $_.TemplateFile;
        
        Write-Output "TemplateFile:  $template"
    
        #Generate Markdown file
        Invoke-PSDocument -Module PSDocs.Azure -OutputPath $templateDir -InputObject $template.FullName -InstanceName $docName
    }
}
else {
    Throw "Invalid metadata in $metadataPath"
    Exit -1
}

$outPutFilePath = Join-Path $templateDir "$docname`.md"
if (Test-Path $outPutFilePath) {
    if ($gitRootDir.length -gt 0) {
        # replace the git root dir with a relative in the generated markdown file
        Write-Verbose "replacing git root dir '$gitRootDir' with '.' in generated markdown file '$outputFilePath'"
        (Get-Content $outPutFilePath -Raw) -replace $gitRootDir, '.' | Set-Content $outputFilePath
    }
    Write-Output "Generated document '$outputFilePath"
}
else {
    Write-Output "'$outputFilePath' not found"
}

# Remove temp arm templates
if ($removeARM) {
    Write-Verbose "Remove temp ARM template $tempPath"
    Remove-Item -Path $tempPath -Force
}
#endregion main



