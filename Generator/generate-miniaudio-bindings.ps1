# requires git, gcc, ClangSharpPInvokeGenerator

$root = $PSScriptRoot
$miniaudio_repo = Join-Path $root "miniaudio"
$output_directory = Join-Path $root "output"
$local_repo = Split-Path $PSScriptRoot -Parent

# clone repo if it isnt there
if (-not (Test-Path $miniaudio_repo))
{
    Write-Host "cloning miniaudio repository"
    & git clone "https://github.com/mackron/miniaudio.git" $miniaudio_repo
}

# reset the output directory
if (Test-Path $output_directory)
{
    Write-Host "cleaning output directory"
    Remove-Item -Recurse -Force -Path $output_directory
}
New-Item -ItemType Directory -Path $output_directory | Out-Null

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
$miniaudio_so_path = Join-Path $output_directory "miniaudio.so"
$miniaudio_cs_path = Join-Path $output_directory "Bindings.cs"

Write-Host "building dll"
$mindows_links = '-lwinmm', '-luser32', '-lgdi32', '-lole32', '-luuid'
& gcc -shared -o $miniaudio_dll_path $miniaudio_c_path @mindows_links

Write-Host "building so"
$linux_links = '-lpthread', '-lm'
& gcc -shared -o $miniaudio_so_path $miniaudio_c_path @linux_links

Write-Host "generating bindings"
& ClangSharpPInvokeGenerator `
    -f $miniaudio_h_path `
    -I $miniaudio_repo `
    -o $miniaudio_cs_path `
    -l miniaudio `
    -n Sjoerd.Miniaudio `
    --methodClassName Miniaudio `
    -x c --additional '-DWIN32' --additional '-D_WINDOWS'

# set up move paths
$miniaudio_cs_path_new = Join-Path $local_repo "Bindings/Bindings.cs"
$miniaudio_dll_path_new = Join-Path $local_repo "Bindings/native/windows/miniaudio.dll"
$miniaudio_so_path_new = Join-Path $local_repo "Bindings/native/linux/miniaudio.so"

# make sure native dir exists
$native_path = Join-Path $local_repo "Bindings/native"
$native_path_windows = Join-Path $local_repo "Bindings/native/windows"
$native_path_linux = Join-Path $local_repo "Bindings/native/linux"
if (-not (Test-Path $native_path)) { New-Item -ItemType Directory $native_path  | Out-Null}
if (-not (Test-Path $native_path_windows)) { New-Item -ItemType Directory $native_path_windows  | Out-Null}
if (-not (Test-Path $native_path_linux)) { New-Item -ItemType Directory $native_path_linux  | Out-Null}

Write-Host "moving the generated bindings"
if (Test-Path $miniaudio_cs_path_new) { Remove-Item -Force $miniaudio_cs_path_new }
if (Test-Path $miniaudio_dll_path_new) { Remove-Item -Force $miniaudio_dll_path_new }
if (Test-Path $miniaudio_so_path_new) { Remove-Item -Force $miniaudio_so_path_new }
Move-Item $miniaudio_cs_path $miniaudio_cs_path_new
Move-Item $miniaudio_dll_path $miniaudio_dll_path_new
Move-Item $miniaudio_so_path $miniaudio_so_path_new