using Genocs.Core.Builders;
using Genocs.Library.Template.Worker.Extensions;
using Genocs.Logging;
using Genocs.Persistence.MongoDB.Extensions;
using Genocs.Telemetry;
using Serilog;

StaticLogger.EnsureInitialized();

IHost host = Host.CreateDefaultBuilder(args)
    .UseLogging()
    .ConfigureServices((hostContext, services) =>
    {
        services
            .AddCustomMassTransit(hostContext.Configuration)
            .RegisterApplicationServices()
            .AddGenocs(hostContext.Configuration)
            .AddMongoWithRegistration()
            .AddTelemetry();
    })
    .Build();

await host.RunAsync();

Log.CloseAndFlush();