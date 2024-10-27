State file can be stored in Azure Storage Account. But for the sake of simplicity, local storage is used in the code.
Storage Account best practices are inculcated
    HTTPS should be enabled
    Network Access should be restricted
    Container Access should be private
Tags are beings added in resource deployments to maintain standards.
Databricks best practices are inculcated
    Public Access is disabled
    Managed Identity is used for authentication
Below new resources are created as part of the deployment
    Resource Group
    Storage Accounts
    Databricks
    Log Analytics Workspaces
    Virtual Network
    Subnets
    Network Security Groups
    Managed Identity