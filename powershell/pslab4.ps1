# Function to show hardware data
function get-harwareDescription {
    echo "===========================
    Hardware Description 
==========================="
    Get-CimInstance win32_computersystem | 
    fl Model, Name, Domain, Manufacturer, TotalPhysicalMemory
    echo "==========================="
}
# Function to show OS data
function get-osDescription {
    echo "====================
    OS DATA 
===================="
    Get-CimInstance win32_operatingsystem | Select-Object Caption, Version, OSArchitecture | format-list
    echo "===================="
}
# Function to show processor data
function get-processorDescription {
    echo "=======================
    PROCESSOR DATA 
======================="
    Get-CimInstance win32_processor | 
    Select-Object Name, CurrentclockSpeed, MaxClockSpeed, NumberOfCores, 
    @{  n = "L1CacheSize"; e = { switch ($_.L1CacheSize) { 0 { $outVariable = 0 } $null { $outVariable = "Data Not Found" } Default { $outVariable = $_.L1CacheSize } }; $outVariable }
    },
    @{  n = "L2CacheSize"; e = { switch ($_.L2CacheSize) { 0 { $outVariable = 0 }$null { $outVariable = "Data Not Found" }Default { $outVariable = $_.L2CacheSize } }; $outVariable }
    },
    @{  n = "L3CacheSize"; e = { switch ($_.L3CacheSize) { $null { $outVariable = "Data Not Found" } 0 { $outVariable = 0 } Default { $outVariable = $_.L3CacheSize } }; $outVariable }
    } | format-list *
    echo "======================="
}
# Function to show ram data
function get-ramSummary {
    echo "=====================
    PRIMARY MEMORY DATA 
====================="
    $totalPrimaryStorageCapacity = 0
    Get-CimInstance win32_physicalmemory |
    ForEach-Object {
        $passedObject = $_ ;
        New-Object -TypeName psObject -Property @{
            Manufacturer = $passedObject.Manufacturer
            Description  = $passedObject.Description
            "Size (GB)"  = $passedObject.Capacity / 1073741824
            Bank         = $passedObject.banklabel
            Slot         = $passedObject.devicelocator
        }
        $totalPrimaryStorageCapacity += $passedObject.Capacity / 1073741824
    } |
    ft manufacturer, description, "Size (GB)", Bank, Slot -AutoSize
    echo "RAM (total) = $($totalPrimaryStorageCapacity)GB"
    echo "====================="
}
# Function to show disk data
function get-diskSummary {
    echo "=========================
    DISKDRIVE DATA 
========================="
    $diskDrives = Get-CIMInstance CIM_diskdrive | Where-Object DeviceID -ne $null
    foreach ($diskDrive in $diskDrives) {
        $partitions = $diskDrive | get-cimassociatedinstance -resultclassname CIM_diskpartition
        foreach ($partition in $partitions) {
            $logicalDisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
            foreach ($logicalDisk in $logicalDisks) {
                new-object -typename psobject -property @{
                    Model          = $diskDrive.Model
                    Manufacturer   = $diskDrive.Manufacturer
                    Location       = $partition.deviceid
                    Drive          = $logicalDisk.deviceid
                    "Size (GB)"    = [string]($logicalDisk.size / 1073741824 -as [int]) + 'GB'
                    FreeSpace      = [string]($logicalDisk.FreeSpace / 1073741824 -as [int]) + 'GB'
                    "FreeSpace(%)" = ([string]((($logicalDisk.FreeSpace / $logicalDisk.Size) * 100) -as [int]) + '%')
                } | Format-Table Drive, "Size (GB)", FreeSpace, "FreeSpace(%)", Manufacturer, Location, Model  -AutoSize
            } 
        }
    } 
    echo "=========================" 
}
# Function to show network data
function get-networkConfiguration {
    echo "=======================
    NETWORK DATA 
======================="
    get-ciminstance win32_networkadapterconfiguration |
    ? {$_.IPEnabled -eq "True"} |
    Select-Object Index, IPaddress, 
    @{
        n = 'IPSubnet';
        e = {
            switch ($_.Subnet) {
                0 { $outVariable = "0"}
                $null { $outVariable = 'Data Not Found' }
                Default { $outVariable = $_.Subnet }
            };
            $outVariable
        }
    }, 
    DNSDomain, DNSServerSearchOrder, Description  |
    Format-Table Index, IPaddress, Description, IPSubnet, DNSDomain, DNSserversearchorder -AutoSize
    echo "======================="
}
# Function to show graphics data
function get-videoDescription {
    echo "=====================
    GRAPHICS DATA 
====================="
    Get-CimInstance win32_videocontroller | % {New-Object -TypeName psObject -Property @{
    Name             = $_.Name
    Description      = $_.Description
    ScreenResolution = [string]($_.CurrentHorizontalResolution) + 'px x ' + [string]($_.CurrentVerticalResolution) + 'px'
}} | Format-List *
    echo "====================="
}
    
    
get-harwareDescription
get-osDescription
get-processorDescription
get-RAMSummary
get-diskSummary
get-networkConfiguration
get-videoDescription