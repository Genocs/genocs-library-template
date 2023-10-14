﻿using Genocs.Core.CQRS.Events;

namespace Genocs.Library.Template.Contracts.Events;

public class OrderRequest : IEvent
{
    public string OrderId { get; set; } = Guid.NewGuid().ToString();
    public string UserId { get; set; } = default!;
    public DateTime TimeStamp { get; set; } = DateTime.UtcNow;
    public string CardToken { get; set; } = default!;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = default!;

    public List<Product> Basket { get; set; } = default!;
}

public class Product
{
    public string SKU { get; private set; }
    public int Count { get; private set; }
    public decimal Price { get; private set; }

    public Product(string sKU, int count, decimal price)
    {
        SKU = sKU;
        Count = count;
        Price = price;
    }
}
