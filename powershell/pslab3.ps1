get-ciminstance win32_networkadapterconfiguration |
? {$_.IPEnabled -eq "True"} |
format-table Index ,IPAddress, Description, DNSDomain, DNSServerSearchOrder
