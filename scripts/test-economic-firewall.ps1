$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'validate-economic.ps1') -Root $root -AsLibrary

function Copy-EconomicFixture($Path) {
  return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 12 | ConvertFrom-Json)
}

$lrn = Get-Content (Join-Path $root 'lrns/testing/LRN-CELSIUS-FAHRENHEIT-0001.json') -Raw | ConvertFrom-Json
$lifecycleBefore = $lrn.status
$lrns = @{ "$($lrn.id)@$($lrn.version)" = $lrn }
$profiles = @{}
Get-ChildItem (Join-Path $root 'economic/cost-profiles') -Filter '*.json' | ForEach-Object {
  $profile = Get-Content $_.FullName -Raw | ConvertFrom-Json
  $profiles["$($profile.profile_id)@$($profile.profile_version)"] = $profile
}

$base = Copy-EconomicFixture (Join-Path $root 'economic/events/ECO-CELSIUS-FAHRENHEIT-SIMULATION-0001.json')
$approve = Copy-EconomicFixture (Join-Path $root 'economic/events/ECO-VALIDATOR-REVIEW-APPROVE-SIMULATION-0001.json')
$reject = Copy-EconomicFixture (Join-Path $root 'economic/events/ECO-VALIDATOR-REVIEW-REJECT-SIMULATION-0001.json')
$cases = @()

$real = Copy-EconomicFixture (Join-Path $root 'economic/events/ECO-CELSIUS-FAHRENHEIT-SIMULATION-0001.json')
$real.mode = 'REAL'
$cases += @{ name = 'REAL event against ineligible LRN'; pass = @((Test-EconomicEvent $real $lrns $profiles)).Count -gt 0 }
$cases += @{ name = 'SIMULATION event against ineligible LRN'; pass = @((Test-EconomicEvent $base $lrns $profiles)).Count -eq 0 }
$validated = Copy-EconomicFixture (Join-Path $root 'economic/events/ECO-CELSIUS-FAHRENHEIT-SIMULATION-0001.json')
$validated.governance_state = 'validated'
$cases += @{ name = 'Economic event attempting validated state'; pass = @((Test-EconomicEvent $validated $lrns $profiles)).Count -gt 0 }
$active = Copy-EconomicFixture (Join-Path $root 'economic/events/ECO-CELSIUS-FAHRENHEIT-SIMULATION-0001.json')
$active.governance_state = 'active'
$cases += @{ name = 'Economic event attempting active state'; pass = @((Test-EconomicEvent $active $lrns $profiles)).Count -gt 0 }
$authority = Copy-EconomicFixture (Join-Path $root 'economic/events/ECO-CELSIUS-FAHRENHEIT-SIMULATION-0001.json')
$authority | Add-Member -NotePropertyName validation_authority -NotePropertyValue 'attempt'
$cases += @{ name = 'Economic event attempting validation authority'; pass = @((Test-EconomicEvent $authority $lrns $profiles)).Count -gt 0 }
$payable = Copy-EconomicFixture (Join-Path $root 'economic/events/ECO-CELSIUS-FAHRENHEIT-SIMULATION-0001.json')
$payable.payable_creator_balance_minor_units = 1
$cases += @{ name = 'Simulation attempting payable creator balance'; pass = @((Test-EconomicEvent $payable $lrns $profiles)).Count -gt 0 }
$reject.allocations_minor_units.review_pool = 6000
$reject.compensation_rate_minor_units = 600
$cases += @{ name = 'Validator fee changed solely by outcome'; pass = @((Test-CompensationParity @($approve, $reject))).Count -gt 0 }

$failed = @()
foreach($case in $cases) {
  $result = if($case.pass){'PASS'}else{'FAIL'}
  Write-Output "$($case.name): $result"
  if(!$case.pass){$failed += $case.name}
}
$lifecycleAfter = (Get-Content (Join-Path $root 'lrns/testing/LRN-CELSIUS-FAHRENHEIT-0001.json') -Raw | ConvertFrom-Json).status
if($lifecycleBefore -ne 'testing' -or $lifecycleAfter -ne 'testing'){throw 'ECONOMIC GOVERNANCE BLOCKER'}
if($failed.Count){throw "Economic firewall failures: $($failed -join ', ')"}
Write-Output 'ECONOMIC FIREWALL TEST PASS'
