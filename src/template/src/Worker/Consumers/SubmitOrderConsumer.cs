using Genocs.Library.Template.Contracts.Commands;
using Genocs.Library.Template.Domain.Aggregates;
using Genocs.Persistence.MongoDb.Domain.Repositories;
using MassTransit;

namespace Genocs.Library.Template.Worker.Consumers;

public class SubmitOrderConsumer(ILogger<SubmitOrderConsumer> logger, IMongoDbRepository<Order> orderRepository) : IConsumer<SubmitOrder>
{
    private readonly ILogger<SubmitOrderConsumer> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    private readonly IMongoDbRepository<Order> _orderRepository = orderRepository ?? throw new ArgumentNullException(nameof(orderRepository));

    public async Task Consume(ConsumeContext<SubmitOrder> context)
    {
        Order order = new Order(context.Message.OrderId, context.Message.UserId, string.Empty, 1, "EUR");
        await _orderRepository.InsertAsync(order);
        _logger.LogInformation($"Order {context.Message.OrderId} processed!");
    }
}