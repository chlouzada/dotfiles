function Init {
    New-Item -ItemType Directory -Force "$HOME\.playground" | Out-Null
    New-Item -ItemType Directory -Force "$HOME\.playground\.vscode" | Out-Null

    '{"deno.enable": true, "deno.lint": true, "deno.unstable": true}' |
        Set-Content "$HOME\.playground\.vscode\settings.json"

    '{"tasks": {"dev": "deno run --allow-all --watch main.ts"}}' |
        Set-Content "$HOME\.playground\deno.jsonc"

    @'
import moment from 'npm:moment'

export function add(a: number, b: number): number {
  return a + b;
}

if (import.meta.main) {
  console.log("Add 2 + 3 =", add(2, 3));
  console.log("moment", moment().format());
}
'@ | Set-Content "$HOME\.playground\main.ts"
}

if (-not (Get-Command deno -ErrorAction SilentlyContinue)) {
    Write-Host "Deno could not be found"
    exit 1
}


$playground = "$HOME\.playground"
$settings = "$playground\.vscode\settings.json"
$denoConfig = "$playground\deno.jsonc"
$main = "$playground\main.ts"

if (
    -not (Test-Path $settings) -or
    -not (Test-Path $denoConfig) -or
    -not (Test-Path $main)
) {
    Init
}

code $playground

deno task --cwd $playground dev