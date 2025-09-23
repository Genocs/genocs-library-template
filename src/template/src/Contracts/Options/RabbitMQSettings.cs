namespace Genocs.Library.Template.Contracts.Options;

public class RabbitMQSettings
{
    public const string Position = "RabbitMQ";

    public string HostName { get; set; } = "localhost";
    public string VirtualHost { get; set; } = "/";
    public string UserName { get; set; } = "guest";
    public string Password { get; set; } = "guest";
    public int Port { get; set; } = 5672;
    public bool UseSSL { get; set; }
}
