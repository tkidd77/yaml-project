<#

.SYNOPSIS

Changes the image version number of a named package in a YAML file and outputs a new YAML file.



.DESCRIPTION

Written by Tim Kidd
tkidd77@gmail.com
https://github.com/tkidd77

The script is to be used to increment any or all parts of a version number in a YAML file. Currently one package name can be processed at a time.



.PARAMETER inputfile

The source file with the old image version



.PARAMETER outpath

The new file to be output with the old image version



.PARAMETER name

The name of the package for which the version is to be incremented.



.PARAMETER versionmajor

The part of the version number to increment. first octet: x.n.n

Use an int32. A 1 increments the version number 1, and a 2 increments it by 2, and so on.

Omit parameter or set to 0 if no version change needed. octet will be incremented by 0 either way.



.PARAMETER versionminor

The part of the version number to increment. second octet: n.x.n

Use an int32. A 1 increments the version number 1, and a 2 increments it by 2, and so on.

Omit parameter or set to 0 if no version change needed. octet will be incremented by 0 either way.



.PARAMETER versionbuild

The part of the version number to increment. second octet: n.n.x

Use an int32. A 1 increments the version number 1, and a 2 increments it by 2, and so on.

Omit parameter or set to 0 if no version change needed. octet will be incremented by 0 either way.



.EXAMPLE

Increment the build version by 1 for package "advisorUi":

C:\Users\rocke\Downloads\fsscript.ps1 -name advisorsapi -outputfile $env:userprofile\Downloads\modified.yaml -inputfile $env:userprofile\Downloads\example.yaml -imagename dockerTag -versionmajor 0 -versionminor 0 -versionbuild 1



.NOTES

This script has only been tested on Powershell v5

You need to run this script in an elevator Powershell session as it requires the installation of a third party module to properly parse the YAML.

Known issue: All empty lines in source YAML file are removed in output file. This is due to hashtable created by the powershell-yaml module using a hashtable object type to store the YAML so that Powershell can properly address and  it.

The PSYAML module was not used in this script due to its YAML formatting limitations. The powershell-yaml module was used instead. This post was helpful in understadning the differences between the two modules: http://dbadailystuff.com/yaml-in-powershell



#>


# Parameters
  Param(
  [Parameter(Mandatory=$true)]
  [string]$name = $(Throw "Please provide package name"),
  [Parameter(Mandatory=$true)]
  [string]$outputfile = $(Throw "Please provide output file"),
  [Parameter(Mandatory=$true)]
  [string]$inputfile = $(Throw "Please provide input file"),
  [Parameter(Mandatory=$true)]
  [string]$imagename = $(Throw "Please provide image name"),
  [int]$versionmajor,
  [int]$versionminor,
  [int]$versionbuild
)

# Install and import "psyaml" module to allow us to easily process YAML files.
Install-Module powershell-yaml -WarningAction SilentlyContinue -Force
Import-Module powershell-yaml
# Get content from file and import into a hashtable variable in ordered JSON format
$yaml = Get-Content -Raw $inputfile | ConvertFrom-YAML -Ordered
# Change version in hashtable based on app name in parameter
# Current version
$loopversion = $yaml.$name.image."$imagename".ToString()
# Remove "v" from version number
$currentVersionString = ($loopversion).Trim("v")
# Set to Powershell object type "system.version"
$currentVersion = [version]$currentversionstring
# Bump version number accordingly
$newVersion = (New-Object -TypeName 'System.Version' -ArgumentList @(($currentversion.Major+"$versionmajor"), ($currentversion.Minor+"$versionminor"), ($currentversion.Build+"$versionbuild")))
# Set version number back to a string in order to update $yaml varaible
$newVersionstring = $newVersion.ToString()
# Set YAML version key value
$yaml.$name.image."$imagename" = "v$newVersionstring"
# Write version number to screen
"$name " + " $currentVersionString" + " -> " + $yaml.$name.image."$imagename"
# Create modified yaml file - overwrite existing
ConvertTo-YAML -data $yaml -OutFile $outputfile -Force
