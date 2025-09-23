using Genocs.Core.CQRS.Commands;

namespace Genocs.Library.Template.Contracts.Commands;

public class SubmitOrderCommand(string orderId, string userId) : ICommand
{
    public string OrderId { get; private set; } = orderId;
    public string UserId { get; private set; } = userId;
}
