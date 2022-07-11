<#
.SYNOPSIS
  Convert an Obsidian vault to a format for static site generation.
.DESCRIPTION
  This will take an obisdian vault and look for any markdown files with a
  published item in the front matter.
.NOTES
  Currently only supports Hugo.
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  ConvertFrom-ObsidianNote -Source $src -DestinationPath $dest

  Will convert your Obsidian notes in the $src directory and put the converted
  notes into the $dest folder.
.PARAMETER Source
  The path to your obsidiain vault that you want to convert.
.PARAMETER DestinationPath
  Where the output files will be put. Something like your Hugo content folder.
#>
function ConvertFrom-ObsidianNote {
  [CmdletBinding(SupportsShouldProcess = $True)]
  param (
    [ValidateScript({
        if ( -Not ($_ | Test-Path) ) {
          throw 'File or folder does not exist'
        }
        return $true
      })]
    [System.IO.FileInfo]
    $Source,
    [ValidateScript({
        if ( -Not ($_ | Test-Path) ) {
          throw 'File or folder does not exist'
        }
        return $true
      })]
    [System.IO.FileInfo]
    $DestinationPath
  )

  # Get current directory
  Set-Location $PSScriptRoot

  # Clean up destination directory
  Get-ChildItem -Recurse $DestinationPath | ForEach-Object {
    if ($PSCmdlet.ShouldProcess($_, 'Delete')) {
      Remove-Item -Recurse -Force $_
    }
  }

  # Get all the notes
  $notes = Get-ChildItem -Recurse $Source -File -Filter '*.md'
  Write-Debug "Notes detected: $($notes.BaseName -join ',' )"

  $notes | ForEach-Object {
    # Parse Each Note
    $note = ParseNote $_

    # Skip if missing frontmatter
    if (-Not($note.Frontmatter)) { continue }
    # Skip is missing posted frontmatter value or is false
    if (-Not ($note.Frontmatter.published)) { continue }

    # Using the relative path will allow us to keep the
    $relative = (Resolve-Path $_ -Relative) -replace '^./', ''
    # Construct the final location for the file in the destination
    $destination = Join-Path (Resolve-Path $DestinationPath) $relative
    Write-Debug "Destination: $destination"

    # Create the destination folder recursively if it is missing
    $destFolder = Split-Path $destination
    if (-Not(Test-Path $destFolder)) {
      if ($PSCmdlet.ShouldProcess($destFolder, 'Creating folder')) {
        New-Item -ItemType Directory -Path $destFolder
      }
    }

    # Dump the processed note to the destination
    if ($PSCmdlet.ShouldProcess($destination, 'Set the content')) {
      Set-Content -Value (ConvertLinks $note.Content) -LiteralPath $destination
    }
  }
}
