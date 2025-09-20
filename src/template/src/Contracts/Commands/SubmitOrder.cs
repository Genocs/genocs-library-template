namespace Genocs.Library.Template.Contracts.Commands;

public class SubmitOrder(string orderId, string userId)
{
    private Guid Id { get; } = Guid.NewGuid();

    public string OrderId { get; private set; } = orderId;
    public string UserId { get; private set; } = userId;

}
