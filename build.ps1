$env:APPVEYOR_REPO_TAG = "true"
$env:APPVEYOR_REPO_TAG_NAME = "1.3.3-beta42"

if($env:APPVEYOR_REPO_TAG -eq "true")
{
    $suffix = Extract-Suffix($env:APPVEYOR_REPO_TAG_NAME);
    
    if(![string]::IsNullOrWhiteSpace($suffix))
    {
        Set-VersionSuffix("src", $suffix)   
    }
}

# Gets version suffix from tag name or null. Example: "1.3.3-beta1" => "beta1"
function Extract-Suffix([string] $tagName)
{
    $index = $tagName.IndexOf("-")
    
    if($index -gt -1)
    {
        return $tagName.Substring($index + 1);
    }

    return null
}

# 
function Set-VersionSuffix([string]$dir, [string] $suffix)
{
    Write-Host "Setting version suffix to '$suffix'"

    $projFiles = Get-ChildItem $dir -Recurse -Filter *.csproj

    foreach($file in $projFiles)
    {
        $content = [xml](Get-Content $file.FullName)
       
        $versionSuffix = $content.CreateElement("VersionSuffx");
        $versionSuffix.set_InnerXML($suffix)
        [void] $content.Project.PropertyGroup.AppendChild($versionSuffix)
        $content.Save($file.FullName);
    }
}