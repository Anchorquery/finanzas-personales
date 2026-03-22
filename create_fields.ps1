$ErrorActionPreference = "Stop"

try {
    # 1. Login
    Write-Host "Logging in..."
    $loginBody = @{
        email = "admin@finanzas.local"
        password = "admin"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8056/auth/login" -Method Post -ContentType "application/json" -Body $loginBody
    $token = $loginResponse.data.access_token
    Write-Host "Login successful."

    # 2. Define Fields
    $fields = @(
        @{
            field = "exchange_rate_mode"
            type = "string"
            meta = @{
                interface = "select-dropdown"
                options = @{
                    choices = @(
                        @{ text = "Manual"; value = "manual" },
                        @{ text = "BCV (USD)"; value = "ExchangeRateProvider.bcv" },
                        @{ text = "BCV (EUR)"; value = "ExchangeRateProvider.bcvEur" },
                        @{ text = "Binance"; value = "ExchangeRateProvider.binance" },
                        @{ text = "Paralelo"; value = "ExchangeRateProvider.parallel" }
                    )
                }
                note = "Mode for exchange rate calculation"
            }
        },
        @{
            field = "manual_exchange_rate"
            type = "float"
            meta = @{
                interface = "input"
                note = "Exchange rate if mode is Manual"
            }
        },
        @{
            field = "secondary_currency"
            type = "string"
            meta = @{
                interface = "input"
                note = "Secondary currency code (e.g. VES)"
            }
            schema = @{
                default_value = "VES"
            }
        }
    )

    # 3. Create Fields
    foreach ($fieldDef in $fields) {
        $fieldName = $fieldDef.field
        Write-Host "Creating field: $fieldName ..."
        
        try {
            # Check if exists first to avoid error? No, let's try create and catch 409/Exists
            # Or just Try Create
            $body = $fieldDef | ConvertTo-Json -Depth 10
            Invoke-RestMethod -Uri "http://localhost:8056/fields/workspaces" -Method Post -ContentType "application/json" -Headers @{Authorization="Bearer $token"} -Body $body
            Write-Host "Field $fieldName created successfully."
        } catch {
            $err = $_.Exception.Response.StatusCode.value__
            # 403 or 409 means exists usually? Directus returns 403 Forbidden if field makes conflict sometimes?
            # Actually standard is 400 or 200.
            Write-Host "Failed to create $fieldName (might exist): $($_.Exception.Message)"
            # Print response body if possible
             $stream = $_.Exception.Response.GetResponseStream()
             $reader = New-Object System.IO.StreamReader($stream)
             $respBody = $reader.ReadToEnd()
             Write-Host "Response: $respBody"
        }
    }

} catch {
    Write-Error "Script failed: $_"
    exit 1
}
