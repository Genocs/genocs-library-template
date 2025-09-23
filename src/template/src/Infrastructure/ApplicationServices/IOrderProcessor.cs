namespace Genocs.Library.Template.Infrastructure.ApplicationServices;

public interface IOrderProcessor : IApplicationService
{
    Task ProcessOrderSync(string orderId, string userId);
}
