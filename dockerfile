# --------------------
# build C# and release
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source
# restore dotnet tool
COPY ./.config/ ./.config/
RUN dotnet tool restore
# skip husky install
ENV HUSKY=0
# copy csproj and restore as distinct layers
COPY *.sln .
COPY BlazorTest.Core/*.csproj       ./BlazorTest.Core/
COPY BlazorTest.Migrations/*.csproj ./BlazorTest.Migrations/
COPY BlazorTest.Tests/*.csproj      ./BlazorTest.Tests/
COPY BlazorTest.Web/*.csproj        ./BlazorTest.Web/
# run dotnet restore
RUN dotnet restore
# copy all files
COPY . .
# run dotnet build and publish
RUN dotnet build -c release --no-restore
RUN dotnet publish -c release -o ./publish -r linux-x64 BlazorTest.Web

# --------------------
# generate migrations
FROM build AS migrations
WORKDIR /source
# copy files for migrations
COPY --from=build . .
WORKDIR /source/BlazorTest.Migrations
# export sql
RUN dotnet ef migrations script -o ./migrations.sql --idempotent
# generate efbundle
RUN dotnet ef migrations bundle --idempotent --self-contained -r linux-x64 -o ./efbundle

# --------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /source/publish .
COPY --from=migrations /source/BlazorTest.Migrations/migrations.sql .
COPY --from=migrations /source/BlazorTest.Migrations/efbundle .

# run web app
EXPOSE 8080
CMD ["./web"]
