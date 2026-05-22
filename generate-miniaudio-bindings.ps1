$root = (Get-Location).ProviderPath
$sourcePath = Join-Path $root "./miniaudio/"
$outPath = Join-Path $root "./output/"

function Assert-CommandExists($Name)
{
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue))
    {
        throw "Required command '$Name' was not found in PATH."
    }
}

Assert-CommandExists 'git'
Assert-CommandExists 'gcc'
Assert-CommandExists 'ClangSharpPInvokeGenerator'

if (-not (Test-Path $sourcePath))
{
    & git clone "https://github.com/mackron/miniaudio.git"
}

if (Test-Path $outPath)
{
    Write-Host "cleaning output folder"
    Remove-Item -Recurse -Force -Path $outPath
}

New-Item -ItemType Directory -Path $outPath

<#

ClangSharpPInvokeGenerator `
    -c multi-file compatible-codegen generate-aggressive-inlining exclude-default-remappings generate-helper-types <# configuration for the generator#> `
    --file miniaudio\vendor\miniaudio.h <# file we want to generate bindings for #>  `
    --traverse miniaudio\vendor\miniaudio.h `
    -n MiniaudioSharp <# namespace of the bindings #> `
    --methodClassName Miniaudio <# class name where to put methods #> `
    --libraryPath miniaudio <# name of the DLL #> `
    -o ..\MiniaudioSharp\src <# output folder #>

#>

$miniaudioC = Join-Path $sourcePath 'miniaudio.c'
$miniaudioH = Join-Path $sourcePath 'miniaudio.h'
$dllOut = Join-Path $outPath 'miniaudio.dll'
$soOut = Join-Path $outPath 'libminiaudio.so'
$bindingsOut = Join-Path $outPath 'MiniaudioBindings.cs'

Write-Host "building dll"
$winLibs = '-lwinmm', '-luser32', '-lgdi32', '-lole32', '-luuid'
& gcc -shared -o $dllOut $miniaudioC @winLibs

Write-Host "building so"
$linuxLibs = '-lpthread', '-lm'
& gcc -shared -o $soOut $miniaudioC @linuxLibs

Write-Host "generating bindings with clangsharp"
& ClangSharpPInvokeGenerator -f $miniaudioH -I $sourcePath -o $bindingsOut -l miniaudio -n MiniaudioSharp -x c --additional '-DWIN32' --additional '-D_WINDOWS'

Write-Host "Output directory: $outPath"
Get-ChildItem -Path $outPath | Select-Object Name, Length | Format-Table -AutoSize