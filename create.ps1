#################################################
# HelloID-Conn-Prov-Target-SSRPM-Onboarding-Create
# PowerShell V2
#################################################

# Enable TLS1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

#region functions
function Resolve-SSRPM-OnboardingError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $ErrorObject
    )
    process {
        $httpErrorObj = [PSCustomObject]@{
            ScriptLineNumber = $ErrorObject.InvocationInfo.ScriptLineNumber
            Line             = $ErrorObject.InvocationInfo.Line
            ErrorDetails     = $ErrorObject.Exception.Message
            FriendlyMessage  = $ErrorObject.Exception.Message
        }
        if (-not [string]::IsNullOrEmpty($ErrorObject.ErrorDetails.Message)) {
            $httpErrorObj.ErrorDetails = $ErrorObject.ErrorDetails.Message
        } elseif ($ErrorObject.Exception.GetType().FullName -eq 'System.Net.WebException') {
            if ($null -ne $ErrorObject.Exception.Response) {
                $streamReaderResponse = [System.IO.StreamReader]::new($ErrorObject.Exception.Response.GetResponseStream()).ReadToEnd()
                if (-not [string]::IsNullOrEmpty($streamReaderResponse)) {
                    $httpErrorObj.ErrorDetails = $streamReaderResponse
                }
            }
        }
        try {
            $errorDetailsObject = ($httpErrorObj.ErrorDetails | ConvertFrom-Json)
            # Make sure to inspect the error result object and add only the error message as a FriendlyMessage.
            # $httpErrorObj.FriendlyMessage = $errorDetailsObject.message
            $httpErrorObj.FriendlyMessage = $httpErrorObj.ErrorDetails # Temporarily assignment
        } catch {
            $httpErrorObj.FriendlyMessage = $httpErrorObj.ErrorDetails
        }
        Write-Output $httpErrorObj
    }
}
#endregion

try {
    # Initial Assignments
    $outputContext.AccountReference = 'Currently not available'

    # Validate correlation configuration
    # there is no "get" functionality for onboarding, so account correlation cannot be done

    $action = 'CreateAccount'

    # Process
    switch ($action) {
        'CreateAccount' {

            $onboardDate = Get-Date -Format "yyyy-MM-dd";
            $user = [PSCustomObject]@{
                Domain = $actionContext.Data.Domain
                SAMAccountName = $actionContext.Data.SamAccountName
                OnboardingDate = $onboardDate
                Attributes = [System.Collections.Generic.List[PSCustomObject]]::new()

            };
            $Attributes = $actionContext.Data.Attributes | convertFrom-Json
            foreach( $Attribute in $Attributes) {
                [void]$user.Attributes.Add($Attribute);
            }

            $account = [PSCustomObject]@{
                Action = "new"
                OnboardingToken = $actionContext.Configuration.token
                users = [System.Collections.Generic.List[PSCustomObject]]::new()
            };
            [void]$account.users.Add($user);

            $splatCreateParams = @{
                Uri    = "$($actionContext.Configuration.BaseUrl)/onboarding/import"
                Method = 'POST'
                ContentType = "application/json"
                UseBasicParsing = $true
                Body   = $account | ConvertTo-Json -Depth 10
            }
            # Make sure to test with special characters and if needed; add utf8 encoding.
            if (-not($actionContext.DryRun -eq $true)) {
                Write-Information 'Creating and correlating SSRPM-Onboarding account'
                # < Write Create logic here >

                $createdAccount = Invoke-RestMethod @splatCreateParams
                if($createdAccount.Success -eq $false)
                {
                    throw "Error onboarding ssrpm user [$($createdAccount.ErrorCode)] [$($createdAccount.Errormessage)]"
                }
                $outputContext.AccountReference = $actionContext.Data.SamAccountName

            } else {
                Write-Information '[DryRun] Create and correlate SSRPM-Onboarding account, will be executed during enforcement'
            }
            $auditLogMessage = "Create account was successful. AccountReference is: [$($outputContext.AccountReference)]"
            break
        }
    }


    $outputContext.success = $true
    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = $action
            Message = $auditLogMessage
            IsError = $false
        })
} catch {
    $outputContext.success = $false
    $ex = $PSItem
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or
        $($ex.Exception.GetType().FullName -eq 'System.Net.WebException')) {
        $errorObj = Resolve-SSRPM-OnboardingError -ErrorObject $ex
        $auditMessage = "Could not create or correlate SSRPM-Onboarding account. Error: $($errorObj.FriendlyMessage)"
        Write-Warning "Error at Line '$($errorObj.ScriptLineNumber)': $($errorObj.Line). Error: $($errorObj.ErrorDetails)"
    } else {
        $auditMessage = "Could not create or correlate SSRPM-Onboarding account. Error: $($ex.Exception.Message)"
        Write-Warning "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
    }
    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Message = $auditMessage
            IsError = $true
        })
}