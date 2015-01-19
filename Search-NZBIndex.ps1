# Search-NZBIndex.ps1
# Search the NZBIndex.nl site
# Jan 2015
# If this works, this was written by Victor Vogelpoel (victor@victorvogelpoel.nl)
# If it doesn't work, I don't know who wrote this.
#
# This program is free software; you can redistribute it and/or modify it under the terms 
# of the GNU General Public License as published by the Free Software Foundation; either 
# version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with this program; 
# if not, write to the Free Software Foundation, Inc., 
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


function Search-NZBIndex
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, position=0, HelpMessage='Term to search for on NZBIndex.nl')]
        [ValidateNotNullOrEmpty()]
        [string[]]$SearchTerm,

        [Parameter(Mandatory=$false, HelpMessage='Start page to scrape for results')]
        [ValidateRange(1, 9999)]
        [int]$PageOffset = 1,

        [Parameter(Mandatory=$false, HelpMessage='Results page size')]
        [ValidateRange(1, 250)]
        [int]$PageSize = 25,

        [Parameter(Mandatory=$false, HelpMessage='Number of pages to fetch for scraping the results')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$PagesToFetch = [int]::MaxValue
    )


    $NZBIndexSearchTerms	= $SearchTerm -join ' '
    $NZBIndexPageNr 		= $PageOffset-1
    $NZBIndexPagesize 		= $PageSize
    $NZBIndexPagesToFetch 	= $PagesToFetch

    do
    {
        $searchResultsFound	= $false

        if ($NZBIndexPagesize -gt 250) { $NZBIndexPagesize = 250 }

        $nzbIndexQueryUri = New-Object Uri("http://www.nzbindex.nl/search/?q=$([System.Web.HttpUtility]::UrlEncode($NZBIndexSearchTerms))&sort=agedesc&max=$NZBIndexPagesize&p=$NZBIndexPageNr")

        $cookies			= @{'agreed' = 'true'}
        $cc 				= New-Object System.Net.CookieContainer 
        foreach ($c in $cookies.Keys)  
        {  
            $cookie 		= New-Object System.Net.Cookie $c, $cookies[$c], $nzbIndexQueryUri.AbsolutePath, $nzbIndexQueryUri.Host  
            $cc.Add($cookie)  
        }  

        $session 			= New-Object Microsoft.PowerShell.Commands.WebRequestSession  
        $session.Cookies	= $cc  

        $pageContent 		= Invoke-WebRequest -uri $nzbIndexQueryUri -WebSession $session


        $document 			= New-Object HtmlAgilityPack.HtmlDocument
        $document.LoadHtml($pageContent.Content)
    

        foreach ($td in $document.DocumentNode.SelectNodes('//td/label/..'))
        {
            $NZBtitle = [System.Web.HttpUtility]::HtmlDecode($td.selectSingleNode('label').InnerText)

            # If each search term is found in the NZB title, then continue parsing the TD block...
            if (@($NZBIndexSearchTerms -split ' ' | foreach { $NZBTitle -like "*$_*" } | where {$_ -eq $false}).Length -eq 0)
            {
                $searchResultsFound	= $true

                $nzbUrl 			= $td.SelectSingleNode("div/div/a[text()='Download']").GetAttributeValue('href', '')
                #$nzbFilename 		= (New-Object Uri($nzbUrl)).Segments | select -last 1
                #$nzbFilename 		= [System.Web.HttpUtility]::HtmlDecode($nzbFilename)

                $title 				= ($NZBTitle -split '"')[1]

                Write-Output ([PSCustomObject]@{
                    NZBTitle		= $NZBtitle
                    NZBUrl 			= $nzbUrl
                    Title 			= $title
                })
            }
        }

        $NZBIndexPageNr++
        $NZBIndexPagesToFetch--

    }
    while($NZBIndexPagesToFetch -gt 0 -and $searchResultsFound)

	
<#
.SYNOPSIS
    Perform a term search query on the NZBIndex.nl site and scrape the results.

.DESCRIPTION
    Perform a term search query on the NZBIndex.nl site and scrape the results.
	Search-NZBIndex returns zero or more PSObjects with
	- Title,
	- NZBTitle, and 
	- NZBUrl.
	
	The NZBUrl points to the NZB file on NZBIndex.nl. Download this file to
	a SABNZB or GetNZB watched directory. SABNZB or GetNZB will download the
	item you searched for.

.PARAMETER SearchTerm
	One or more terms to search for on NZBIndex.nl.

.PARAMETER PageOffset
	Optional: the start page of the search results. Default is 1.
 
.PARAMETER PageSize
	Optional: the size of the NZBIndex.nl search results page. Default is 25 (1-250).

.PARAMETER PagesToFetch
	Optional: the number of search result pages to fetch. Default is all.

.EXAMPLE
	Search-NZBIndex -SearchTerm 'Striparchief_2015', 'Nomad'

    Searches the NZBIndex.nl site for terms 'Striparchief_2015' and 'Nomad' and return results
	as PSObjects for futher processing.
	
	NZBTitle                                                     NZBUrl                                                                                     Title                                                                                    
	--------                                                     ------                                                                                     -----                                                                                    
	(Striparchief_2015_NN) - "Nomade 01 (c).nzb" [00/13] yEnc    http://www.nzbindex.nl/download/114886771/Striparchief-2015-NN-Nomade-01-c.nzb-0013.nzb    Nomade 01 (c).nzb                                                                        
	(Striparchief_2015_NN) - "Nomad 01-08 (c).nzb" [00/16] yEnc  http://www.nzbindex.nl/download/114886698/Striparchief-2015-NN-Nomad-01-08-c.nzb-0016.nzb  Nomad 01-08 (c).nzb 	

.EXAMPLE
	Search-NZBIndex -SearchTerm 'Striparchief_2015', 'Nomad' | foreach { Write-Host "Downloading NZB `"$($_.Title)`""; Invoke-WebRequest -Uri $_.NZBUrl -OutFile (Join-Path 'C:\temp\nzb\comics' $_.Title) }

	Searches the NZBIndex.nl site for terms 'Striparchief_2015' and 'Nomad' and downloads the 
	NZB file to the C:\temp\nzb\comics directory where a tool like SABNZB picks it up for
	downloading the comic from usenet.
	
.NOTES
	

.LINK
    about_DramaticNZBIndexModule
#>	
}