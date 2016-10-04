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

