var builder = WebApplication.CreateBuilder(args);

// Add services if needed
builder.Services.AddApplicationInsightsTelemetry();

var app = builder.Build();

// Configure the HTTP request pipeline
app.MapGet("/hello", () => "Hello from Minimal API!");

app.MapGet("/error", () =>
{
    // Simulate an internal server error
    return Results.StatusCode(500);
});

app.Run();