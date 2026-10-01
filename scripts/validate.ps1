$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$lrns = Get-ChildItem (Join-Path $root 'lrns') -Recurse -Filter '*.json'
$errors = @()
foreach ($file in $lrns) {
  try { $item = Get-Content $file.FullName -Raw | ConvertFrom-Json } catch { $errors += "$($file.FullName): invalid JSON"; continue }
  foreach ($field in 'id','version','status','title','creator','scope','trigger','procedure','evidence','negative_evidence','limitations','stop_conditions','validation_event_ids') { if ($null -eq $item.$field) { $errors += "$($file.Name): missing $field" } }
  if ($file.FullName -match '[\\/]examples[\\/]') { if ($item.status -ne 'example_not_validated' -or $item.title -ne 'EXAMPLE — NOT VALIDATED') { $errors += "$($file.Name): example must be explicitly NOT VALIDATED" } }
  if ($item.status -eq 'active' -and @($item.validation_event_ids).Count -eq 0) { $errors += "$($file.Name): active LRN requires a validation event" }
}
if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "Foundation structural validation passed ($($lrns.Count) LRN record(s))."
