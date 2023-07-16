﻿using Genocs.Core.Domain.Entities;
using Genocs.Core.Domain.Entities.Auditing;
using Genocs.Core.Domain.Repositories;
using Genocs.Persistence.MongoDb.Repositories;

namespace Genocs.WebApiTemplate.Domain.Aggregates;

[TableMapping("Orders")]
public class Order : AggregateRoot<Guid>, IMongoDbEntity, IHasCreationTime
{
    public Order(string orderId, string userId, string cardToken, decimal amount, string currency)
    {
        OrderId = orderId;
        UserId = userId;
        CardToken = cardToken;
        Amount = amount;
        Currency = currency;
    }

    public string OrderId { get; set; } = Guid.NewGuid().ToString();
    public string UserId { get; set; } = default!;
    public DateTime CreationTime { get; set; } = DateTime.UtcNow;
    public string CardToken { get; set; } = default!;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = default!;
}
