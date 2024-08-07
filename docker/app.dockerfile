# build C# and release
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source
# run dotnet restore
COPY ["**.csproj", "./"]
RUN dotnet restore
# copy all files
COPY . .
# run dotnet build and publish
RUN dotnet build -c release --no-restore
RUN dotnet publish -c release -o ./publish --no-restore

FROM base as final
WORKDIR /app
COPY --from=build /source/publish .
# run web app
CMD ["dotnet", "BlazorTest.Web.dll"]
