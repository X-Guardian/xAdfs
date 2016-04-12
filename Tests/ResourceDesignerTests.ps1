Write-Host "Testing xAdfsRelyingPartyTrust" -ForegroundColor Yellow
Test-xDscResource ..\DSCResources\MSFT_xAdfsRelyingPartyTrust -Verbose
Test-xDscSchema ..\DSCResources\MSFT_xAdfsRelyingPartyTrust\MSFT_xAdfsRelyingPartyTrust.schema.mof -Verbose

Write-Host "Testing xAdfsFarmNode" -ForegroundColor Yellow
Test-xDscResource ..\DSCResources\MSFT_xAdfsFarmNode -Verbose
Test-xDscSchema ..\DSCResources\MSFT_xAdfsFarmNode\MSFT_xAdfsFarmNode.schema.mof -Verbose

Write-Host "Testing xAdfsFarm" -ForegroundColor Yellow
Test-xDscResource ..\DSCResources\MSFT_xAdfsFarm -Verbose
Test-xDscSchema ..\DSCResources\MSFT_xAdfsFarm\MSFT_xAdfsFarm.schema.mof -Verbose