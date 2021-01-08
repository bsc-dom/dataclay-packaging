#/bin/sh

# Add dependencies for disabling invariant mode (set in base image)
apk add --no-cache icu-libs

# Install .NET Core SDK
dotnet_sdk_version=3.1.404
wget -O dotnet.tar.gz https://download.visualstudio.microsoft.com/download/pr/d7b82e76-1d88-4873-817b-2c3f02c93138/92137dd72c4a1ae2e758edbe95756068/dotnet-sdk-3.1.404-linux-musl-x64.tar.gz
#wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-musl-x64.tar.gz
mkdir -p "$HOME/dotnet" && tar zxf dotnet.tar.gz -C "$HOME/dotnet"
ln -s $HOME/dotnet/dotnet /usr/local/bin/dotnet
