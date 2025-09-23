using Genocs.Library.Template.Contracts.Commands;
using Genocs.Library.Template.Contracts.Events;
using Genocs.Library.Template.Infrastructure.ApplicationServices;
using MassTransit;

namespace Genocs.Library.Template.Worker.Consumers;

public class SubmitOrderCommandConsumer(ILogger<SubmitOrderCommandConsumer> logger, IOrderProcessor orderProcessor) : IConsumer<SubmitOrderCommand>
{
    private readonly ILogger<SubmitOrderCommandConsumer> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    private readonly IOrderProcessor _processor = orderProcessor ?? throw new ArgumentNullException(nameof(orderProcessor));

    public async Task Consume(ConsumeContext<SubmitOrderCommand> context)
    {
        // Process the order
        await _processor.ProcessOrderSync(context.Message.OrderId, context.Message.UserId);

        // Publish an event indicating the order has been submitted
        await context.Publish(new OrderSubmittedEvent() { OrderId = context.Message.OrderId, UserId = context.Message.UserId });

        _logger.LogInformation($"Order {context.Message.OrderId} processed!");
    }
}