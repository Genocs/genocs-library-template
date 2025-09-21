using Genocs.Library.Template.Domain.Aggregates;
using Genocs.Persistence.MongoDb.Domain.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Genocs.Library.Template.WebApi.Controllers;

/// <summary>
/// Controller for demonstrating MongoDB repository operations.
/// Provides endpoints to test and interact with MongoDB database through the repository pattern.
/// </summary>
/// <remarks>
/// Initializes a new instance of the <see cref="MongoDbRepositoryController"/> class.
/// </remarks>
/// <param name="logger">The logger instance for logging operations.</param>
/// <param name="userRepository">The MongoDB repository for User entity operations.</param>
/// <exception cref="ArgumentNullException">Thrown when logger or userRepository is null.</exception>
[ApiController]
[Route("[controller]")]
public class MongoDbRepositoryController(ILogger<MongoDbRepositoryController> logger, IMongoDbRepository<User> userRepository) : ControllerBase
{
    private readonly IMongoDbRepository<User> _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));

    private readonly ILogger<MongoDbRepositoryController> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    /// <summary>
    /// Health check endpoint for the MongoDB repository controller.
    /// Returns a simple message to verify the controller is accessible and functioning.
    /// </summary>
    /// <returns>
    /// Returns a success message indicating the controller is operational.
    /// </returns>
    /// <response code="200">Controller is accessible and functioning properly.</response>
    /// <example>
    /// GET /MongoDbRepository
    /// 
    /// Response: "MongoDbRepositoryController"
    /// </example>
    /// <remarks>
    /// This endpoint can be used for health checks or to verify that the MongoDB repository controller
    /// is properly configured and accessible within the application.
    /// </remarks>
    [HttpGet]
    [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
    public IActionResult Get()
        => Ok("MongoDbRepositoryController");

    /// <summary>
    /// Creates and inserts a dummy user record into the MongoDB database for testing purposes.
    /// Generates a new User entity with random GUIDs for UserId and Username, along with predefined test data.
    /// </summary>
    /// <returns>
    /// Returns the created User entity with populated fields including the generated MongoDB ObjectId.
    /// </returns>
    /// <response code="200">User was successfully created and inserted into the database.</response>
    /// <response code="500">Internal server error occurred during database operation.</response>
    /// <example>
    /// POST /MongoDbRepository/dummy
    /// 
    /// Response:
    /// {
    ///   "id": "507f1f77bcf86cd799439011",
    ///   "userId": "550e8400-e29b-41d4-a716-446655440000",
    ///   "username": "123e4567-e89b-12d3-a456-426614174000",
    ///   "age": 21,
    ///   "country": "ITA",
    ///   "createdAt": "2023-12-07T10:30:00Z"
    /// }
    /// </example>
    /// <remarks>
    /// <para>
    /// This endpoint is designed for testing and demonstration purposes. It creates a User entity with:
    /// - UserId: Randomly generated GUID converted to string
    /// - Username: Randomly generated GUID converted to string  
    /// - Age: Fixed value of 21
    /// - Country: Fixed value of "ITA" (Italy)
    /// - CreatedAt: Automatically set by the repository
    /// </para>
    /// <para>
    /// The User entity is mapped to the "Users" collection in MongoDB as indicated by the TableMapping attribute.
    /// The returned User object includes the MongoDB-generated ObjectId and timestamp information.
    /// </para>
    /// <para>
    /// In a production environment, this endpoint should be replaced with proper user creation logic
    /// that accepts real user data and implements appropriate validation and business rules.
    /// </para>
    /// </remarks>
    [HttpPost("dummy")]
    [ProducesResponseType(typeof(User), StatusCodes.Status200OK)]
    public async Task<IActionResult> PostDummy()
    {
        User user = new User(Guid.NewGuid().ToString(), Guid.NewGuid().ToString(), 21, "ITA");
        var result = await _userRepository.InsertAsync(user);
        return Ok(result);
    }
}
