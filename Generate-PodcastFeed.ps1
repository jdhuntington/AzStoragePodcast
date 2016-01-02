[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$StorageAccount,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$Container,
    [switch]$Pretend
)

$ErrorActionPreference = "Stop"

Function Get-MediaFiles($Context, $_Container) {
    Write-Debug "Connecting to $($_Container)."
    $contents = Get-AzureStorageBlob -Container $_Container -Context $Context -MaxCount 10000 | `
      Where-Object { $_.Name -like '*.mp3' -or $_.Name -like '*.m4a' }
    return $contents
}

Function Get-ContextForAccount($_StorageAccount) {
    $StorageKey = (Get-AzureStorageKey -StorageAccountName $_StorageAccount).Primary
    $_Context = New-AzureStorageContext -storageaccountname $_StorageAccount -storageaccountkey $StorageKey
    return $_Context;
}


$PREAMBLE = '<?xml version="1.0" encoding="ISO-8859-1"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
<channel>
<title>My Feed</title>
<description>My Description</description>'
$POST = '</channel>
</rss>'

Function Get-EnclosureForFile($File) {
    return @"
<item>
<title>$($File.Name)</title>
<enclosure url="$($File.ICloudBlob.Uri.AbsoluteUri)" length="$($File.Length)" type="audio/mpeg" />
<pubDate>$($File.LastModified.ToString('u'))</pubDate>
</item>
"@
}

Function Write-RSSFeed($Files) {
    $filename = [System.IO.Path]::GetTempFileName()
    Write-Verbose "Writing RSS feed to $($filename)"

    $result = ''

    # Add preamble
    $result += $PREAMBLE
    # Add pubdate
    $result += '<pubDate>'
    $result += Get-Date -Format 'u'
    $result += '</pubDate>'
    # Add items

    Foreach($file in $Files) {
        $result += Get-EnclosureForFile($file)
    }
    # Add postfix
    $result += $POST


    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
    [System.IO.File]::WriteAllLines($filename, $result, $Utf8NoBomEncoding)
    return $filename
}

Function Upload-Feed($Context, $_Container, $LocalFilename) {
    $dontcare = Set-AzureStorageBlobContent -File $LocalFilename `
      -Container $_Container `
      -Blob 'feed.xml' `
      -Context $Context `
      -Force

    $FeedBlob = Get-AzureStorageBlob -Container $_Container -Context $Context -Blob 'feed.xml'

    Write-Host "Uploaded $($FeedBlob.Length) bytes to"
    Write-Host $FeedBlob.ICloudBlob.Uri.AbsoluteUri -ForegroundColor "Cyan"
}

$Context = Get-ContextForAccount $StorageAccount
$Files = Get-MediaFiles $Context $Container
$FeedFilename = Write-RSSFeed $Files
Upload-Feed $Context $Container $FeedFilename
