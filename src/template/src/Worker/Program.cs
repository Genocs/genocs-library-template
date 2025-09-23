using Genocs.Core.Builders;
using Genocs.Library.Template.Worker.Extensions;
using Genocs.Logging;
using Genocs.Monitoring;
using Genocs.Persistence.MongoDb.Extensions;
using Serilog;

StaticLogger.EnsureInitialized();

IHost host = Host.CreateDefaultBuilder(args)
    .UseLogging()
    .ConfigureServices((hostContext, services) =>
    {
        services
            .AddGenocs(hostContext.Configuration)
            .AddMongoWithRegistration();

        services.AddCustomMassTransit(hostContext.Configuration)
                .AddCustomOpenTelemetry(hostContext.Configuration)
                .RegisterApplicationServices();
    })
    .Build();

await host.RunAsync();

Log.CloseAndFlush();