namespace Genocs.Library.Template.Contracts.ReadModels;

public class Product(string sKU, int count, decimal price)
{
    public string SKU { get; private set; } = sKU;
    public int Count { get; private set; } = count;
    public decimal Price { get; private set; } = price;
}