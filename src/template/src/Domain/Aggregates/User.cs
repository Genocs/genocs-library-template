using Genocs.Core.Domain.Repositories;

namespace Genocs.Library.Template.Domain.Aggregates;

/// <summary>
/// Represents a user aggregate root entity in the domain model.
/// This class encapsulates user information and is mapped to the "Users" collection in MongoDB.
/// Inherits from BaseAggregateRoot to provide ObjectId primary key and creation time tracking.
/// </summary>
/// <remarks>
/// <para>
/// The User aggregate is the primary entity for managing user-related data within the system.
/// It includes basic user information such as identification, personal details, and location.
/// </para>
/// <para>
/// This class uses C# 13 primary constructor syntax for concise initialization.
/// All properties are mutable to support entity framework and serialization scenarios.
/// </para>
/// <para>
/// The TableMapping attribute maps this entity to the "Users" collection in MongoDB,
/// allowing the repository pattern to correctly persist and retrieve user data.
/// </para>
/// </remarks>
[TableMapping("Users")]
public class User(string userId, string username, decimal age, string country) : BaseAggregateRoot
{
    /// <summary>
    /// Gets or sets the unique identifier for the user within the business domain.
    /// This is distinct from the MongoDB ObjectId and represents the business key.
    /// </summary>
    /// <value>
    /// A string value representing the user's unique identifier.
    /// Typically a GUID string or other business-specific identifier.
    /// </value>
    /// <remarks>
    /// This property serves as the business identifier and should be unique across all users.
    /// It is separate from the Id property inherited from BaseAggregateRoot which contains the MongoDB ObjectId.
    /// </remarks>
    public string UserId { get; set; } = userId;

    /// <summary>
    /// Gets or sets the username for the user account.
    /// Used for identification and display purposes within the application.
    /// </summary>
    /// <value>
    /// A string value representing the user's chosen username or display name.
    /// </value>
    /// <remarks>
    /// The username may be used for login purposes or as a display name.
    /// Consider implementing uniqueness constraints at the application or database level
    /// if usernames must be unique across the system.
    /// </remarks>
    public string Username { get; set; } = username;

    /// <summary>
    /// Gets or sets the age of the user in years.
    /// Stored as a decimal to allow for precise age calculations if needed.
    /// </summary>
    /// <value>
    /// A decimal value representing the user's age in years.
    /// Should be a positive value representing a valid human age.
    /// </value>
    /// <remarks>
    /// Using decimal type allows for fractional ages if precise age tracking is required.
    /// Consider implementing validation to ensure age values are within reasonable bounds
    /// (e.g., between 0 and 150 years).
    /// </remarks>
    public decimal Age { get; set; } = age;

    /// <summary>
    /// Gets or sets the country code or name where the user is located.
    /// Used for localization, regional services, and compliance purposes.
    /// </summary>
    /// <value>
    /// A string value representing the user's country.
    /// May be a country code (e.g., "USA", "ITA") or full country name.
    /// </value>
    /// <remarks>
    /// Consider standardizing on ISO 3166-1 country codes for consistency.
    /// This information can be used for:
    /// - Regional content delivery
    /// - Compliance with local regulations
    /// - Localized user experiences
    /// - Geographic analytics
    /// </remarks>
    public string Country { get; set; } = country;
}
