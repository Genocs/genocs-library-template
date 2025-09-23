using Genocs.Core.CQRS.Events;
using Genocs.Library.Template.Contracts.ReadModels;

namespace Genocs.Library.Template.Contracts.Events;

public class OrderSubmittedEvent : IEvent
{
    public string OrderId { get;  set; } = default!;
    public string UserId { get;  set; } = default!;
    public DateTime TimeStamp { get; private set; } = DateTime.UtcNow;
    public string CardToken { get; set; } = default!;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = default!;

    public List<Product> Basket { get; set; } = default!;
}

