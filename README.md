# Install New QuickAssist

## Download do QuickAssist:
1º Consultar o link pelo Windows App Store
https://apps.microsoft.com/store/detail/quick-assist/9P7BP5VNWKX5?hl=en-us&gl=US

2º Acessar site e colar link do QuickAssit da Windows App Store
https://store.rg-adguard.net/

3º Nos resultados clicar para fazer Download. 
http://tlu.dl.delivery.mp.microsoft.com/filestreamingservice/files/f2fee4d7-1b66-43c6-a2d8-351b89621521?P1=1659103510&P2=404&P3=2&P4=Xk9CUjvkmS6XEuny%2bKA2rjjGjOzSTlTWwR3pEZC4HTMQYltueS635XpxfyIda3HqkgFIDVGwDxT8KNDmEWVSUA%3d%3d

## Remove old QuickAssist:
Remove-WindowsCapability -Online -Name 'App.Support.QuickAssist~~~~0.0.1.0' -ErrorAction 'SilentlyContinue'

## Install new QuickAssist:
Add-AppxProvisionedPackage -online -SkipLicense -PackagePath '.\MicrosoftCorporationII.QuickAssist.AppxBundle'

## Ponto de atenção:
O novo QuickAssist utiliza Microsoft Edge WebView2, desta forma é necessário realizar a instalação, ou no primeiro acesso no quickassit a instalação é realizada automaticamente. Certifique que a comunicação com URLs estejam liberadas no firewall. 

Webview2 - https://developer.microsoft.com/en-us/microsoft-edge/webview2/

## Script powershell install new QuickAssist:
https://github.com/alexandrecoradi/QuickAssist/blob/main/ScriptInstallQuickAssist.ps1


