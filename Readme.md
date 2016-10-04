# SharePoint PowerShell Unit Testing with Pester

[Pester][] is a **BDD** based test runner for PowerShell.

[Pester][] provides a framework for running Unit Tests to execute and validate PowerShell commands.

This project tries to explain how [Pester][] framework can be used for Unit testing SharePoint PowerShell commands.

This Project will try to solve the following problems pertaining to SharePoint PowerShell Unit Testing:

1. The SharePoint Installed server is a mandatory requirement for SharePoint Unit Testing. 
2. Testing multiple versions of SharePoint with commands getting modified or new commands being added.

Let's understand what is done to solve the above problems and get seamless unit testing done on SharePoint.

1. Setting up the Pester in our Environment.
   * Goto [PowerShell Gallery][]. Click on Get PowerShellGet for PS 3 & 4.
        ![Powershell Gallery][PowerShellGallerySS]
   * Download the Package Management and Install the same.
   * Open Windows PowerShell
   * Execute the **Find-Module Pester** and **Install-Module Pester** as shown.
        ![Install Pester][InstallPester]

2. Setting up the Project to include Unit Testing.
   * Created a Project Structure as shown in the image below which solved this particular requirement.
        ![Folder Structure][dirStructure]

   * Mock the entire cmdlet of SharePoint. Used this [blog][] as reference.
     * This should be done in **SharePoint server**
     * Double Click the **MockGenerator.bat** file which is located in **SharePoint-With-Pester\Tests** folder.
     * It will generate the SharePoint Cmdlet mocks in **SharePoint-With-Pester\Tests\Stubs** folder.

2. Begin Unit Testing with [Pester][]. We will explore multiple scenario's in this sample
   * Scenario 1: Unit Testing to check **SharePoint WebApplication** with a particular name exists
     * Create a file in **SharePoint-With-Pester\Tests\UnitTest** folder, named **SPWebApp.Tests.ps1**. 
     * Paste the following code in the file.
      ```

      [CmdletBinding()]
      param(
      [string] $SharePointCmdletModule = (Join-Path $PSScriptRoot "..\Stubs\Microsoft.SP.PowerShell.psm1" -Resolve)
      )
      $RepoRoot = (Resolve-Path $PSScriptRoot\..\..).Path
      $Global:CurrentSharePointStubModule = $SharePointCmdletModule
    
      Remove-Module -Name "Microsoft.SharePoint.PowerShell" -Force -ErrorAction SilentlyContinue
      Import-Module $Global:CurrentSharePointStubModule -WarningAction SilentlyContinue

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

      ```
     * Create a file in **SharePoint-With-Pester\Scripts** folder, named **SPWebApp.ps1**.
     * Production code (*SPWebApp.ps1*) and test code (*SPWebApp.**Tests**.ps1*) file names should be similar except **Tests** which is highlighted for Pester to work seamlessly
     * Paste the following code in SPWebApp.ps1.
     ```
      function SPWebApp{
        $params = $args[0]

        $webApplication = Get-SPWebApplication -Identity $params.Name
        return $webApplication 
      }

      $testParams =@{
        Name='SharePoint - 80'
      }

      SPWebApp $testParams

     ```

     * In production code **SPWebApp** is the function for which we have written the unit testing code.
     * In the above scenario we have written a script block containing the desired output.




   * Scenario 2: Unit Testing to check List Count in a particular SharePoint Web and check List Name **My Task** exists.
     * Create a file in **SharePoint-With-Pester\Tests\UnitTest** folder, named **SPList.Tests.ps1**. 
     * Paste the following code in the file.
     ```
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
          )
        } -Verifiable

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

     ```
     * Create a file in **SharePoint-With-Pester\Scripts** folder, named **SPList.ps1**.
     * Production code (*SPList.ps1*) and test code (*SPList.**Tests**.ps1*) file names should be similar except **Tests** which is highlighted for Pester to work seamlessly
     * Paste the following code in SPList.ps1.
     ```
      function SPWeb(){
        $inputParameter = $args[0];
        $web= Get-SPWeb -Identity $inputParameter.url -ErrorAction SilentlyContinue
        return $web
      }

      function GetSPList(){  
        $inputParameter = $args[0];
        $web = SPWeb $inputParameter;
        $list = $web.lists | Where { $_.Title -eq $inputParameter.Title}
        return $list
      }

      function SPList() {
        $inputParameter = $args[0];
        if($inputParameter -ne $null){
        $list=GetSPList $inputParameter
        Write-Host $list.Title
        }
      } 

      $testParams =@{
        url = "http://win-fhhao4r7hve/sites/TS"
        Title = "My Task"
      }

      SPList $testParams

     ```
     * In the above scenario we have written a mock script block containing the code which will import xml file containing the real time objects of SharePoint Web.
     * The Value of SharePoint Web was exported to **SharePoint-With-Pester\Tests\MockData**. The process of exporting the objects of SharePoint Web is as follows.
        *  This should be done in SharePoint server
        *  Paste the following code to get the entire SharePoint Web object pertaining to the url exported to xml.
        ```
        $web= Get-SPWeb -Identity "http://win-fhhao4r7hve/sites/TS" -ErrorAction SilentlyContinue
        $web | Export-Clixml -Path ..\..\..\SPList-Mock.xml

        ``` 
        * Similarly we can get any object of SharePoint exported to the **SharePoint-With-Pester\Tests\MockData** folder. 
        * This will help in having our Unit Testing of SharePoint done in environment where no SharePoint is installed also with real time data.


Thank you...


[Pester]: https://github.com/pester/Pester/wiki
[blog]: https://blogs.msdn.microsoft.com/brian_farnhill/2015/09/27/better-approaches-to-unit-testing-powershell-scripts-that-call-sharepoint-cmdlets/
[PowerShell Gallery]: http://www.powershellgallery.com/
[dirStructure]:https://github.com/kumarsendhi/GitImages/blob/master/SP%20with%20Pester%20Folder%20Structure.png?raw=true
[PowerShellGallerySS]: https://github.com/kumarsendhi/GitImages/blob/master/Powershellgallery.png?raw=true
[InstallPester]: https://github.com/kumarsendhi/GitImages/blob/master/InstallPester.png?raw=true