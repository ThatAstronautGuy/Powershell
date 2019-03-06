function Validate-DNS {
    <#
        .SYNOPSIS
            Validates the DNS settings of a list of hosts against given DNS Servers
        .DESCRIPTION
            This function validates the DNS Server settings of a list of hosts against a provided primary and secondary DNS Server
        .PARAMETER Hostnames
            An array of hostnames to check
        .PARAMETER PrimaryDNS
            The Primary DNS Server to check for
        .PARAMETER SecondaryDNS
            The secondary DNS Server to check for
        .EXAMPLE
            Validate-DNS -Hostnames "foobar" -PrimaryDNS 10.100.0.1 -SecondaryDNS 10.101.0.1

            Returns an object array with the hostname, its current primary and secondary DNS servers, and whether or not it matches the provided servers.
        .NOTES
            FunctionName : Validate-DNS
            Created by   : ThatAstronautGuy
            Date Coded   : 24/01/2019
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [psobject[]]$Hostnames,

        [Parameter(Mandatory=$True)]
        [string]$PrimaryDNS,

        [Parameter(Mandatory=$True)]
        [string]$SecondaryDNS
    )

    PROCESS {
        $objarray = @()
        foreach($Computer in $Hostnames){
            if(Test-Connection -ComputerName $computer -Count 1 -Quiet){
                try{
                    $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer -EA Stop | ? {$_.IPEnabled}
                
                    foreach($Network in $Networks){
                        $DNSServers = $Network.DNSServerSearchOrder
                        if($DNSServers[0] -eq $PrimaryDNS -and $DNSServers[1] -eq $SecondaryDNS){
                            $valid = "True"
                        }
                        else{
                            $valid = "False"
                        }

                        $Output = New-Object -Type PSObject
                        $Output | Add-Member -MemberType NoteProperty -Name HostName -Value $Computer
                        $Output | Add-Member -MemberType NoteProperty -Name PrimaryDNS -Value $DNSServers[0]
                        $Output | Add-Member -MemberType NoteProperty -Name SecondaryDNS -Value $DNSServers[1]
                        $Output | Add-Member -MemberType NoteProperty -Name Correct -Value $valid
                        $objarray += $Output
                    }
                }
                catch{
                    Write-Error -Message "WMI error connecting to $computer" -Category ConnectionError -TargetObject $computer
                    $Output = New-Object -Type PSObject
                    $Output | Add-Member -MemberType NoteProperty -Name HostName -Value $Computer
                    $Output | Add-Member -MemberType NoteProperty -Name Correct -Value "Error - WMI error"
                    $objarray += $Output
                }
            }
            else {
                Write-Error -Message "Can't connect to server $computer" -Category ConnectionError -TargetObject $computer
                $Output = New-Object -Type PSObject
                $Output | Add-Member -MemberType NoteProperty -Name HostName -Value $Computer
                $Output | Add-Member -MemberType NoteProperty -Name Correct -Value "Error - Connection error"
                $objarray += $Output
            }
        }
        return $objarray
    }
}

function Set-RemoteDNS {
    <#
        .SYNOPSIS
            Sets the DNS settings of a list of hosts to the given DNS Servers
        .DESCRIPTION
            This function updates the DNS Server settings of a list of hosts with a provided primary and secondary DNS Server
        .PARAMETER Hostnames
            An array of hostnames to check
        .PARAMETER PrimaryDNS
            The Primary DNS Server to set
        .PARAMETER SecondaryDNS
            The secondary DNS Server to set
        .EXAMPLE
            Set-RemoteDNS -Hostnames "foobar" -PrimaryDNS 10.100.0.1 -SecondaryDNS 10.101.0.1

            Returns an object array with the hostname, and a boolean variable on whether or not it was successful in setting the new DNS Servers.
        .NOTES
            FunctionName : Set-RemoteDNS
            Created by   : ThatAstronautGuy
            Date Coded   : 24/01/2019
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [psobject[]]$Hostnames,

        [Parameter(Mandatory=$True)]
        [string]$PrimaryDNS,

        [Parameter(Mandatory=$True)]
        [string]$SecondaryDNS
    )

    PROCESS {
        $objarray = @()
        foreach($Computer in $Hostnames){
            if(Test-Connection -ComputerName $computer -Count 1 -Quiet){
                try{
                    $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer -EA Stop | ? {$_.IPEnabled}
                
                    foreach($Network in $Networks){
                        try {
                            $DNSServers = "$PrimaryDNS","$SecondaryDNS"
                            $dump = $Network.SetDNSServerSearchOrder($DNSServers)

                            $Output = New-Object -Type PSObject
                            $Output | Add-Member -MemberType NoteProperty -Name HostName -Value $Computer
                            $Output | Add-Member -MemberType NoteProperty -Name Result -Value "True"
                        }
                        catch {
                            $Output = New-Object -Type PSObject
                            $Output | Add-Member -MemberType NoteProperty -Name HostName -Value $Computer
                            $Output | Add-Member -MemberType NoteProperty -Name Result -Value "False - Setting error"
                        }
                        $objarray += $Output
                    }
                }
                catch{
                    Write-Error -Message "WMI error connecting to $computer" -Category ConnectionError -TargetObject $computer
                    $Output = New-Object -Type PSObject
                    $Output | Add-Member -MemberType NoteProperty -Name HostName -Value $Computer
                    $Output | Add-Member -MemberType NoteProperty -Name Correct -Value "False - WMI Error"
                    $objarray += $Output
                }
            }
            else {
                Write-Error -Message "Can't connect to server $computer" -Category ConnectionError -TargetObject $computer
                $Output = New-Object -Type PSObject
                $Output | Add-Member -MemberType NoteProperty -Name HostName -Value $Computer
                $Output | Add-Member -MemberType NoteProperty -Name Result -Value "False - Connection error"
                $objarray += $Output
            }
        }
        return $objarray
    }
}
