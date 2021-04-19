configuration ActiveDirectoryPrimaryDomainController
{
    # Import the modules needed to run the DSC script
    Import-DscResource -ModuleName 'xActiveDirectory'
    Import-DscResource -ModuleName 'xStorage'
    Import-DscResource -ModuleName 'xPendingReboot'
    Import-DscResource -ModuleName 'xDnsServer'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node "localhost"
    { 
        # When using with Azure Automation, modify these values to match your stored credential names
        $DomainAdminCredential = Get-AutomationPSCredential -Name 'ActiveDirectoryDomainAdministrator'
        $SafeModePassword = Get-AutomationPSCredential -Name 'ActiveDirectorySafeModePassword'
        $DomainName = Get-AutomationVariable -Name 'ActiveDirectoryDomainName'
        $DomainJoinCredential = Get-AutomationPSCredential -Name 'DomainJoinAccount'
        
        # Configuration
        node localhost
        {
            Script LocalAdministratorRename
            {
                SetScript = {
                    # Check if the computer is member of the domain
                    if ((gwmi win32_computersystem).partofdomain -ne $true)
                    {
                        $user = Get-LocalUser -ErrorAction Stop | Where-Object {$_.sid -like "S-1-5-21-*-500"}
                        Set-LocalUser -InputObject $user -FullName "Administrator"
                        Rename-LocalUser -InputObject $user -NewName "Administrator"
                    }
    
                }
                TestScript = {
                    $result = 0
    
    
                    # Check if the computer is member of the domain
                    if ((gwmi win32_computersystem).partofdomain -ne $true)
                    {
                        $user = Get-LocalUser -ErrorAction Stop | Where-Object {$_.sid -like "S-1-5-21-*-500"}
    
                        if($user.Name -ne "Administrator")
                        {
                            $result++
                        }
                    }
    
                    if($result -gt 0)
                    {
                        $false
                    }
                    else
                    {
                        $true
                    }
                }
                GetScript = {
                 @{
                    Result = $true
                  }
                }
            }

            WindowsFeature ADDSInstall
            {
                Ensure = 'Present'
                Name = 'AD-Domain-Services'
                DependsOn = "[Script]LocalAdministratorRename"
            }            
 
            xWaitforDisk Disk2
            {
                DiskId = 2
                RetryIntervalSec = 10
                RetryCount = 30
            }
 
            xDisk DiskF
            {
                DiskId = 2
                DriveLetter = 'F'
                DependsOn = '[xWaitforDisk]Disk2'
            }
 
            WindowsFeature ADManagement
            {
                Ensure = 'Present'
                Name = 'RSAT-AD-Tools'
                IncludeAllSubFeature = $true
            }

            xPendingReboot BeforeDC
            {
                Name = 'BeforeDC'
                SkipCcmClientSDK = $true
                DependsOn = '[WindowsFeature]ADDSInstall','[xDisk]DiskF','[WindowsFeature]ADManagement'
            }

            xADDomain Domain
            {
                DomainName = $DomainName
                DomainNetbiosName = $DomainName.Split(".")[0]
                DomainAdministratorCredential = $DomainAdminCredential
                SafemodeAdministratorPassword = $SafeModePassword
                DatabasePath = 'F:\NTDS'
                LogPath = 'F:\NTDS'
                SysvolPath = 'F:\SYSVOL'
                DependsOn = '[WindowsFeature]ADDSInstall','[xDisk]DiskF','[xPendingReboot]BeforeDC', '[WindowsFeature]ADManagement'
            }

            xADUser AdministratorUser
            {
                Ensure = 'Present'
                DomainName = $DomainName
                UserName = 'administrator'
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]Domain'
                UserPrincipalName = "administrator@$DomainName"
            }

            xDnsServerForwarder DNSForwarders
            {
                IPAddresses = "8.8.8.8", "8.8.4.4"
                DependsOn = "[xADDomain]Domain"
                IsSingleInstance = "Yes" 
            }

            xPendingReboot AfterDC
            {
                Name = 'AfterDC'
                SkipCcmClientSDK = $true
                DependsOn = '[xADDomain]Domain','[xDnsServerForwarder]DNSForwarders'
            }
 
            Registry DisableRDPNLA
            {
                Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
                ValueName = 'UserAuthentication'
                ValueData = 0
                ValueType = 'Dword'
                Ensure = 'Present'
                DependsOn = '[xADDomain]Domain'
            }
        }
    }
}