using Genocs.Core.CQRS.Commands;

namespace Genocs.Library.Template.Contracts.Commands;

public class SubmitDeleteOrder(string orderId) : ICommand
{
    public string OrderId { get; private set; } = orderId;
}
