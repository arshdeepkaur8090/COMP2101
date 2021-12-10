[CmdletBinding()]
param (
    [switch]$Disks, [switch]$Network , [switch]$System
)
if ($Disks -ne $true -and $Disks -ne $true -and $Network -ne $true) {
    get-harwareDescription
    get-osDescription
    get-processorDescription
    get-RAMSummary
    get-diskSummary
    get-networkConfiguration
    get-videoDescription
}
if ($Disks -eq $true) {
    get-diskSummary
}
if ($Network -eq $true) {
    get-networkConfiguration
}
if ($System -eq $true) {
    get-harwareDescription
    get-osDescription
    get-processorDescription
    get-RAMSummary
    get-videoDescription
}