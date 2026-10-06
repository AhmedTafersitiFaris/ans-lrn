$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$errors = [System.Collections.Generic.List[string]]::new()
function Read-Json($path) { try { return (Get-Content $path -Raw | ConvertFrom-Json) } catch { $errors.Add("Invalid JSON: $path"); return $null } }
function Require($obj, $fields, $label) { foreach($f in $fields) { if($null -eq $obj.$f) { $errors.Add("$label missing $f") } } }
function Allowed-Transition($from,$to,$validation,$actor,$creator) {
  if($actor -eq $creator -and $to -eq 'validated') { return $false }
  if($from -eq 'proposed' -and $to -eq 'testing') { return $true }
  if($from -eq 'testing' -and $to -eq 'validated') { return $validation.Count -gt 0 }
  if($from -eq 'validated' -and $to -eq 'active') { return $validation.Count -gt 0 }
  if($from -eq 'active' -and $to -in @('suspended','retired')) { return $true }
  if($from -eq 'suspended' -and $to -eq 'active') { return $validation.Count -gt 0 }
  return $false
}

# Every JSON artifact and every schema must parse. Schema semantics are structural only.
Get-ChildItem $root -Recurse -Filter '*.json' | ForEach-Object { Read-Json $_.FullName | Out-Null }
Get-ChildItem (Join-Path $root 'schemas') -Filter '*.json' | ForEach-Object {
  $s = Read-Json $_.FullName
  if($s -and ($s.'$schema' -ne 'https://json-schema.org/draft/2020-12/schema' -or $s.type -ne 'object')) { $errors.Add("Invalid Draft 2020-12 schema marker: $($_.Name)") }
}

$ids = @{}
$lrns = Get-ChildItem (Join-Path $root 'lrns') -Recurse -Filter '*.json'
$lrnSchema = Join-Path $root 'schemas/lrn.schema.json'
if (!(Test-Path $lrnSchema)) { $errors.Add('Missing public LRN schema') }
foreach($f in $lrns) {
  $l = Read-Json $f.FullName; if(!$l){continue}
  if ((Test-Path $lrnSchema) -and !(Test-Json -Path $f.FullName -SchemaFile $lrnSchema)) { $errors.Add("LRN does not conform to public schema: $($f.Name)") }
  Require $l @('id','version','status','title','creator','scope','trigger','procedure','evidence','negative_evidence','limitations','stop_conditions','validation_event_ids','commercial_eligibility') $f.Name
  if($ids.ContainsKey($l.id)){ $errors.Add("Duplicate LRN ID: $($l.id)") } else { $ids[$l.id]=$true }
  if($l.version -notmatch '^\d+\.\d+\.\d+$'){ $errors.Add("Invalid LRN version: $($l.id)") }
  if($f.FullName -match '[\\/]examples[\\/]') {
    if($l.status -ne 'example_not_validated' -or $l.title -ne 'EXAMPLE — NOT VALIDATED' -or @($l.validation_event_ids).Count -ne 0 -or $l.commercial_eligibility -ne 'not_eligible'){ $errors.Add('Example LRN may not validate, activate, or monetize') }
  }
  if($l.status -in @('validated','active') -and @($l.validation_event_ids).Count -eq 0){ $errors.Add("$($l.id): validated/active requires validation event") }
}

$validationIds=@{}
Get-ChildItem (Join-Path $root 'validation-events') -Filter '*.json' | ForEach-Object {
  $v=Read-Json $_.FullName; if(!$v){return}; Require $v @('validation_id','lrn_id','lrn_version','validator_id','validator_role','decision','conflicts_of_interest','timestamp') $_.Name
  if($v.validation_id -notmatch '^VAL-[A-Z0-9-]+$'){ $errors.Add("Invalid validation ID: $($v.validation_id)") }
  if($validationIds.ContainsKey($v.validation_id)){ $errors.Add("Duplicate validation ID: $($v.validation_id)")}; $validationIds[$v.validation_id]=$true
}

Get-ChildItem (Join-Path $root 'state-transitions') -Filter '*.json' | ForEach-Object {
  $t=Read-Json $_.FullName; if(!$t){return}; Require $t @('event_id','lrn_id','lrn_version','from_state','to_state','actor','actor_role','reason','evidence_refs','validation_event_refs','timestamp') $_.Name
  if($t.event_id -notmatch '^STATE-[A-Z0-9-]+$'){ $errors.Add("Invalid transition ID: $($t.event_id)") }
  $creator=''; $match=$lrns | ForEach-Object { $x=Read-Json $_.FullName; if($x.id -eq $t.lrn_id){$x} } | Select-Object -First 1; if($match){$creator=$match.creator.id}
  foreach($ref in @($t.validation_event_refs)){if(!$validationIds.ContainsKey($ref)){$errors.Add("Unknown validation reference: $ref")}}
  if(!(Allowed-Transition $t.from_state $t.to_state @($t.validation_event_refs) $t.actor $creator)){ $errors.Add("Illegal transition $($t.from_state) -> $($t.to_state) in $($t.event_id)") }
}
Get-ChildItem (Join-Path $root 'audits/audit-reports') -Filter '*.json' | ForEach-Object {
  $a=Read-Json $_.FullName; if($a){Require $a @('audit_id','title','target_reference','audit_type','auditor_id','scope','evidence_refs','findings','conflicts_of_interest','recommendation','timestamp','status') $_.Name; if($a.audit_id -notmatch '^AUD-[A-Z0-9-]+$'){$errors.Add("Invalid audit ID: $($a.audit_id)")}}
}
Get-ChildItem (Join-Path $root 'audits/counter-audits') -Filter '*.json' | ForEach-Object {
  $a=Read-Json $_.FullName; if($a){Require $a @('counter_audit_id','title','original_audit_id','challenge_types','scope','evidence_refs','conflicts_of_interest','timestamp','status') $_.Name; if($a.counter_audit_id -notmatch '^CAUD-[A-Z0-9-]+$'){$errors.Add("Invalid counter-audit ID: $($a.counter_audit_id)")}}
}

# Required negative lifecycle and separation tests.
$tests=@(
  @{n='PROPOSED -> TESTING'; ok=(Allowed-Transition 'proposed' 'testing' @() 'c' 'c')},
  @{n='TESTING -> VALIDATED without event'; ok=!(Allowed-Transition 'testing' 'validated' @() 'v' 'c')},
  @{n='TESTING -> VALIDATED with event'; ok=(Allowed-Transition 'testing' 'validated' @('VAL-X') 'v' 'c')},
  @{n='VALIDATED -> ACTIVE without event'; ok=!(Allowed-Transition 'validated' 'active' @() 'v' 'c')},
  @{n='VALIDATED -> ACTIVE with event'; ok=(Allowed-Transition 'validated' 'active' @('VAL-X') 'v' 'c')},
  @{n='ACTIVE -> SUSPENDED'; ok=(Allowed-Transition 'active' 'suspended' @() 'a' 'c')},
  @{n='SUSPENDED -> ACTIVE without revalidation'; ok=!(Allowed-Transition 'suspended' 'active' @() 'v' 'c')},
  @{n='SUSPENDED -> ACTIVE with revalidation'; ok=(Allowed-Transition 'suspended' 'active' @('VAL-R') 'v' 'c')},
  @{n='ACTIVE -> RETIRED'; ok=(Allowed-Transition 'active' 'retired' @() 'a' 'c')},
  @{n='RETIRED -> ACTIVE'; ok=!(Allowed-Transition 'retired' 'active' @('VAL-R') 'v' 'c')},
  @{n='creator equals validator'; ok=!(Allowed-Transition 'testing' 'validated' @('VAL-X') 'c' 'c')},
  @{n='different validator'; ok=(Allowed-Transition 'testing' 'validated' @('VAL-X') 'v' 'c')}
)
foreach($test in $tests){if(!$test.ok){$errors.Add("Lifecycle test failed: $($test.n)")}}
if($errors.Count){ $errors | ForEach-Object {Write-Error $_}; Write-Output 'STRUCTURAL FAIL'; exit 1 }
Write-Output "STRUCTURAL PASS: $($lrns.Count) LRN record(s), $($tests.Count) lifecycle/separation tests. Structural validation is not human/operational validation."
