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
        var client = clientFactory.CreateClient();
        var functionUrl = "https://my-helo-function.azurewebsites.net/api/LogError?code=<your-function-key>";
        var errorDetails = new { ErrorCode = 500, Message = "Internal Server Error from /error endpoint" };
        var content = new StringContent(System.Text.Json.JsonSerializer.Serialize(errorDetails), System.Text.Encoding.UTF8, "application/json");

        var response = await client.PostAsync(functionUrl, content);
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