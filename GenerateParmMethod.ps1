
$tables = import-csv ("C:\Vishram\VW\shipping.csv")
ForEach ($line in $tables){
    $line.type +"  " + $line.var +";"
}

$tables = import-csv ("C:\Vishram\VW\shipping.csv")
ForEach ($line in $tables){
    
    getParmMethod -type $line.type -var $line.var

}



Function getParmMethod
{
    Param ([string]$type,[string]$var)
    $TextInfo = (Get-Culture).TextInfo

    $method = "[DataMemberAttribute('"+$var+"')]`n"
    $method += "public "+$type+" parm"+$var.Substring(0,1).ToUpper()+$var.Substring(1,$var.Length-1)+"("+$type+" _"+$var+" = "+$var+")`n"
    $method += "{`n"
    $method += "        "+$var+" = _"+$var+";`n"
    $method += "        return "+$var+";`n"
    $method += "}`n"

Return $method 
}

$var = "fontName"
$type ="str"
#getParmMethod -type $type -var $var