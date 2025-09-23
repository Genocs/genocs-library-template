using Genocs.Library.Template.Contracts.Commands;
using Genocs.Library.Template.Contracts.Events;
using Genocs.Library.Template.Domain.Aggregates;
using Genocs.Persistence.MongoDb.Domain.Repositories;
using MassTransit;

namespace Genocs.Library.Template.Worker.Consumers;

public class SubmitOrderCommandConsumer(ILogger<SubmitOrderCommandConsumer> logger, IMongoDbRepository<Order> orderRepository) : IConsumer<SubmitOrderCommand>
{
    private readonly ILogger<SubmitOrderCommandConsumer> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    private readonly IMongoDbRepository<Order> _orderRepository = orderRepository ?? throw new ArgumentNullException(nameof(orderRepository));

    public async Task Consume(ConsumeContext<SubmitOrderCommand> context)
    {
        Order order = new Order(context.Message.OrderId, context.Message.UserId, string.Empty, 1, "EUR");
        await _orderRepository.InsertAsync(order);

        await context.Publish(new OrderSubmittedEvent() { OrderId = context.Message.OrderId, UserId = context.Message.UserId });

        _logger.LogInformation($"Order {context.Message.OrderId} processed!");
    }
}