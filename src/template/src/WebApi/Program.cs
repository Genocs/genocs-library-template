using Genocs.Core.Builders;
using Genocs.Core.CQRS.Commands;
using Genocs.Core.CQRS.Events;
using Genocs.Core.CQRS.Queries;
using Genocs.Discovery.Consul;
using Genocs.HTTP;
using Genocs.Library.Template.WebApi;
using Genocs.Library.Template.WebApi.Infrastructure.Extensions;
using Genocs.LoadBalancing.Fabio;
using Genocs.Logging;
using Genocs.MessageBrokers.Outbox;
using Genocs.MessageBrokers.Outbox.MongoDB;
using Genocs.MessageBrokers.RabbitMQ;
using Genocs.Persistence.MongoDb.Extensions;
using Genocs.Persistence.Redis;
using Genocs.Secrets.Vault;
using Genocs.Tracing;
using Genocs.WebApi;
using Genocs.WebApi.Swagger;
using Genocs.WebApi.Swagger.Docs;
using Serilog;

StaticLogger.EnsureInitialized();

var builder = WebApplication.CreateBuilder(args);

builder.Host
        .UseLogging()
        .UseVault();

var gnxBuilder = builder.AddGenocs()
                        .AddOpenTelemetry();

gnxBuilder
        .AddErrorHandler<ExceptionToResponseMapper>()
        .AddServices()
        .AddHttpClient()
        .AddCorrelationContextLogging()
        .AddConsul()
        .AddFabio()
        .AddMongoWithRegistration()
        .AddCommandHandlers()
        .AddEventHandlers()
        .AddQueryHandlers()
        .AddInMemoryCommandDispatcher()
        .AddInMemoryEventDispatcher()
        .AddInMemoryQueryDispatcher()
        .AddRedis();

await gnxBuilder.AddRabbitMQAsync();

gnxBuilder.AddMessageOutbox(o => o.AddMongo())
        .AddWebApi()
        .AddWebApiSwaggerDocs()
        .Build();

var services = builder.Services;

// START: TO be Refactory

//services.AddCors();
//services.AddControllers().AddJsonOptions(x =>
//{
//    // serialize Enums as strings in api responses (e.g. Role)
//    x.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
//});

//services.Configure<HealthCheckPublisherOptions>(options =>
//{
//    options.Delay = TimeSpan.FromSeconds(2);
//    options.Predicate = check => check.Tags.Contains("ready");
//});

// Add Masstransit bus configuration
services.AddCustomMassTransit(builder.Configuration);

var app = builder.Build();

//.UseCertificateAuthentication()
//.UseEndpoints(r => r.MapControllers())
//.Get<GetOrder, OrderDto>("orders/{orderId}")
//.Post<CreateOrder>("orders",
//    afterDispatch: (cmd, ctx) => ctx.Response.Created($"orders/{cmd.OrderId}")))
//.UseRabbitMQ();
//    .SubscribeEvent<DeliveryStarted>();

// END: TO be Refactory

app.UseGenocs()
    .UserCorrelationContextLogging()
    .UseErrorHandler()
    .UseSwaggerDocs()
    .UseRouting();

app.UseHttpsRedirection();

// global cors policy
// app.UseCors(x => x
//     .SetIsOriginAllowed(origin => true)
//     .AllowAnyMethod()
//     .AllowAnyHeader()
//     .AllowCredentials());

app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

// Use it only if you need to authenticate with Firebase
// app.UseFirebaseAuthentication();

app.MapControllers();

app.MapDefaultEndpoints();

app.Run();

Log.CloseAndFlush();
