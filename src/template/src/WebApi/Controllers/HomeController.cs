using Microsoft.AspNetCore.Mvc;

namespace Genocs.Library.Template.WebApi.Controllers;

[ApiController]
[Route("[controller]")]
public class HomeController() : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
    public IActionResult Get()
        => Ok("Welcome to Genocs.Library.Template");
}