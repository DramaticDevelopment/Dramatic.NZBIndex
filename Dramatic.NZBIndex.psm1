# Dramatic.NZBIndex.psm1
# Scraping the NZBIndex site
# Dec 2014
# If this works, this was written by Victor Vogelpoel (victor@victorvogelpoel.nl)
# If it doesn't work, I don't know who wrote this.


#requires -version 3.0 
Set-PSDebug -Strict
Set-StrictMode -Version Latest


# Always stop at an error
$global:ErrorActionPreference 	= "Stop"


Add-Type -AssemblyName 'System.Web'


#----------------------------------------------------------------------------------------------------------------------
# Set variables
$script:thisModuleDirectory			= $PSScriptRoot								# Directory path\Dramatic.NZBIndex\

# Load the HtmlAgility Pack DLL (for easily scraping an HTML page)
Add-Type -path (Join-Path $PSScriptRoot 'HtmlAgilityPack.dll')


#----------------------------------------------------------------------------------------------------------------------
# Dot source any related scripts and functions in the same directory as this module
$ignoreCommandsForDotSourcing = @(
	'install.ps1'
)

Get-ChildItem $script:thisModuleDirectory\*.ps1 | foreach { 

	if ($ignoreCommandsForDotSourcing -notcontains $_.Name)
	{
		Write-Verbose "Importing functions from file '$($_.Name)' by dotsourcing `"$($_.Fullname)`""
		. $_.Fullname
	}
	else
	{
		Write-Verbose "Ignoring file '$($_.Name)'"
	}
}
