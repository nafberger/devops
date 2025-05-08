using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var builder = WebApplication.CreateBuilder(args);

// Add Application Insights for telemetry
builder.Services.AddApplicationInsightsTelemetry();

// Add HttpClient for calling the Azure Function
builder.Services.AddHttpClient();

var app = builder.Build();

// Configure the HTTP request pipeline
app.MapGet("/hello", () => "Hello from Minimal API!");

app.MapGet("/error", async (IHttpClientFactory clientFactory) =>
{
    try
    {
        var httpClient = clientFactory.CreateClient();

        string keyVaultUrl = "https://ship-soft-kv.vault.azure.net/"; // Your Key Vault URL
        string secretName = "MyHelloFunctionApp"; // The name of the secret in Key Vault

        var credential = new DefaultAzureCredential();
        var secretClient = new SecretClient(new Uri(keyVaultUrl), credential);

        KeyVaultSecret secret = secretClient.GetSecret(secretName);
        string functionKey = secret.Value; // The actual function key

        // Step 2: Construct the function URL with the retrieved key
        string functionUrl = $"https://my-hello-function.azurewebsites.net/api/LOGERROR?code={functionKey}";

        var errorDetails = new { ErrorCode = 500, Message = "Internal Server Error from /error endpoint" };
        var content = new StringContent(System.Text.Json.JsonSerializer.Serialize(errorDetails), System.Text.Encoding.UTF8, "application/json");

        var response = await httpClient.PostAsync(functionUrl, content);
        if (!response.IsSuccessStatusCode)
        {
            app.Logger.LogError($"Failed to log error to Azure Function: {response.StatusCode}");
        }

        return Results.StatusCode(500);
    }
    catch (Exception ex)
    {
        app.Logger.LogError($"Error in /error endpoint: {ex.Message}");
        return Results.StatusCode(500);
    }
});

app.Run();