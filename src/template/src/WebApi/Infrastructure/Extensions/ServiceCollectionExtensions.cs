using Genocs.Library.Template.Contracts.Options;
using MassTransit;

namespace Genocs.Library.Template.WebApi.Infrastructure.Extensions;

public static class ServiceCollectionExtensions
{

    public static IServiceCollection AddCustomMassTransit(this IServiceCollection services, IConfiguration configuration)
    {
        var rabbitMQSettings = new RabbitMQSettings();
        configuration.GetSection(RabbitMQSettings.Position).Bind(rabbitMQSettings);

        services.AddSingleton(rabbitMQSettings);

        services.AddMassTransit(x =>
        {
            // x.AddConsumersFromNamespaceContaining<MerchantStatusChangedEvent>();

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
            });
        });

        return services;
    }
}
