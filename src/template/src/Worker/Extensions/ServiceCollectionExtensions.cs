using Genocs.Library.Template.Contracts.Options;
using Genocs.Library.Template.Infrastructure.ApplicationServices;
using Genocs.Library.Template.Worker.Consumers;
using MassTransit;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace Genocs.Library.Template.Worker.Extensions;
public static class ServiceCollectionExtensions
{
    public static IServiceCollection RegisterApplicationServices(this IServiceCollection services)
    {
        services.AddTransient<IOrderProcessor, OrderProcessor>();
        return services;
    }

    public static IServiceCollection AddCustomMassTransit(this IServiceCollection services, IConfiguration configuration)
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
}
