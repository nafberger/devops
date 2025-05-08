# check-app.ps1
$webAppUrl = "https://my-helo-app.azurewebsites.net/hello"
$errorUrl = "https://my-helo-app.azurewebsites.net/error"
$functionUrl = "https://my-helo-function.azurewebsites.net/api/LogError?code=""

# Check Web App health
try {
    $response = Invoke-WebRequest -Uri $webAppUrl -Method Get
    if ($response.StatusCode -eq 200) {
        Write-Output "✅ Web App is healthy: Status Code $($response.StatusCode)"
    }
} catch {
    Write-Output "❌ Web App check failed: $($_.Exception.Message)"
    $errorDetails = @{ ErrorCode = 500; Message = "Web App health check failed" } | ConvertTo-Json
    Invoke-WebRequest -Uri $functionUrl -Method Post -Body $errorDetails -ContentType "application/json"
}

# Simulate errors
for ($i = 0; $i -lt 6; $i++) {
    Invoke-WebRequest -Uri $errorUrl -Method Get | Out-Null
    Write-Output "Triggered /error endpoint $($i + 1)/6"
}