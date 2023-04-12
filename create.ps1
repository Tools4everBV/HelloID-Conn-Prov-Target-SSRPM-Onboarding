#region Initialize default properties
$config = ConvertFrom-Json $configuration
$p = $person | ConvertFrom-Json
$pp = $previousPerson | ConvertFrom-Json
$pd = $personDifferences | ConvertFrom-Json
$m = $manager | ConvertFrom-Json

$success = $False;
$auditLogs = [System.Collections.Generic.List[PSCustomObject]]::new()
#endregion Initialize default properties

#region Change mapping here
    $onboardDate = Get-Date -Format "yyyy-MM-dd";
    $domain = "t4edev.local";

    $account = [PSCustomObject]@{
                        Action = "new"
                        OnboardingToken = $config.token
                        users = [System.Collections.Generic.List[PSCustomObject]]::new()
                    };
    
    $user = [PSCustomObject]@{
        Domain = $domain
        SAMAccountName = $p.Accounts.ActiveDirectory.SamAccountName
        OnboardingDate = $onboardDate
        Attributes = [System.Collections.Generic.List[PSCustomObject]]::new()
    };
    
    #Claim ID
    [void]$user.Attributes.add([PSCustomObject]@{
                                    Name = "ID"
                                    Value = $p.ExternalID
                                    Options = 1
                                }
    );
    
    #Birth date
    [void]$user.Attributes.add([PSCustomObject]@{
                                    Name = "DOB"
                                    Value = (Get-Date -Date $p.details.birthdate).ToUniversalTime().toString("dd/MM/yyyy")
                                    Options = 34
                                }
    )
    
    [void]$account.users.Add($user);
#endregion Change mapping here

#region Execute
try {
    if(-Not($dryRun -eq $True)) {
        $response = (Invoke-WebRequest -Uri "$($config.ssrpmServer)/onboarding/import" -Method POST -ContentType "application/json" -Body ($account | ConvertTo-Json -Depth 10) -UseBasicParsing | ConvertFrom-Json).Success
    }
    else
    {
        $response = $true;
    }
     
    if($response -eq $true)
    {
        $success = $True;
        $auditLogs.Add([PSCustomObject]@{
                Action = "CreateAccount"
                Message = "Enrolled in SSRPM onboarding for person [$($account.sAMAccountName)]";
                IsError = $false;
            });
    }
     
}
catch
{
        $auditLogs.Add([PSCustomObject]@{
                Action = "CreateAccount"
                Message = "Failed to Enroll SSRPM Onboarding: $($_)"
                IsError = $True
            });
        Write-Error "$($_) : General error"
}
#endregion Execute 
 
#region build up result
$result = [PSCustomObject]@{
    Success= $success
    AccountReference= $user.SAMAccountName
    AuditLogs= $auditLogs
    Account = $account
};

Write-Output $result | ConvertTo-Json -Depth 10
#endregion build up result
