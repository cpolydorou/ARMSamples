configuration ActiveDirectoryMemberClient
{
    # Import the modules needed to run the DSC script
    Import-DscResource -ModuleName 'xPendingReboot'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'xDSCDomainJoin'
    Import-DscResource -ModuleName 'xPowerShellExecutionPolicy'

    Node "localhost"
    { 
        # When using with Azure Automation, modify these values to match your stored credential names
        $DomainAdminCredential = Get-AutomationPSCredential -Name 'ActiveDirectoryDomainAdministrator'
        $DomainName = Get-AutomationVariable -Name 'ActiveDirectoryDomainName'

        # Configuration
        node localhost
        {
            # Set the Powershell Execution policy
            xPowerShellExecutionPolicy ExecutionPolicy
            {
                ExecutionPolicy      = 'Unrestricted'
            }

            xDSCDomainjoin JoinDomain
            {
                Domain = $DomainName
                Credential = $DomainAdminCredential               
            }
            
            xPendingReboot AfterJoin
            {
                Name = 'AfterJoin'
                SkipCcmClientSDK = $true
                DependsOn = '[xDSCDomainJoin]JoinDomain'
            }
        }
    }
}