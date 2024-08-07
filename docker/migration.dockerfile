# setup C# environment
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source
# restore dotnet tool
COPY ./.config/ ./.config/
RUN dotnet tool restore
# run dotnet restore
COPY ["./BlazorTest.Migrations/*.csproj", "./"]
RUN dotnet restore
# copy all migration files
COPY ./BlazorTest.Migrations/ .
# export sql
RUN dotnet ef migrations script -o ./migrations.sql --idempotent
# execute dotnet ef update
RUN dotnet ef migrations bundle --self-contained -r linux-x64

# execute efbundle container
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS runtime
WORKDIR /migration
COPY --from=build /source/appsettings.json .
COPY --from=build /source/migrations.sql .
COPY --from=build /source/efbundle .

CMD ["./efbundle"]
