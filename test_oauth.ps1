# Test M-Pesa OAuth Token Generation
$consumerKey = "8An32lxeMj9PYYOLVDLsGFllTqAJRyNw"
$consumerSecret = "UnGPrTj4AGhQMLD5"
$credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$consumerKey`:$consumerSecret"))

$headers = @{
    "Authorization" = "Basic $credentials"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials" -Method GET -Headers $headers
    Write-Host "OAuth Token Generated Successfully!"
    Write-Host "Access Token: $($response.access_token)"
    Write-Host "Expires In: $($response.expires_in) seconds"
} catch {
    Write-Host "OAuth Token Generation Failed!"
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)"
    Write-Host "Error: $($_.Exception.Message)"
    Write-Host "Response: $($_.Exception.Response.GetResponseStream())"
}
