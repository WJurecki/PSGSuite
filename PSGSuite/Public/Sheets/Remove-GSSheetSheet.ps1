﻿function Remove-GSSheetSheet {
    <#
    .SYNOPSIS
    Deletes an existing Sheet on an existing SpreadSheet

    .DESCRIPTION
    Deletes an existing Sheet on an existing SpreadSheet

    .PARAMETER SpreadsheetId
    The unique Id of the SpreadSheet to delete the Sheet from

    .PARAMETER Title
    The title of the SpreadSheet Sheet to delete

    .PARAMETER SheetId
    The SheetId of the SpreadSheet Sheet to delete

    .PARAMETER User
    The user to delete the Sheet as

    .EXAMPLE
    Remove-GSSheetSheet -SpreadsheetId $id -Title "Finance Sheet"

    Deletes the Sheet titled "Finance Sheet" from the Spreadsheet with id $id

    .EXAMPLE
    Remove-GSSheetSheet -SpreadsheetId $id -SheetId 0

    Deletes the Sheet with SheetId 0 from the Spreadsheet with id $id
    #>
    [OutputType('Google.Apis.Sheets.v4.Data.BatchUpdateSpreadsheetResponse')]
    [cmdletbinding(DefaultParameterSetName = "Name")]
    Param
    (
        [parameter(Mandatory = $true,Position = 0)]
        [String]
        $SpreadsheetId,
        [parameter(Mandatory = $true, ParameterSetName= "Name")]
        [Alias('SheetName')]
        [String]
        $Title,
        [parameter(Mandatory = $true, ParameterSetName= "Id")]
        [Int]
        $SheetId,
        [parameter(Mandatory = $false)]
        [switch]
        $Launch,
        [parameter(Mandatory = $false)]
        [Alias('Owner','PrimaryEmail','UserKey','Mail')]
        [string]
        $User = $Script:PSGSuite.AdminEmail
    )
    Begin {
        if ($User -ceq 'me') {
            $User = $Script:PSGSuite.AdminEmail
        }
        elseif ($User -notlike "*@*.*") {
            $User = "$($User)@$($Script:PSGSuite.Domain)"
        }
    }
    Process {
        try {
            if ($Title) {
                $sheetInfo = Get-GSSheetInfo -SpreadsheetId $SpreadsheetId -User $User
                $SheetId = $sheetInfo.Sheets.Properties | Where-Object Title -eq $Title | Select-Object -ExpandProperty SheetId
                if (-not $SheetId) {
                    throw "No Sheet found with title $Title"
                }
            }
            $deleteSheetRequest = Add-GSSheetDeleteSheetRequest -SheetId $SheetId
            Submit-GSSheetBatchUpdate -SpreadsheetId $SpreadsheetId -Requests $deleteSheetRequest -User $User
        }
        catch {
            if ($ErrorActionPreference -eq 'Stop') {
                $PSCmdlet.ThrowTerminatingError($_)
            }
            else {
                Write-Error $_
            }
        }
    }
}
