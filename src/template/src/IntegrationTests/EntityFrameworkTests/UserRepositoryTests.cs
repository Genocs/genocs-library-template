using Xunit;

namespace Genocs.Library.Template.IntegrationTests.EntityFrameworkTests;

public sealed class UserRepositoryTests
{
    [Fact]
    public async Task AddChangesDatabaseAsync()
    {
        await Task.CompletedTask;

        /*
        var options = new DbContextOptionsBuilder<GenocsContext>()
            .UseInMemoryDatabase(databaseName: "test_database")
            .Options;

        var factory = new EntityFactory();

        var customer = factory.NewCustomer(
            new SSN("198608177955"),
            new Name("Nocco Giovanni Emanuele"));

        using (var context = new GenocsContext(options))
        {
            context.Database.EnsureCreated();

            var repository = new CustomerRepository(context);
            await repository.Add(customer);

            Assert.Equal(2, context.Customers.Count());
        }
    }

    [Fact]
    public async Task Get_ReturnsCustomer()
    {
        var options = new DbContextOptionsBuilder<GenocsContext>()
            .UseInMemoryDatabase(databaseName: "test_database")
            .Options;

        ICustomer customer = null;

        using (var context = new GenocsContext(options))
        {
            context.Database.EnsureCreated();

            var repository = new CustomerRepository(context);
            customer = await repository.Get(new Guid("197d0438-e04b-453d-b5de-eca05960c6ae"));

            Assert.NotNull(customer);
        }

        */
    }
}