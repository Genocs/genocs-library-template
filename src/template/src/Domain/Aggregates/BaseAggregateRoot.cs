using Genocs.Common.Domain.Entities.Auditing;
using Genocs.Core.Domain.Entities;
using Genocs.Persistence.MongoDB.Domain.Entities;
using MongoDB.Bson;

namespace Genocs.Library.Template.Domain.Aggregates;

/// <summary>
/// Base class for aggregate roots with MongoDB ObjectId as the primary key.
/// Use this class for aggregate roots that require creation time tracking.
/// </summary>
public abstract class BaseAggregateRoot : AggregateRoot<ObjectId>, IMongoEntity, IHasCreationTime
{
    /// <summary>
    /// The creation time of the entity.
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
