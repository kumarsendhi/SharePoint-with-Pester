function Write-SharePointStubFiles() {
 param
 (
 [parameter(Mandatory = $true)] [System.String] $SharePointStubPath
 )

 
 
 Add-PSSnapin Microsoft.SharePoint.PowerShell 
 
 $SPStubContent = ((Get-Command –PSSnapin "Microsoft.SharePoint.PowerShell" ) | ForEach-Object -Process {
 $signature = $null
 $command = $_
 $metadata = New-Object -TypeName System.Management.Automation.CommandMetaData -ArgumentList $command
 $definition = [System.Management.Automation.ProxyCommand]::Create($metadata) 
 foreach ($line in $definition -split "`n")
 {
 if ($line.Trim() -eq 'begin')
 {
 break
 }
 $signature += $line
 }
 "function $($command.Name) { `n $signature `n } `n"
 }) | Out-String
 
 foreach ($line in $SPStubContent.Split([Environment]::NewLine)) {
 $line = $line.Replace("[System.Nullable``1[[Microsoft.Office.Server.Search.Cmdlet.ContentSourceCrawlScheduleType, Microsoft.Office.Server.Search.PowerShell, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c]], mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]", "[object]")
 $line = $line.Replace("[System.Collections.Generic.List``1[[Microsoft.SharePoint.PowerShell.SPUserLicenseMapping, Microsoft.SharePoint.PowerShell, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c]], mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]", "[object]")
 $line = $line -replace "\[System.Nullable\[Microsoft.*]]", "[System.Nullable[object]]"
 $line = $line -replace "\[Microsoft.*.\]", "[object]"
 
 $line | Out-File $SharePointStubPath -Encoding utf8 -Append
 }
 }

Export-ModuleMember -Function Write-SharePointStubFiles

