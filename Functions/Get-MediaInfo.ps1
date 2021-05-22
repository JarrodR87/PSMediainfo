function Get-MediaInfo {
    <#
        .SYNOPSIS
            Gets Files MediaInfo
        .DESCRIPTION
            Used MediaInfo to get file mediainfo and output a PowerShell Object
        .PARAMETER Files
            Single or Multiple Files
        .EXAMPLE
            Get-MediaInfo -Files C:\Temp\File.mkv
        .EXAMPLE
            Get-MediaInfo -Files 'C:\Temp\File.mkv','C:\Temp\File.mkv'
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]$Files
    ) 
    BEGIN { 
        $MediaInfo = @()
        $ParentFolder = (Split-Path -Path $PSScriptRoot -Parent)
        $MediaInfoEXE = Join-Path $ParentFolder "MediaInfo.exe"
    } #BEGIN

    PROCESS {
        foreach ($File in $Files) {
            $MediainfoCommand = $MediaInfoEXE + ' --Output=XML --full ' + '"' + $File + '"'
            [XML]$MediaInfoXML = (Invoke-Expression $MediainfoCommand -OutVariable output)
            $MediaInfoXMLObject = $MediaInfoXML.mediainfo.media.track | where-object { $_.type -eq 'General' }

            $MediaInfoRow = $MediaInfoXMLObject | Select-Object VideoCount, AudioCount, TextCount, MenuCount, UniqueID, Video_Format_List, Video_Codec_List, Audio_Codec_List, Text_Codec_List, Text_Language_List, CompleteName, Title, Movie


            $Row = New-Object PSObject
            $Row | Add-Member -MemberType noteproperty -Name "VideoCount" -Value $MediaInfoRow.VideoCount
            $Row | Add-Member -MemberType noteproperty -Name "AudioCount" -Value $MediaInfoRow.AudioCount
            $Row | Add-Member -MemberType noteproperty -Name "TextCount" -Value $MediaInfoRow.TextCount
            $Row | Add-Member -MemberType noteproperty -Name "MenuCount" -Value $MediaInfoRow.MenuCount
            $Row | Add-Member -MemberType noteproperty -Name "UniqueID" -Value $MediaInfoRow.UniqueID
            $Row | Add-Member -MemberType noteproperty -Name "Video_Format_List" -Value $MediaInfoRow.Video_Format_List
            $Row | Add-Member -MemberType noteproperty -Name "Video_Codec_List" -Value $MediaInfoRow.Video_Codec_List
            $Row | Add-Member -MemberType noteproperty -Name "Audio_Codec_List" -Value $MediaInfoRow.Audio_Codec_List
            $Row | Add-Member -MemberType noteproperty -Name "Text_Codec_List" -Value $MediaInfoRow.Text_Codec_List
            $Row | Add-Member -MemberType noteproperty -Name "Text_Language_List" -Value $MediaInfoRow.Text_Language_List
            $Row | Add-Member -MemberType noteproperty -Name "CompleteName" -Value $MediaInfoRow.CompleteName
            $Row | Add-Member -MemberType noteproperty -Name "Title" -Value $MediaInfoRow.Title
            $Row | Add-Member -MemberType noteproperty -Name "Movie" -Value $MediaInfoRow.Movie
            $Row | Add-Member -MemberType noteproperty -Name "Size in GB" -Value ((Get-Item $File).Length / 1gb)

            $MediaInfo += $Row
        }
    } #PROCESS

    END { 
        $MediaInfo
    } #END

} #FUNCTION