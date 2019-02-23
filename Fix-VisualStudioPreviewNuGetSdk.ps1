$PathToFile = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\Common7\IDE\CommonExtensions\Microsoft\NuGet\Newtonsoft.Json.dll"

$SourceUrl = "https://raw.githubusercontent.com/onovotny/UpdateVsOnAgent/master/Newtonsoft.Json.9/Newtonsoft.Json.dll"

Invoke-WebRequest -Uri $SourceUrl -OutFile $PathToFile