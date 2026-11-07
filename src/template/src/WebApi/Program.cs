using Genocs.Core.Builders;
using Genocs.Core.CQRS.Commands;
using Genocs.Core.CQRS.Events;
using Genocs.Core.CQRS.Queries;
using Genocs.Library.Template.WebApi;
using Genocs.Library.Template.WebApi.Infrastructure.Extensions;
using Genocs.LoadBalancing.Fabio;
using Genocs.Logging;
using Genocs.Messaging.RabbitMQ;
using Genocs.Messaging.Outbox;
using Genocs.Messaging.Outbox.MongoDB;
using Genocs.Persistence.MongoDB.Extensions;
using Genocs.Persistence.Redis;
using Genocs.Secrets.HashicorpKeyVault;
using Genocs.ServiceDiscovery.Consul;
using Genocs.Telemetry;
using Genocs.WebApi;
using Genocs.WebApi.OpenApi;
using Serilog;

StaticLogger.EnsureInitialized();

var builder = WebApplication.CreateBuilder(args);

builder.Host
        .UseLogging()
        .UseVault();

IGenocsBuilder gnxBuilder = builder.AddGenocs()
                                .AddTelemetry()
                                .AddErrorHandler<ExceptionToResponseMapper>()
                                .AddCorrelationContextLogging()
                                .AddMongo()
                                .AddMongoWithRegistration()
                                .AddServices()
                                .AddConsul()
                                .AddFabio()
                                .AddCommandHandlers()
                                .AddEventHandlers()
                                .AddQueryHandlers()
                                .AddInMemoryCommandDispatcher()
                                .AddInMemoryEventDispatcher()
                                .AddInMemoryQueryDispatcher()
                                .AddRedis()
                                .AddMessageOutbox(o => o.AddMongo())
                                .AddWebApi()
                                .AddOpenApiDocs();

await gnxBuilder.AddRabbitMQAsync();

var services = builder.Services;

services.AddCustomMassTransit(builder.Configuration);

var app = builder.Build();

gnxBuilder.Build(app.Services);

app.UseGenocs()
    .UseCorrelationContextLogging()
    .UseErrorHandler()
    .UseOpenApiDocs()
    .UseRouting();

// Uncomment the following line to enable HTTPS redirection.
// In case of using a reverse proxy like Fabio, you may want to keep it commented out to avoid issues with SSL termination.
// app.UseHttpsRedirection();

// global cors policy

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.MapDefaultEndpoints();

app.Run();

Log.CloseAndFlush();
