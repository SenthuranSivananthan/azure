FROM microsoft/aspnetcore

WORKDIR /app
COPY ./app/bin/Debug/netcoreapp2.0/publish .

ENV ASPNETCORE_URLS http://+:80
EXPOSE 80

ENTRYPOINT ["dotnet", "code.dll"]
