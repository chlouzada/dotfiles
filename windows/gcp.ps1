[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$scriptDirectory = if ($PSScriptRoot) {
    $PSScriptRoot
}
elseif ($PSCommandPath) {
    Split-Path -Parent $PSCommandPath
}
else {
    (Get-Location).Path
}
$cacheFile = Join-Path $scriptDirectory 'gcp-cache.json'
$firebaseCommand = $null

function Invoke-FirebaseJson {
    param(
        [Parameter(Mandatory)]
        [string[]] $Arguments
    )

    $process = $null

    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $script:firebaseCommand
        $startInfo.Arguments = ($Arguments | ForEach-Object { '"' + ($_ -replace '"', '\"') + '"' }) -join ' '
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $startInfo
        [void] $process.Start()
        $outputTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()

        $spinner = @('|', '/', '-', '\')
        $spinnerIndex = 0
        while (-not $process.HasExited) {
            Write-Host ("`b{0}" -f $spinner[$spinnerIndex]) -NoNewline -ForegroundColor DarkGray
            $spinnerIndex = ($spinnerIndex + 1) % $spinner.Count
            Start-Sleep -Milliseconds 100
        }

        $process.WaitForExit()
        $exitCode = $process.ExitCode
        $json = $outputTask.Result
        $stderr = $stderrTask.Result.Trim()

        if ($exitCode -ne 0) {
            $details = if ([string]::IsNullOrWhiteSpace($stderr)) {
                'Nenhuma mensagem adicional foi retornada pelo Firebase.'
            }
            else {
                "`n$stderr"
            }
            throw "firebase $($Arguments -join ' ') failed with code $exitCode.$details"
        }

        if ([string]::IsNullOrWhiteSpace($json)) {
            throw "firebase $($Arguments -join ' ') did not return JSON."
        }

        return $json.Trim() | ConvertFrom-Json
    }
    finally {
        if ($null -ne $process) {
            $process.Dispose()
        }
    }
}

function Test-PropertyValue {
    param(
        [Parameter(Mandatory)]
        [psobject] $Object,

        [Parameter(Mandatory)]
        [string] $Name
    )

    $property = $Object.PSObject.Properties[$Name]
    return $null -ne $property -and $null -ne $property.Value
}

function Get-FunctionType {
    param(
        [Parameter(Mandatory)]
        [psobject] $Function
    )

    if (Test-PropertyValue $Function 'httpsTrigger') {
        return 'https'
    }
    if (Test-PropertyValue $Function 'taskQueueTrigger') {
        return 'queue'
    }
    if (Test-PropertyValue $Function 'scheduleTrigger') {
        return 'schedule'
    }
    if (Test-PropertyValue $Function 'eventTrigger') {
        return 'subscription'
    }

    return 'unknown'
}

function Get-DashboardUrl {
    param(
        [Parameter(Mandatory)]
        [string] $ProjectId,

        [Parameter(Mandatory)]
        [psobject] $Function
    )

    if ($Function.platform -eq 'gcfv1') {
        $functionId = [string] $Function.id
        return "https://console.cloud.google.com/functions/details/$($Function.region)/$($functionId)?project=$ProjectId"
    }

    $functionId = if (Test-PropertyValue $Function 'runServiceId') {
        [string] $Function.runServiceId
    }
    else {
        [string] $Function.id
    }

    return "https://console.cloud.google.com/run/detail/$($Function.region)/$functionId/observability/metrics?project=$ProjectId"
}

function Select-WithFzf {
    param(
        [Parameter(Mandatory)]
        [string[]] $Options
    )

    $maxColumnWidth = 0
    foreach ($option in $Options) {
        $columns = $option -split "`t", 3
        foreach ($column in $columns | Select-Object -First 2) {
            if ($column.Length -gt $maxColumnWidth) {
                $maxColumnWidth = $column.Length
            }
        }
    }

    $tabStop = $maxColumnWidth + 1
    $selected = @($Options) | & fzf '--prompt=> ' '--height=100%' '--layout=default' '--border' "--tabstop=$tabStop"

    if ($LASTEXITCODE -eq 1 -or $LASTEXITCODE -eq 130) {
        return ''
    }
    if ($LASTEXITCODE -ne 0) {
        throw "fzf failed with code $LASTEXITCODE."
    }

    return ($selected -join [Environment]::NewLine).Trim()
}

function Remove-EnvironmentVariables {
    param(
        [Parameter(Mandatory)]
        [psobject] $Function
    )

    $properties = [ordered]@{}
    foreach ($property in $Function.PSObject.Properties) {
        if ($property.Name -ine 'environmentVariables') {
            $properties[$property.Name] = $property.Value
        }
    }

    return [pscustomobject]$properties
}

function Refresh-Cache {
    $startedAt = Get-Date
    Write-Host 'Atualizando cache...  ' -NoNewline -ForegroundColor DarkGray

    try {
        $projectsResponse = Invoke-FirebaseJson @('projects:list', '--json')
        $projects = @($projectsResponse.result)
        $results = @()

        foreach ($project in $projects) {
            $functionsResponse = Invoke-FirebaseJson @(
                'functions:list'
                '--project'
                [string] $project.projectId
                '--json'
            )
            $functions = foreach ($function in @($functionsResponse.result)) {
                Remove-EnvironmentVariables $function
            }
            $results += [pscustomobject]@{
                result = @($functions)
            }
        }

        $cache = [pscustomobject]@{
            projects = $projects
            functions = $results
        }

        $cache | ConvertTo-Json -Depth 20 | Set-Content -Path $cacheFile -Encoding UTF8

        return $cache
    }
    catch {
        Write-Host ' falhou.' -ForegroundColor Red
        throw
    }
}

function Get-Cache {
    if (Test-Path -LiteralPath $cacheFile) {
        try {
            $cache = Get-Content -Raw -LiteralPath $cacheFile | ConvertFrom-Json
            $projectCount = @($cache.projects).Count
            $resultCount = @($cache.functions).Count
            if ($projectCount -eq $resultCount) {
                return $cache
            }
        }
        catch {}
    }

    return Refresh-Cache
}

function Get-FunctionOptions {
    param(
        [Parameter(Mandatory)]
        [psobject] $Cache
    )

    $options = [System.Collections.Generic.List[string]]::new()
    $functionsByOption = @{}
    $projects = @($Cache.projects)
    $results = @($Cache.functions)

    for ($index = 0; $index -lt $projects.Count; $index++) {
        foreach ($function in @($results[$index].result)) {
            $option = "{0}`t[{1}]`t{2}" -f $projects[$index].projectId, (Get-FunctionType $function), $function.id
            $options.Add($option)
            $functionsByOption[$option] = $function
        }
    }

    return [pscustomobject]@{
        options = $options.ToArray()
        functionsByOption = $functionsByOption
    }
}

function Assert-Dependencies {
    $firebase = Get-Command firebase.cmd, firebase -All -ErrorAction SilentlyContinue |
        Where-Object CommandType -eq 'Application' |
        Select-Object -First 1
    $fzf = Get-Command fzf -All -ErrorAction SilentlyContinue |
        Where-Object CommandType -eq 'Application' |
        Select-Object -First 1

    $missing = @()
    if ($null -eq $firebase) { $missing += 'firebase' }
    if ($null -eq $fzf) { $missing += 'fzf' }
    if ($missing.Count -gt 0) {
        throw "CLI(s) obrigatoria(s) nao encontrada(s): $($missing -join ', ')."
    }

    $script:firebaseCommand = $firebase.Source
}

Assert-Dependencies

$cache = Get-Cache
$selectionData = Get-FunctionOptions $cache
$option = ''

while ([string]::IsNullOrEmpty($option)) {
    $option = Select-WithFzf $selectionData.options
    if ([string]::IsNullOrEmpty($option)) {
        $cache = Refresh-Cache
        $selectionData = Get-FunctionOptions $cache
    }
}

if (-not $selectionData.functionsByOption.ContainsKey($option)) {
    exit 0
}

$function = $selectionData.functionsByOption[$option]
$projectId = ($option -split "`t", 2)[0]
$functionType = Get-FunctionType $function
$functionId = [string] $function.id
$dashboardUrl = Get-DashboardUrl $projectId $function

Write-Host ''
Write-Host ("Project: {0}" -f $projectId) -ForegroundColor Cyan
Write-Host ("Name:    {0}" -f $functionId) -ForegroundColor Cyan
Write-Host ("Type:    {0}" -f $functionType) -ForegroundColor Cyan
Write-Host ''
Write-Host "Dashboard: $dashboardUrl" -ForegroundColor DarkGray

if (Test-PropertyValue $function 'httpsTrigger') {
    Write-Host "Endpoint: $($function.uri)" -ForegroundColor DarkGray
}
