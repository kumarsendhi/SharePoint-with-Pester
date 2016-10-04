 [CmdletBinding()]
param(
    [string] $SharePointCmdletModule = (Join-Path $PSScriptRoot "..\Stubs\Microsoft.SP.PowerShell.psm1" -Resolve)
)

    $RepoRoot = (Resolve-Path $PSScriptRoot\..\..).Path
    $Global:CurrentSharePointStubModule = $SharePointCmdletModule
    
    Remove-Module -Name "Microsoft.SharePoint.PowerShell" -Force -ErrorAction SilentlyContinue
    Import-Module $Global:CurrentSharePointStubModule -WarningAction SilentlyContinue

#$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$here = $RepoRoot+'\Scripts'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "SP-WebApplication Unit Test" {
     $testParams =@{
        Name='SharePoint - 80'
        }
    Context "Web Application exist"{
          Mock Get-SPWebApplication {return (@{
            DisplayName= $testParams.Name
             ApplicationPool = @{ 
                    Name = "SharePoint - 80"
                    Username = "seyon\SPAdmin"
                }
                ContentDatabases = @(
                    @{
                        Name = "WSS_Content"
                        Server = "WIN-FHHAO4R7HVE"
                    }
                )
        })}
        It "WebApplication with Identity  exist"{
            $result = SPWebApp $testParams
            $result.DisplayName | Should Be 'SharePoint - 80'
        }
    }
    Context "Web Application doesn't exist"{
        Mock Get-SPWebApplication { return $null }
        It "WebApplication with Identity doesn't exist"{
            $result = SPWebApp $testParams
            $result | Should Be $null
        }
    }
}
