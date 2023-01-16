[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]$fileDepsJson,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$fileListName,
    [Parameter(Mandatory = $True, Position = 3)]
    [string]$fileWxsPath
)

$fileDepsRoot = (Get-ChildItem $fileDepsJson).Directory.FullName
$depsJson = Get-Content $fileDepsJson | ConvertFrom-Json
$fileWxs = Get-Content $fileWxsPath;

$fileExclusionList = @("*.pdb", "*.lastcodeanalysissucceeded", "backup_restore_settings.json")
$fileInclusionList = @("*.dll", "*.exe", "*.json")

$runtimeList = ([array]$depsJson.targets.PSObject.Properties)[-1].Value.PSObject.Properties | Where-Object {
    $_.Name -match "runtimepack.*Runtime"
};

$runtimeList | ForEach-Object {
    $_.Value.PSObject.Properties.Value | ForEach-Object { 
        $fileExclusionList += $_.PSObject.Properties.Name 
    } 
}

$fileList = Get-ChildItem $fileDepsRoot -Include $fileInclusionList -Exclude $fileExclusionList -File -Name
$fileWxs = $fileWxs -replace "\s+(<!--$($fileListName)_Def-->)", "<?define $fileListName=$($fileList -join ';')?>"

Set-Content -Path $fileWxsPath -Value $fileWxs