# Lab Active Directory Environment
An ARM template that deploys an IaaS Active Directory environment in order to be used as a testbed.

The resource to be deployed contain:
* Azure Virtual Network - IP Prefix 10.0.0.0/16
    * Subnet Networking - IP Prefix 10.0.0.0/24
    * Subnet AzureBastionSubnet - IP Prefix 10.0.1.0/24
    * Subnet ActiveDirectory - IP Prefix 10.0.2/24
    * Subnet Clients - IP 10.0.3./24
* Azure Bastion
    * Bastion Host
    * Public IP Address
* Azure Automation Account
    * DSC Configurations
    * DSC Modules
    * DSC Configuration Jobs
    * DSC Variables
    * DSC Credentials
* Azure Key Vault
    * Key Vault Secrets
* Azure Storage Account (Virtual Machine Diagnostics)
* Azure Virtual Machines
    * Domain Controller (Windows Server)
    * Client (Windows 10)


The parameters of the deployment are
* Subscription: The Azure subscription to be used.
* Resource Group: The resource group to place the resources in.
* Region: The region to deploy to.
* Location: The location to use for the resources.
* DC VM Size: The size for the domain controller machine.
* Server VM Size: The size for the member server machine.
* Client VM Size: The size for the member client machine.
* DC OS Version: The operating system version for the domain controller machine.
* Server OS Version: The operating system version for the member server machine.
* Client OS Version: The operating system version for the member client machine.
* Local Administrator Username: The username for the local administrator user on all machines.
* Local Administrator Password: The password for the local administrator user on all machines.
* Active Directory Administrator Username: The username for the Active Directory domain administrator user.
* Active Directory Administrator Password: The username for the Active Directory domain administrator account.
* Active Directory Domain Name: The name of the Active Directory Domain to be created.
* Key Vaule Administrator User Object Id: The object ID of the user to be assigned full access to the Key Vault. Leave empty to not deploy the Key Vault (used to save the credentials used during the deployment). 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcpolydorou%2FARMSamples%2Fmain%2FLab-Active-Directory-Environment%2FLabActiveDirectoryEnvironment.json)
