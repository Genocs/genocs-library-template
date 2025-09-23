using System.Net.Mime;
using Genocs.Library.Template.Contracts.Commands;
using Genocs.Library.Template.Contracts.Events;
using Genocs.Library.Template.WebApi.Models;
using MassTransit;
using Microsoft.AspNetCore.Mvc;

namespace Genocs.Library.Template.WebApi.Controllers;

[ApiController]
[Route("[controller]")]
public class ServiceBusMassTransitController(ILogger<ServiceBusMassTransitController> logger, IPublishEndpoint publishEndpoint) : ControllerBase
{
    private readonly IPublishEndpoint _publishEndpoint = publishEndpoint ?? throw new ArgumentNullException(nameof(publishEndpoint));

    private readonly ILogger<ServiceBusMassTransitController> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    [HttpPost("SubmitOrder")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(typeof(string), StatusCodes.Status202Accepted)]
    public async Task<IActionResult> PostSubmitOrder()
    {
        SubmitOrderCommand submitOrder = new SubmitOrderCommand(Guid.NewGuid().ToString(), Guid.NewGuid().ToString());

        // Publish an event with MassTransit
        await _publishEndpoint.Publish(submitOrder);

        _logger.LogInformation("SubmitOrder Sent");

        return Accepted(submitOrder.OrderId);
    }

    [HttpPost("OrderSubmitted")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(typeof(string), StatusCodes.Status202Accepted)]
    public async Task<IActionResult> PostOrderSubmitted()
    {
        OrderSubmitted orderSubmitted = new OrderSubmitted("0988656", "Approved");

        // Publish an event with MassTransit
        await _publishEndpoint.Publish(orderSubmitted);

        _logger.LogInformation("OrderSubmitted Sent");

        await _publishEndpoint.Publish(new OrderSubmittedEvent() { OrderId = orderSubmitted.OrderId, UserId = orderSubmitted.UserId });

        return Accepted(orderSubmitted.OrderId);
    }
}
