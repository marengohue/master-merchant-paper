param (
    [Parameter(Mandatory=$true)][PSObject]$Definition,
    [Parameter(Mandatory=$true)][int]$Count
)

function Get-HtmlTemplate {
    param (
        [Parameter(Mandatory=$true)][string]$Type
    )
    process {
        $path = Join-Path $PSScriptRoot "templates/$($Type).html"
        if (Test-Path $path) {
            Get-Content "./templates/$($Type).html" -Raw
        } else {
            throw "Unable to find template"
        }
    }
}


$pageTemplate = Get-HtmlTemplate -Type "page"

$cardTemplate = Get-HtmlTemplate -Type $Definition.Type
$cardTemplate = $cardTemplate -replace "%name%", $Definition.Name
$cardTemplate = $cardTemplate -replace "%icon%", $Definition.Icon
$cardTemplate = $cardTemplate -replace "%iconSize%", $Definition.iconSize
$cardTemplate = $cardTemplate -replace "%name%", $Definition.Name
$cardTemplate = $cardTemplate -replace "%traits%", [string]::Join(", ", $Definition.Traits)
$pageTemplate -replace "%items%", ($cardTemplate * $Count) > out.html
