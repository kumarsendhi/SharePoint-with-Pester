[CmdletBinding()]
param(
    [string] $SharePointCmdletModule = (Join-Path $PSScriptRoot "..\Stubs\Microsoft.SP.PowerShell.psm1" -Resolve)
)

$RepoRoot = (Resolve-Path $PSScriptRoot\..\..).Path
$Global:CurrentSharePointStubModule = $SharePointCmdletModule
$Global:CurrentSharePointStubLoadedModule = "Microsoft.SP.PowerShell"

Remove-Module -Name "Microsoft.SharePoint.PowerShell" -Force -ErrorAction SilentlyContinue
Import-Module $Global:CurrentSharePointStubModule -WarningAction SilentlyContinue

$here = $RepoRoot+'\Scripts'
$fileName =(Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"



Describe "SPList unit test" {
    $testParams =@{
            url = "http://win-fhhao4r7hve/sites/TS"
            Title = "My Task"
        }
    Mock Get-SPWeb {    
        $MockPath = $RepoRoot+'\Tests\MockData\'+$fileName+'-Mock.xml'
        $data = Get-Content $MockPath
        return (
            $rssData= [System.Management.Automation.PSSerializer]::DeserializeAsList($data)
        )} -Verifiable

    Context 'SPWeb Unit Test'{      
        It "SPWeb Exists" {
        (SPWeb $testParams).Title | Should Be "TeamSite"   
        }
    }

    Context 'List Count Verification'{
        It "SPWeb Exists" {
        (SPWeb $testParams).Lists.Count | Should Be 21   
        }
    }


     Context 'SPList Unit Test'{    
       It "SPList Exists" {
        (GetSPList $testParams).Title | Should Be "My Task"
        Assert-MockCalled Get-SPWeb -Exactly 1
        Assert-VerifiableMocks
    }  
    }   
}


 