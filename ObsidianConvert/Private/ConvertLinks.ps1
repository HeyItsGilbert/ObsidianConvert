function ConvertLinks {
  param (
    $content
  )
  # TODO Add more output formats and maybe make it a param switch
  # TODO Allow custom outputs
  # Iterate over each line
  return $content | ForEach-Object {
    # Find links and replace them
    if ($_ -match '\[\[.*\]\]') {
      # TODO Replace with Hugo syntax
      $_ -replace '\[\[([^\[\]]+)\]\]', '[$1]({{< ref "$1" >}})'
    } else {
      $_
    }
  }
}
