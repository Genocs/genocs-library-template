using Genocs.Library.Template.Contracts.Commands;
using Genocs.Library.Template.WebApi.Models;
using MassTransit;
using Microsoft.AspNetCore.Mvc;
using System.Net.Mime;

namespace Genocs.Library.Template.WebApi.Controllers;

/// <summary>
/// Demo controller for testing MassTransit message publishing functionality.
/// Provides endpoints to publish demo commands and events through the message bus.
/// </summary>
/// <remarks>
/// Initializes a new instance of the <see cref="DemoController"/> class.
/// </remarks>
/// <param name="logger">The logger instance for logging operations.</param>
/// <param name="publishEndpoint">The MassTransit publish endpoint for message publishing.</param>
/// <exception cref="ArgumentNullException">Thrown when logger or publishEndpoint is null.</exception>
[ApiController]
[Route("[controller]")]
public class DemoController(ILogger<DemoController> logger, IPublishEndpoint publishEndpoint) : ControllerBase
{
    private readonly IPublishEndpoint _publishEndpoint = publishEndpoint ?? throw new ArgumentNullException(nameof(publishEndpoint));

    private readonly ILogger<DemoController> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    /// <summary>
    /// Publishes a demo SubmitOrder command to the message bus.
    /// Creates a new order with randomly generated OrderId and UserId for testing purposes.
    /// </summary>
    /// <returns>
    /// Returns a success message indicating the command was published.
    /// </returns>
    /// <response code="200">Command was successfully published to the message bus.</response>
    /// <example>
    /// POST /Demo/SubmitDemoCommand
    /// 
    /// Response: "Sent"
    /// </example>
    [HttpPost("SubmitDemoCommand")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
    public async Task<IActionResult> PostSubmitDemoCommand()
    {
        // Publish an event with MassTransit
        await _publishEndpoint.Publish<SubmitOrder>(new
        {
            OrderId = Guid.NewGuid().ToString(),
            UserId = Guid.NewGuid().ToString()
        });

        _logger.LogInformation("SubmitOrder Sent");

        return Ok("Sent");
    }

    /// <summary>
    /// Publishes a demo OrderSubmitted event to the message bus.
    /// Creates an order status change event with predefined test data for demonstration purposes.
    /// </summary>
    /// <returns>
    /// Returns a success message indicating the event was published.
    /// </returns>
    /// <response code="200">Event was successfully published to the message bus.</response>
    /// <example>
    /// POST /Demo/SubmitDemoEvent
    /// 
    /// Response: "Sent"
    /// </example>
    /// <remarks>
    /// This endpoint publishes an OrderSubmitted event with:
    /// - MerchantId: "0988656"
    /// - OldStatus: "Approved"
    /// - Status: "Rejected"
    /// 
    /// This simulates an order status change from Approved to Rejected.
    /// </remarks>
    [HttpPost("SubmitDemoEvent")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
    public async Task<IActionResult> PostSubmitDemoEvent()
    {
        // Publish an event with MassTransit
        await _publishEndpoint.Publish<OrderSubmitted>(new
        {
            MerchantId = "0988656",
            OldStatus = "Approved",
            Status = "Rejected"
        });

        _logger.LogInformation("OrderSubmitted Sent");

        return Ok("Sent");
    }
}
