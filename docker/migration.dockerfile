# setup C# environment
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source
# restore dotnet tool
COPY ./.config/ ./.config/
RUN dotnet tool restore
# copy all files
COPY . .
# run dotnet restore
RUN dotnet restore
# run dotnet build
RUN dotnet build -c release --no-restore
# ... use cached
# ---------------------
# current directory changed to BlazorTest.Migrations
WORKDIR /source/BlazorTest.Migrations
# export sql
RUN dotnet ef migrations script -o ./migrations.sql --idempotent
# execute dotnet ef update
RUN dotnet ef migrations bundle --self-contained -r linux-x64 -o ./efbundle

# execute efbundle container
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS runtime
WORKDIR /migration
#COPY --from=build /source/BlazorTest.Migrations/appsettings.json .
COPY --from=build /source/BlazorTest.Migrations/migrations.sql .
COPY --from=build /source/BlazorTest.Migrations/efbundle .

CMD ["./efbundle"]
