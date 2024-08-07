# build C# and release
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source
# run dotnet restore
COPY ["**.sln", "./"]
COPY ["**.csproj", "./"]
RUN dotnet restore
# copy all files
COPY . .
# run dotnet build and publish
RUN dotnet build -c release --no-restore
RUN dotnet publish -c release -o ./publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 as final
WORKDIR /app
COPY --from=build /source/publish .
# run web app
CMD ["dotnet", "BlazorTest.Web.dll"]
