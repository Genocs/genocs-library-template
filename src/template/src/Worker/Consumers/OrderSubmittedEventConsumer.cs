using Genocs.Library.Template.Contracts.Events;
using MassTransit;

namespace Genocs.Library.Template.Worker.Consumers;

public class OrderSubmittedEventConsumer(ILogger<OrderSubmittedEventConsumer> logger) : IConsumer<OrderSubmittedEvent>
{
    private readonly ILogger<OrderSubmittedEventConsumer> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    public Task Consume(ConsumeContext<OrderSubmittedEvent> context)
    {
        _logger.LogInformation($"OrderRequest '{0}', '{1}' processing..", context.Message.OrderId, context.Message.UserId);

        // Do something with the message hereIConsumer<OrderSubmittedEvent>

        _logger.LogInformation($"OrderRequest '{0}', '{1}' processed!", context.Message.OrderId, context.Message.UserId);
        return Task.CompletedTask;
    }
}
