using Genocs.Library.Template.Domain.Aggregates;
using Genocs.Persistence.MongoDb.Domain.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Genocs.Library.Template.WebApi.Controllers;

[ApiController]
[Route("[controller]")]
public class MongoDbRepositoryController(ILogger<MongoDbRepositoryController> logger, IMongoDbRepository<User> userRepository) : ControllerBase
{
    private readonly IMongoDbRepository<User> _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));

    private readonly ILogger<MongoDbRepositoryController> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    [HttpGet]
    [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
    public IActionResult Get()
        => Ok(nameof(MongoDbRepositoryController));

    [HttpPost("insert-mongodb-dummy")]
    [ProducesResponseType(typeof(User), StatusCodes.Status200OK)]
    public async Task<IActionResult> PostInsertMongoDbDummyUserAsync()
    {
        _logger.LogInformation("Creating and inserting a dummy user into MongoDB...");
        User user = new User(Guid.NewGuid().ToString(), Guid.NewGuid().ToString(), 21, "ITA");
        var result = await _userRepository.InsertAsync(user);
        return Ok(result);
    }
}
