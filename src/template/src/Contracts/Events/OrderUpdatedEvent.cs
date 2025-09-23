using Genocs.Core.CQRS.Events;

namespace Genocs.Library.Template.Contracts.Events;

public class OrderUpdatedEvent : IEvent
{
    public string Name { get; set; }
    public string Address { get; set; }

    public OrderUpdatedEvent(string name, string address)
        => (Name, Address) = (name, address);
}
