function SPWebApp{
    $params = $args[0]

    $webApplication = Get-SPWebApplication -Identity $params.Name
    return $webApplication
   
}

$testParams =@{
    Name='SharePoint - 80'
}

SPWebApp $testParams
