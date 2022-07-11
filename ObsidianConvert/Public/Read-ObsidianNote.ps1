<#
.SYNOPSIS
  A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
  A longer description of the function, its purpose, common use cases, etc.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Read-ObsidianNote -File './mynote.md'

  This will return your parsed note as an object.
.PARAMETER File
  A path to the note to parse
#>
function Read-ObsidianNote {
  param (
    [System.IO.FileInfo]
    $File
  )

  Write-Debug "Parsing $($File.BaseName)"

  # Read the file
  $raw = Get-Content $File

  # Pull out the metadata from frontmatter
  # Front matter always starts on the first line and there should be at least 2
  if ($raw[0] -match '---' -and ($raw -match '---').Count -ge 2) {
    Write-Debug 'Frontmatter detected'
    for ($i = 1; $i -lt $raw.Count; $i++) {
      if ($raw[$i] -match '---') {
        $raw_yaml = $raw[1..($i - 1)]
        $post = $raw[($i + 1)..($raw.Count)]
        break
      }
    }
    $fm = $raw_yaml | ConvertFrom-Yaml
  } else {
    # No frontmatter, set these to work on below
    $fm = @{}
    $post = $raw
    Write-Warning ("{0} is missing frontmatter! It won't be published." -f $File.BaseName)
  }

  # Check for title and add/remove as necessary
  if ($post[0] -match '^#') {
    Write-Host 'Header detected, removing'
    # if no title set, add it
    if (-Not ($fm.Contains('title'))) {
      $fm['title'] = $post[0] -replace '^#'
    }
    # Remove the header line
    $post = $post[1..($post.Count)]
  }

  # Rebuild the content
  $content = @()
  $content += '---'
  $content += $fm | ConvertTo-Yaml
  $content += '---'
  $content += $post

  return [PSCustomObject]@{
    Name = $File.BaseName
    Frontmatter = $fm
    Content = $content
    # TODO Add a list of outgoing links
  }
}
