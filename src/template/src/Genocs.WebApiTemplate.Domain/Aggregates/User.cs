﻿using Genocs.Core.Domain.Entities.Auditing;
using Genocs.Core.Domain.Repositories;
using Genocs.Persistence.MongoDb.Repositories;
using MongoDB.Bson;

namespace Genocs.WebApiTemplate.Domain.Aggregates;

[TableMapping("Users")]
public class User : IMongoDbEntity, IHasCreationTime
{

    public ObjectId Id { get; set; }
    public string UserId { get; set; } = default!;
    public DateTime CreationTime { get; set; } = DateTime.UtcNow;
    public string Username { get; set; } = default!;
    public decimal Age { get; set; }
    public string Country { get; set; } = default!;

    public User(string userId, string username, decimal age, string country)
    {
        Id = ObjectId.GenerateNewId();
        UserId = userId;
        Username = username;
        Age = age;
        Country = country;
    }

    public bool IsTransient()
    {
        return true;
    }
}
