
$tenantId = 'd05153cc-16cb-45f3-853c-fc45067554dd'

# Login to tenant
Connect-MgGraph -Scopes "Application.Read.All" -Tenantid $tenantId

# Get all applications
$appRegistrations = Get-MgApplication

# Enumerate all applications and determine the users\roles that are assigned to them
$appRegistrations | ForEach-Object {

    $currentApp = $_

    # Get Service principal for application
    $servicePrincipalMsGraph = Get-MgServicePrincipal -Filter "AppId eq '$($currentApp.AppId)'"

    if ($servicePrincipalMsGraph ) {
        [array] $assignedPrincipals = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $servicePrincipalMsGraph.Id -All

        # If there are assigned principals output a row for each
        if ($assignedPrincipals.Count) {
            $assignedPrincipals | ForEach-Object {
                $currentPrincipal = $_
                [pscustomobject]@{
                    ApplicationObjectId = $currentApp.Id; 
                    Application         = $currentApp.DisplayName; 
                    PrincipalId         = $currentPrincipal.PrincipalId;
                    Principal           = $currentPrincipal.PrincipalDisplayName; 
                    PrincipalType       = $currentPrincipal.PrincipalType 
                } | 
                Export-Csv -Append -Path "application-assignments.csv" -NoTypeInformation
            }
        }
        else {
            # If not then ouput a row for just the application
            [pscustomobject]@{
                ApplicationObjectId = $currentApp.Id; 
                Application         = $currentApp.DisplayName; 
                PrincipalId         = "";
                Principal           = ""; 
                PrincipalType       = ""
            } | 
            Export-Csv -Append -Path "application-assignments.csv" -NoTypeInformation
        }
    }
    else {
        Write-Host $currentApp.AppId
    }
}
