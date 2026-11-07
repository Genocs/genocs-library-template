using Genocs.Library.Template.Domain.Aggregates;
using Genocs.Persistence.MongoDB.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace Genocs.Library.Template.Infrastructure.ApplicationServices;

public class OrderProcessor(ILogger<OrderProcessor> logger, IMongoRepository<Order> orderRepository) : IOrderProcessor
{
    private readonly ILogger<OrderProcessor> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    private readonly IMongoRepository<Order> _orderRepository = orderRepository ?? throw new ArgumentNullException(nameof(orderRepository));

    public async Task ProcessOrderSync(string orderId, string userId)
    {
        Order order = new Order(orderId, userId, string.Empty, 1, "EUR");
        await _orderRepository.InsertAsync(order);

        // Implementation for processing the order
        _logger.LogInformation($"Processed order with ID: {orderId}");
    }
}
