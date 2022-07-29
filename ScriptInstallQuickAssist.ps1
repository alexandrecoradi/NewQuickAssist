#===============================================
# Created on:   03/06/2022 15:00
# Created by:   Alexandre Coradi
# Update:       03/06/2022 15:00
# Ultima Modificação: N/A Update Script, inclusão update Edge and WebView
# Organization: 
#=============================================== 

$Error.Clear()
Function LogUpdate
{
    $DataAtual = (Get-Date).ToString("yyyy_MM_dd")
    $LogAtual = 'C:\TEMP\InfraVarejo\Logs\QuickAssist\' + $DataAtual + '.log'

    If (Test-Path $LogAtual)
    {
        $Global:ArquivoLog = $LogAtual
    }
    Else
    {
        # CRIANDO NOVO ARQUIVO DE LOG
        New-Item -Path $LogAtual -ItemType File -Force
        
        $Global:ArquivoLog = $LogAtual

        # REMOVENDO ARQUIVO DE LOG MAIOR QUE 15 DIAS
        $Del = (Get-Date).AddDays(-15)

        Get-ChildItem "C:\TEMP\InfraVarejo\Logs\QuickAssist\" -Include *.log -Recurse | % {
            $Arq = $_.CreationTime
            $ArqDel = $_.FullName

            If ($Arq -le $Del)
            {
                Remove-Item $ArqDel -Force -Recurse
            }
        }
    }
}
LogUpdate
Function AddLog
{
	Param ( $cLog )
    $rec_time = Get-Date -Format G
    Add-Content $Global:ArquivoLog -Value "$rec_Time | $cLog"
}


$InstallAppX = Get-AppxPackage -allusers MicrosoftCorporationII.QuickAssist

if (!($InstallAppX.version -eq "2.0.6.0"))
{
    AddLog "Instalacao New QuickAssist nao localizado, iniciando instalacao"
    If ($InstallAppX.status -eq 'OK'){
    #remover versão antiga.
    AddLog "Remove versao antiga"
    Remove-WindowsCapability -Online -Name 'App.Support.QuickAssist~~~~0.0.1.0' -ErrorAction 'SilentlyContinue'
    }

    If ($InstallAppX.status -ne 'OK'){
    AddLog "Instalando nova versao"
    Add-AppxProvisionedPackage -online -SkipLicense -PackagePath '.\MicrosoftCorporationII.QuickAssist.AppxBundle'
    Remove-WindowsCapability -Online -Name 'App.Support.QuickAssist~~~~0.0.1.0' -ErrorAction 'SilentlyContinue'
    }

    AddLog "Copiando arquivos menu iniciar"
    #Ajustando layout do MenuIniciar com novo icone.
    Copy-Item -Path "C:\Windows\InfraVarejo\StartMenu\Startmenu.xml" -Destination "C:\Windows\InfraVarejo\StartMenu\Startmenu.xml.old" -Force -ErrorAction SilentlyContinue
    if (Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SoftMaker FreeOffice 2021\TextMaker.lnk"){Copy-Item .\Startmenu_FreeOffice2021.xml -Destination "C:\Windows\InfraVarejo\StartMenu\Startmenu.xml" -Force -ErrorAction SilentlyContinue}
    if (Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SoftMaker FreeOffice 2018\TextMaker.lnk"){Copy-Item .\Startmenu_FreeOffice2018.xml -Destination "C:\Windows\InfraVarejo\StartMenu\Startmenu.xml" -Force -ErrorAction SilentlyContinue}else{Copy-Item .\Startmenu.xml -Destination "C:\Windows\InfraVarejo\StartMenu\Startmenu.xml" -Force -ErrorAction SilentlyContinue}
    AddLog "Criando atalho area de trabalho"
    #Criando atalho area de trabalho
    Copy-Item -Path ".\Assistência Rápida.lnk" -Destination "C:\Users\Public\Desktop\Assistência Rápida.lnk" -ErrorAction SilentlyContinue

}

#atualizando MicrosoftEdgeEnterprise
AddLog "Verificando versao de instalacao do MicrosoftEdgeEnterprise"

$productPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$productProperty = (Get-ItemProperty -Path $productPath).VersionInfo.ProductVersion 
if ($productProperty -lt "103.0.1264.37")
{
AddLog "Versao menor que 103.0.1264.37"
AddLog "Iniciando update do MicrosoftEdgeEnterprise"
Start-process .\MicrosoftEdgeEnterpriseX64.msi -ArgumentList "/quiet /norestart" -Wait

}

#Instalando MicrosoftEdgeWebView2
AddLog "Verificando instalacao do MicrosoftEdgeWebView2"

$InstalledSoftware = Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$resultado = ""
foreach($obj in $InstalledSoftware)
{
  $resultado += $obj.GetValue('DisplayName') 
}

if (!($resultado -like "*WebView2*"))
{

  AddLog "Instalacao do MicrosoftEdgeWebView2 nao localizado"
  AddLog "Iniciando instalacao do MicrosoftEdgeWebView2"

  $ExePath32 = Get-ChildItem -Path "$dirFiles" -Include MicrosoftEdgeWebView2RuntimeInstallerX64.exe -File -Recurse -ErrorAction SilentlyContinue
  Start-Process -FilePath "$ExePath32" -ArgumentList "/silent /install" -WindowStyle Hidden 

}
#verificar se folder foi criado, essa parte foi desativado
<#
$logon = Get-Process -Name LogonUI -ErrorAction SilentlyContinue
if ($logon -eq $null){}else
{
$user = quser | Select-String ">" 
$user = $user -replace (">","")
$user = $user.Substring(0,10)
$user = $user -replace (" ","")
$local = "C:\Users\$user\AppData\Local\Temp\QuickAssist"
}
#>

#finalizando arquivo de processo
Get-Process -Name QuickAssist -ErrorAction SilentlyContinue | Select-Object -Property Id | ForEach-Object -Process { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue}

AddLog "Iniciando processo do QuickAssist"
Start-Process "C:\Users\Public\Desktop\Assistência Rápida.lnk"
AddLog "Aguardando 10 segundos"
Start-Sleep -Seconds 30


for($i=0; $i -lt 20;)
{
    #Inicio do loop para verificar instacao do MicrosoftEdgeWebView2, se tiver algum problema com instalação do pacote, no momento de abrir a primeira vez o QuickAssit é feito o download e instalação automaticamente.
    AddLog "Inicio do loop para verificar instacao do MicrosoftEdgeWebView2"

    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $resultado = ""
    foreach($obj in $InstalledSoftware)
    {
    $resultado += $obj.GetValue('DisplayName') 
    }
    if (!($resultado -like "*WebView2*"))
    {
    AddLog "Salto $i"
    AddLog "Instalacao nao localizada aguardar 60 segundos"
    
    Start-Sleep -Seconds 60
    }
    else
    {

    AddLog "Instalacao do MicrosoftEdgeWebView2 localizado"
    AddLog "Finalizando processo do QuickAssist"
    Get-Process -Name QuickAssist -ErrorAction SilentlyContinue | Select-Object -Property Id | ForEach-Object -Process { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue}
    $i = 20
    }


    $i++
}

AddLog "Finalizando processo do QuickAssist"
Get-Process -Name QuickAssist -ErrorAction SilentlyContinue | Select-Object -Property Id | ForEach-Object -Process { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue}
AddLog "Fim"


