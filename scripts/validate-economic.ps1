param(
  [string]$Root = (Split-Path $PSScriptRoot -Parent),
  [switch]$AsLibrary
)

function Read-EconomicJson($Path, $Errors) {
  try { return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json }
  catch { $Errors.Add("Invalid JSON: $Path"); return $null }
}

function Get-ProfileCostPerExecution($Profile) {
  $r = $Profile.resource_units
  return [int64]($r.compute + $r.payload_data_volume + $r.network + $r.temporary_storage + $r.persistent_storage + $r.external_resource_dependency + $r.reliability_redundancy + $r.security_overhead)
}

function Test-EconomicEvent($Event, $Lrns, $Profiles) {
  $errors = [System.Collections.Generic.List[string]]::new()
  foreach($blocked in @('governance_action','validation_authority','lifecycle_transition')) { if($Event.PSObject.Properties.Name -contains $blocked) { $errors.Add("$($Event.event_id): economic events cannot contain $blocked") } }
  $lrnKey = "$($Event.lrn_id)@$($Event.lrn_version)"
  $profileKey = "$($Event.cost_profile_id)@$($Event.cost_profile_version)"
  $lrn = $Lrns[$lrnKey]
  $profile = $Profiles[$profileKey]
  if($null -eq $profile) { $errors.Add("$($Event.event_id): unknown cost profile") } else {
    if($profile.lrn_id -ne $Event.lrn_id -or $profile.lrn_version -ne $Event.lrn_version) { $errors.Add("$($Event.event_id): cost profile does not match LRN ID/version") }
    $expectedCost = (Get-ProfileCostPerExecution $profile) * [int64]$Event.quantity
    if([int64]$Event.resource_cost_minor_units -ne $expectedCost) { $errors.Add("$($Event.event_id): resource cost does not match cost profile") }
  }
  if($null -ne $lrn) {
    if($Event.governance_state -ne $lrn.status) { $errors.Add("$($Event.event_id): recorded governance state does not match LRN") }
    if($Event.commercial_eligibility -ne $lrn.commercial_eligibility) { $errors.Add("$($Event.event_id): recorded commercial eligibility does not match LRN") }
  } elseif($profile -and $profile.reference_kind -ne 'simulation_fixture') { $errors.Add("$($Event.event_id): no LRN record for registered cost profile") }
  if($Event.mode -eq 'REAL') {
    if($null -eq $lrn -or $lrn.status -notin @('validated','active') -or $lrn.commercial_eligibility -ne 'eligible_by_policy') { $errors.Add("$($Event.event_id): REAL economic event is not commercially eligible") }
  }
  if($Event.mode -eq 'SIMULATION' -and [int64]$Event.payable_creator_balance_minor_units -ne 0) { $errors.Add("$($Event.event_id): simulation cannot create a payable creator balance") }
  $allocated = [int64]$Event.allocations_minor_units.creator + [int64]$Event.allocations_minor_units.platform + [int64]$Event.allocations_minor_units.governance + [int64]$Event.allocations_minor_units.review_pool
  $available = [int64]$Event.gross_minor_units - [int64]$Event.resource_cost_minor_units
  if($available -lt 0) { $errors.Add("$($Event.event_id): resource cost exceeds gross value") }
  elseif($allocated + [int64]$Event.remaining_balance_minor_units -ne $available) { $errors.Add("$($Event.event_id): allocations do not reconcile") }
  if($Event.event_type -eq 'validation_compensation') {
    foreach($field in @('review_work_units','compensation_rate_minor_units','review_decision')) { if($Event.PSObject.Properties.Name -notcontains $field) { $errors.Add("$($Event.event_id): compensation event missing $field") } }
    if($Event.PSObject.Properties.Name -contains 'review_work_units' -and $Event.PSObject.Properties.Name -contains 'compensation_rate_minor_units' -and [int64]$Event.allocations_minor_units.review_pool -ne ([int64]$Event.review_work_units * [int64]$Event.compensation_rate_minor_units)) { $errors.Add("$($Event.event_id): compensation must equal documented review work units times rate") }
  }
  return $errors
}

function Test-CompensationParity($Events) {
  $errors = [System.Collections.Generic.List[string]]::new()
  $groups = $Events | Where-Object { $_.event_type -eq 'validation_compensation' } | Group-Object { "$($_.lrn_id)|$($_.lrn_version)|$($_.review_work_units)" }
  foreach($group in $groups) {
    $amounts = @($group.Group | ForEach-Object { [int64]$_.allocations_minor_units.review_pool } | Select-Object -Unique)
    if($amounts.Count -ne 1) { $errors.Add("Compensation parity failed for equivalent review work: $($group.Name)") }
  }
  return $errors
}

function Invoke-EconomicValidation([string]$ValidationRoot) {
  $errors = [System.Collections.Generic.List[string]]::new()
  $lrns = @{}
  Get-ChildItem (Join-Path $ValidationRoot 'lrns') -Recurse -Filter '*.json' | ForEach-Object { $l=Read-EconomicJson $_.FullName $errors; if($l){$lrns["$($l.id)@$($l.version)"]=$l} }
  $profileSchema = Join-Path $ValidationRoot 'schemas/lrn-cost-profile.schema.json'
  $eventSchema = Join-Path $ValidationRoot 'schemas/economic-event.schema.json'
  $listingSchema = Join-Path $ValidationRoot 'schemas/commercial-listing.schema.json'
  $listingIds=@{}
  Get-ChildItem (Join-Path $ValidationRoot 'commercial-listings') -Filter '*.json' -ErrorAction SilentlyContinue | ForEach-Object {
    if(!(Test-Json -Path $_.FullName -SchemaFile $listingSchema)){$errors.Add("Commercial listing schema failure: $($_.Name)")}
    $listing=Read-EconomicJson $_.FullName $errors
    if($listing){
      if($listingIds.ContainsKey($listing.listing_id)){$errors.Add("Duplicate commercial listing ID: $($listing.listing_id)")}else{$listingIds[$listing.listing_id]=$true}
      $listingLrn=$lrns["$($listing.lrn_id)@$($listing.lrn_version)"]
      if($null -eq $listingLrn){$errors.Add("$($listing.listing_id): unknown LRN ID/version")}
      else {
        if($listing.governance_state -ne $listingLrn.status){$errors.Add("$($listing.listing_id): recorded governance state does not match LRN")}
        if($listing.commercial_state -eq 'commercial' -and ($listingLrn.status -notin @('validated','active') -or $listingLrn.commercial_eligibility -ne 'eligible_by_policy')){$errors.Add("$($listing.listing_id): commercial listing is not governance eligible")}
      }
    }
  }
  $profiles=@{}
  Get-ChildItem (Join-Path $ValidationRoot 'economic/cost-profiles') -Filter '*.json' -ErrorAction SilentlyContinue | ForEach-Object { if(!(Test-Json -Path $_.FullName -SchemaFile $profileSchema)){$errors.Add("Cost profile schema failure: $($_.Name)")}; $p=Read-EconomicJson $_.FullName $errors; if($p){$key="$($p.profile_id)@$($p.profile_version)"; if($profiles.ContainsKey($key)){$errors.Add("Duplicate cost profile: $key")}else{$profiles[$key]=$p}} }
  $eventIds=@{}; $events=@()
  Get-ChildItem (Join-Path $ValidationRoot 'economic/events') -Filter '*.json' -ErrorAction SilentlyContinue | ForEach-Object { if(!(Test-Json -Path $_.FullName -SchemaFile $eventSchema)){$errors.Add("Economic event schema failure: $($_.Name)")}; $e=Read-EconomicJson $_.FullName $errors; if($e){if($eventIds.ContainsKey($e.event_id)){$errors.Add("Duplicate economic event ID: $($e.event_id)")}else{$eventIds[$e.event_id]=$true}; $events += $e; foreach($error in (Test-EconomicEvent $e $lrns $profiles)){$errors.Add($error)} } }
  foreach($error in (Test-CompensationParity $events)){$errors.Add($error)}
  return $errors
}

if(!$AsLibrary) {
  $errors = Invoke-EconomicValidation $Root
  if($errors.Count){$errors | ForEach-Object {Write-Error $_}; exit 1}
  Write-Output 'ECONOMIC STRUCTURAL PASS'
}
