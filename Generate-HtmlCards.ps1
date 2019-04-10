param (
    [Parameter(Mandatory=$true)][PSObject]$Pack
)

$cardsOnCurrentPage = 0
$pagesHtml = ""
$currentPageCards = ""
$script:backTemplate = Get-Content "./templates/back-small.html" -Encoding UTF8 -Raw

function Get-HtmlTemplate {
    param (
        [Parameter(Mandatory=$true)][string]$Type
    )
    process {
        $path = Join-Path $PSScriptRoot "templates/$($Type).html"
        if (Test-Path $path) {
            Get-Content "./templates/$($Type).html" -Raw -Encoding UTF8
        } else {
            throw "Unable to find template"
        }
    }
}

function Break-Page($pageTemplate, $printBacks) {
    $script:pagesHtml += $pageTemplate -replace "%cards%", $script:currentPageCards
    $script:currentPageCards = ""
    if ($printBacks) {
        $script:pagesHtml += $pageTemplate -replace "%cards%", ($script:backTemplate * $script:cardsOnCurrentPage)
    }
    $script:cardsOnCurrentPage = 0
}

function Write-SingleCard($cardHtml, $pageTemplate)
{
    $script:currentPageCards += $cardHtml
    $script:cardsOnCurrentPage += 1
    if ($script:cardsOnCurrentPage -eq $Pack.CardsPerPage) {
        Break-Page $pageTemplate $true
    }
}

$packTemplate = Get-HtmlTemplate -Type "pack"
$pageTemplate = Get-HtmlTemplate -Type "page"

$Pack.Cards | ForEach-Object {
    $set = $_
    $definition = Get-Content "./definitions/$($set.Card).json" -Encoding UTF8 | ConvertFrom-Json
    $cardTemplate = Get-HtmlTemplate -Type $definition.Type
    $cardTemplate = $cardTemplate -replace "%name%", $definition.Name
    $cardTemplate = $cardTemplate -replace "%icon%", $definition.Icon
    $cardTemplate = $cardTemplate -replace "%iconSize%", $definition.iconSize
    $cardTemplate = $cardTemplate -replace "%name%", $definition.Name
    if ($null -ne $Definition.Traits) {
        $cardTemplate = $cardTemplate -replace "%traits%", [string]::Join(", ", $Definition.Traits)
    }
    for ($i = 0; $i -lt $set.Count; $i++) {
        Write-SingleCard -cardHtml $cardTemplate -pageTemplate $pageTemplate
    }
}

Break-Page $pageTemplate $true
$packTemplate -replace "%pages%", $pagesHtml
