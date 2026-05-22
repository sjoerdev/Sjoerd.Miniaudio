# requires git, gcc, ClangSharpPInvokeGenerator

$root = (Get-Location).ProviderPath
$miniaudio_repo = Join-Path $root "./miniaudio/"
$output_directory = Join-Path $root "./output/"

# clone repo if it isnt there
if (-not (Test-Path $miniaudio_repo))
{
    Write-Host "cloning miniaudio repository"
    & git clone "https://github.com/mackron/miniaudio.git"
}

# reset the output directory
if (Test-Path $output_directory)
{
    Write-Host "cleaning output directory"
    Remove-Item -Recurse -Force -Path $output_directory
}
New-Item -ItemType Directory -Path $output_directory

# -c multi-file compatible-codegen generate-aggressive-inlining exclude-default-remappings generate-helper-types <# configuration for the generator#>
# --file miniaudio.h <# file we want to generate bindings for #> 
# --traverse miniaudio.h
# -n Sjoerd.Miniaudio <# namespace of the bindings #>
# --methodClassName Miniaudio <# class name where to put methods #>
# --libraryPath miniaudio <# name of the DLL #>
# -o ..\MiniaudioSharp\src <# output folder #>

$miniaudio_c_path = Join-Path $miniaudio_repo "miniaudio.c"
$miniaudio_h_path = Join-Path $miniaudio_repo "miniaudio.h"
$miniaudio_dll_path = Join-Path $output_directory "miniaudio.dll"
$miniaudio_so_path = Join-Path $output_directory "libminiaudio.so"
$miniaudio_cs_path = Join-Path $output_directory "Bindings.cs"

Write-Host "building dll"
$mindows_links = '-lwinmm', '-luser32', '-lgdi32', '-lole32', '-luuid'
& gcc -shared -o $miniaudio_dll_path $miniaudio_c_path @mindows_links

Write-Host "building so"
$linux_links = '-lpthread', '-lm'
& gcc -shared -o $miniaudio_so_path $miniaudio_c_path @linux_links

Write-Host "generating bindings"
& ClangSharpPInvokeGenerator -f $miniaudio_h_path -I $miniaudio_repo -o $miniaudio_cs_path -l miniaudio -n MiniaudioSharp -x c --additional '-DWIN32' --additional '-D_WINDOWS'

Write-Host "bindings generated here: $output_directory"
Get-ChildItem -Path $output_directory | Select-Object Name, Length | Format-Table -AutoSize