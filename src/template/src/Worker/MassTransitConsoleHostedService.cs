using MassTransit;

namespace Genocs.Library.Template.Worker;

/// <summary>
/// General purpose worker. Please check the link below for further information
/// https://learn.microsoft.com/en-us/aspnet/core/fundamentals/host/hosted-services?view=aspnetcore-7.0&tabs=visual-studio.
/// </summary>
public class MassTransitConsoleHostedService(IBusControl bus, ILogger<MassTransitConsoleHostedService> logger) : IHostedService
{
    private readonly IBusControl _bus = bus ?? throw new ArgumentNullException(nameof(bus));
    private readonly ILogger<MassTransitConsoleHostedService> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("MassTransitConsoleHostedService StartAsync called!");

        // await _bus.StartAsync(cancellationToken).ConfigureAwait(false);
        await Task.CompletedTask;
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("MassTransitConsoleHostedService StopAsync called!");

        // return _bus.StopAsync(cancellationToken);
        return Task.CompletedTask;
    }
}
