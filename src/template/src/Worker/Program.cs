using Genocs.Core.Builders;
using Genocs.Library.Template.Contracts.Options;
using Genocs.Library.Template.Worker.Consumers;
using Genocs.Logging;
using Genocs.Monitoring;
using Genocs.Persistence.MongoDb.Extensions;
using MassTransit;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Serilog;

StaticLogger.EnsureInitialized();

IHost host = Host.CreateDefaultBuilder(args)
    .UseLogging()
    .ConfigureServices((hostContext, services) =>
    {
        services
            .AddGenocs(hostContext.Configuration)
            .AddMongoWithRegistration();

        AddCustomMassTransit(services, hostContext.Configuration);

        services.AddCustomOpenTelemetry(hostContext.Configuration);
    })
    .Build();

await host.RunAsync();

Log.CloseAndFlush();

static IServiceCollection AddCustomMassTransit(IServiceCollection services, IConfiguration configuration)
{
    var rabbitMQSettings = new RabbitMQSettings();
    configuration.GetSection(RabbitMQSettings.Position).Bind(rabbitMQSettings);

    services.AddSingleton(rabbitMQSettings);

    services.TryAddSingleton(KebabCaseEndpointNameFormatter.Instance);

    services.AddMassTransit(x =>
    {
        // Consumer configuration
        x.AddConsumersFromNamespaceContaining<SubmitOrderCommandConsumer>();

        x.UsingRabbitMq((context, cfg) =>
        {
            cfg.ConfigureEndpoints(context);

            // cfg.UseHealthCheck(context);
            cfg.Host(
                        rabbitMQSettings.HostName,
                        rabbitMQSettings.VirtualHost,
                        h =>
                        {
                            h.Username(rabbitMQSettings.UserName);
                            h.Password(rabbitMQSettings.Password);
                        });

            // This configuration allow to handle the Scheduling
            cfg.UseMessageScheduler(new Uri("queue:quartz"));
        });
    });

    return services;
}

Log.CloseAndFlush();