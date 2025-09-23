using Genocs.Core.CQRS.Events;
using Genocs.Library.Template.Contracts.Events;

namespace Genocs.Library.Template.Worker.Handlers;

public class OrderUpdatedEventHandler : IEventHandler<OrderUpdatedEvent>
{
    private readonly ILogger<OrderUpdatedEventHandler> _logger;

    public OrderUpdatedEventHandler(ILogger<OrderUpdatedEventHandler> logger)
    {
        _logger = logger;
    }

    public Task HandleAsync(OrderUpdatedEvent @event, CancellationToken cancellationToken)
    {
        _logger.LogInformation($"DemoEvent '{@event.Name}' processed!");

        // Do something with the message here
        return Task.CompletedTask;
    }
}