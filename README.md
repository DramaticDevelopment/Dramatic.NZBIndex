# Dramatic.NZBIndex
A PowerShell way of searching NZBIndex.nl and scraping results.

Copyright (C) 2015 Victor Vogelpoel - Dramatic Development

### License ###

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


**IMPORTANT: This module is still under development.**

The Dramatic.NZBIndex module provides PowerShell access to the NZBIndex.nl site.
Search for a term on NZBIndex.nl site and return the NZB Title and NZBUrl download
URL for each of the result items:

- Title
- NZBTitle
- NZBUrl

Use the NZBUrl to download the NZB file to a SABNZB watched directory in order
to download the item.

### "Dramatic"? ###
It's short for *Dramatic Development*, my coding brand.


## Installation ##
Open a PowerShell command box and run the following command to install this module straight from the GitHub repository to the WindowsPowerShell\Modules folder in the MyDocuments of your Windows user profile:

    iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/DramaticDevelopment/Dramatic.NZBIndex/master/install/install.ps1')

## Usage
    Import-Module Dramatic.NZBIndex

	# Download the found NZB file to a SABNZB watched folder
	Search-StripArchief2015NZB -searchTerm thorgal, kriss | foreach { Write-Host "Downloading NZB `"$($_.Title)`""; Invoke-WebRequest -Uri $_.NZBUrl -OutFile (Join-Path 'C:\temp\nzb\comics' $_.Title) }

	# Results:
	# NZBTitle                                                                                   NZBUrl                                                                                     Title                                                                                    
	#--------                                                                                   ------                                                                                     -----                                                                                    
	#(Striparchief_2015_TT) - "Thorgal -- Kriss Van Valnor, De Werelden Van 01-04 (c).nzb" [... http://www.nzbindex.nl/download/115197956/Striparchief-2015-TT-Thorgal-Kriss-Van-Valnor... Thorgal -- Kriss Van Valnor, De Werelden Van 01-04 (c).nzb


## Resources ##
- [NZBIndex.nl](http://NZBIndex.nl)
- Victor's vCard site [http://victorvogelpoel.nl](http://victorvogelpoel.nl)
