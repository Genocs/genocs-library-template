# Genocs.Library.Template service


## Introduction

This service is built with [genocs-webapi-template](https://github.com/Genocs/genocs-webapi-template) and is  following [Genocs Framework](https://genocs-blog.netlify.app/) pattern and practices.


## Motivation

> Learn how to design modular applications following microservice pattern.
>
> Explore the .NET Core features.

### Learn how to design modular applications

Learning how to design modular applications will help you become a better engineer. Designing modular applications is the holy grail of software architecture, it is hard to find engineers experienced in designing applications which allows adding new features in a steady speed. 

### Explore the .NET Core features

.NET Core brings a sweet development environment, an extensible and cross-platform framework. We will explore the benefits of it in the infrastructure layer and we will reduce its relevance in the application layer. The same rule is applied for modern C# language constructions.

### Learn from the open source community

This is continually updated, open source project.

[Contributions](#contributors-) are welcome!

## <span style="color:red; font-size:xxl">**Work in Progress**</span>


>Before start you have to update some values in the project.

This is because MongoDB does support database name with the character `.` (period), so you have to change it with another character like `_` (hyphen or undescore character). 

**FROM**
``` json
  "mongoDb": {
    "connectionString": "mongodb://localhost:27017",
    "database": "genocs.library.template-service",
    "seed": false
  },
```

**TO**

``` json
  "mongoDb": {
    "connectionString": "mongodb://localhost:27017",
    "database": "name_of_service-service",
    "seed": false
  },
```

## Containers and orchestrators

The example is ready to create the docker images for both WebApi and BusWorker

## Contributing

> Learn from the community.

Feel free to submit pull requests to help:

* Fix errors
* Improve sections
* Add new sections
* Submit questions and bugs

## Flow of Control

The flow of control begins in the controller, moves through the use case, and then winds up executing in the presenter.


## Test-Driven Development (TDD)

> You are not allowed to write any production code unless it is to make a failing unit test pass.
>
> You are not allowed to write any more of a unit test than is sufficient to fail; and compilation failures are failures.
>
> You are not allowed to write any more production code than is sufficient to pass the one failing unit test.

http://butunclebob.com/ArticleS.UncleBob.TheThreeRulesOfTdd

### Fakes

> Fake it till you make it

## SOLID

| Principle | Rule |
| --------- | ---- |
| Single Responsibility Principle | A class should have one, and only one, reason to change. |
| Open-Closed Principle | You should be able to extend a classes behavior, without modifying it. |
| Liskov Substitution Principle | Derived classes must be substitutable for their base classes. |
| Interface Segregation Principle | Make fine grained interfaces that are client specific. |
| Dependency Inversion Principle | Depend on abstractions, not on concretions. |


### Running the Tests Locally

Run the following command from the root folder:

``` sh
dotnet build
dotnet test
```

## Docker

The project will build two different images. One for the the WebApi endpoint and one for the Background Worker.   

To build and run the docker images, you can use the following script:

``` sh
./scripts/run-on-docker.sh
```

otherwise, you can run the following commands to build and run the docker images:

``` sh
docker build -t genocs/genocs.library.template.webapi -f ./src/WebApi/Dockerfile .
docker build -t genocs/genocs.library.template.worker -f ./src/Worker/Dockerfile .
```

## Kubernetes

The project contains the Kubernetes manifest to deploy the application in a Kubernetes cluster.

Update the values in the manifest files before deploying the application.

Following the list of the variables to update:

| Variable | Description 
| -------- | -------- | 
| **{{name}}**  | The name of the Kubernetes component  | 
| **{{acr_name}}** | The name of the Azure container registry | 
| **{{application_namespace}}** | The application namespace|
