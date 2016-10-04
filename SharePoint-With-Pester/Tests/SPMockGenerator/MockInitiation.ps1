function GenerateStub(){
    $RepoRoot = (Resolve-Path $PSScriptRoot\..).Path
    #$SPMockGenerator = (Join-Path $PSScriptRoot ".\SPMockGenerator\SPMockGenerator.psm1" -Resolve)
    $SPMockGenerator = (Join-Path $RepoRoot ".\SPMockGenerator\SPMockGenerator.psm1" -Resolve)
    Import-Module $SPMockGenerator -WarningAction SilentlyContinue
    $stubPath = $RepoRoot +'.\Stubs\Microsoft.SP.PowerShell.psm1'
    if(![System.IO.File]::Exists($stubPath)){
        Write-SharePointStubFiles $stubPath
    }
    else{
        Remove-Item $stubPath
        Write-SharePointStubFiles $stubPath
    }
    
}

GenerateStub 