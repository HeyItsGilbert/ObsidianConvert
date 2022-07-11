function PendingDoc {
  param (
    [String]
    $Title
  )
  # TODO We need to create a temp doc so Hugo doesn't barf with maybe a link back?
  $content = @()
  $content = @()
  $content += '---'
  $content += $fm | ConvertTo-Yaml
  $content += '---'
  $content += $post
  return $content
}
