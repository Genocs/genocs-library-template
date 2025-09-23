using Genocs.Library.Template.Contracts.Options;
using Genocs.Library.Template.Infrastructure;
using Genocs.Library.Template.Worker.Consumers;
using MassTransit;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace Genocs.Library.Template.Worker.Extensions;

/// <summary>
/// Extension methods for configuring services in the dependency injection container.
/// Provides methods for registering application services and configuring MassTransit with RabbitMQ.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registers all application services that implement IApplicationService interface using automatic discovery.
    /// Uses Scrutor for convention-based registration of services with their corresponding interfaces.
    /// </summary>
    /// <param name="services">The service collection to add services to.</param>
    /// <returns>The service collection for method chaining.</returns>
    /// <remarks>
    /// <para>
    /// This method automatically discovers and registers all classes that implement IApplicationService
    /// from the Infrastructure assembly. Services are registered as transient with their corresponding interfaces.
    /// </para>
    /// <para>
    /// The registration follows these conventions:
    /// - Classes ending with "Service" are registered with interfaces starting with "I" and ending with "Service"
    /// - Classes ending with "Processor" are registered with interfaces starting with "I" and ending with "Processor"
    /// - All registrations use transient lifetime
    /// </para>
    /// <para>
    /// Manual registrations can still be added after this method call to override or supplement
    /// the automatic registration when needed for specific services.
    /// </para>
    /// </remarks>
    public static IServiceCollection RegisterApplicationServices(this IServiceCollection services)
    {
        // Register All the application services using Scrutor for automatic interface discovery
        // Application Services are the services that contain the business logic of the application
        // All the application services inherit from IApplicationService

        // Automatic registration using Scrutor pattern
        services.Scan(scan => scan
            .FromAssemblyOf<IApplicationService>() // Scan the Infrastructure assembly
            .AddClasses(classes => classes.AssignableTo<IApplicationService>()) // Find classes implementing IApplicationService
            .AsImplementedInterfaces() // Register them as their implemented interfaces
            .WithTransientLifetime()); // Use transient lifetime

        // Manual registrations can be added here for specific cases or overrides
        // Example: services.AddTransient<ISpecificService, SpecificService>();

        return services;
    }

    /// <summary>
    /// Configures and adds MassTransit with RabbitMQ transport to the service collection.
    /// Sets up message consumers, RabbitMQ connection, and message scheduling capabilities.
    /// </summary>
    /// <param name="services">The service collection to add MassTransit services to.</param>
    /// <param name="configuration">The configuration instance containing RabbitMQ settings.</param>
    /// <returns>The service collection for method chaining.</returns>
    /// <remarks>
    /// <para>
    /// This method configures MassTransit with the following features:
    /// - RabbitMQ as the message transport
    /// - Automatic consumer discovery from the current assembly
    /// - Kebab-case endpoint naming convention
    /// - Message scheduling support using Quartz
    /// - Connection configuration from appsettings.json
    /// </para>
    /// <para>
    /// Required configuration section: "RabbitMQSettings" with properties:
    /// - HostName: RabbitMQ server hostname
    /// - VirtualHost: Virtual host name
    /// - UserName: Authentication username
    /// - Password: Authentication password
    /// </para>
    /// </remarks>
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
