



$filePath=Convert-Path .
$xmlLine ="";
$ReservedTag = "FIELD","GROUP","INDICES","FULLTEXTINDICES","SOURCE";







Get-ChildItem $filePath -Filter *.xpo |  
ForEach-Object {
$classXML=$_.FullName.Substring(0,$_.FullName.Length-3)+"xml";
if((Test-Path $classXML) -eq (1-eq 0))
{
$xmlLine="<?xml version=`"1.0`" encoding=`"utf-8`"?>";
Set-Content -Path ($_.FullName.Substring(0,$_.FullName.Length-3)+"xml") -Value $xmlLine
$xmlLine="<AxEnum xmlns:i=`"http://www.w3.org/2001/XMLSchema-instance`">";
Add-Content -Path ($_.FullName.Substring(0,$_.FullName.Length-3)+"xml") -Value $xmlLine
$count=0;
$count=0;
$LastPos=0;
$LastTag ="";
$currentTag = "";
$currentPos = 0;
$trimLine = "";
foreach ($line in get-content $_.FullName) {
$count++;

   if(($count -gt 10) -and ($line.Trim() -ne "") )
   {  
        $trimLine = $line.TrimStart();
        $currentPos = ($line.Length-$trimLine.Length)/2;
        if(!$trimLine.StartsWith("#"))
        {
            if ($trimLine.IndexOf(" ",1) -ge 0)
            {
                $currentTag = $trimLine.Substring(0,$trimLine.IndexOf(" ",1))
            }
            else
            {
                $currentTag = $trimLine;
            }
                $sperator = "#";
            $value = $trimLine.Replace(" ","").Split($sperator,[System.StringSplitOptions]::RemoveEmptyEntries);
            if ($value[1].Length -ge 1 -and $currentPos -gt 1)
            {
                        if($currentTag -eq "TYPEELEMENTS")
                        {
                            $currentTag = "EnumValues";
                        }
                         if($currentTag -eq "EnumValue")
                       {
                        $xmlLine= "<Value>" + $value[1]+"</Value>" +"</AxEnumValue>";
                       }
                       else
                       {    
                    
                              $xmlLine= "<"+ $currentTag +">" + $value[1]+"</"+ $currentTag +">";
                              }
         
            }
            else
            {
                if($currentTag.StartsWith("END"))
                {
                    $currentTag = $currentTag.Replace("END","/");
                    if($currentTag -eq "/TYPEELEMENTS")
                        {
                            $currentTag = "/EnumValues";
                        }
                         if($currentTag -eq "/ENUMTYPE")
                        {
                            $currentTag = "/AxEnum";
                        }

                    $xmlLine= "<"+ $currentTag +">";
                }
                else
                {
                       if($currentTag -eq "TYPEELEMENTS")
                        {
                            $currentTag = "EnumValues";
                        }
                     
                        
                                    $xmlLine= "<"+ $currentTag +">";
                        
                }
            }
         }
         else 
         {
 

                $xmlLine ="<AxEnumValue>"
               # $xmlLine = $trimLine.Substring(1,$trimLine.Length-1);
             
         }

       if ($currentTag -ne "PROPERTIES" -and $currentTag -ne "/PROPERTIES" -and !$currentTag.StartsWith("*"))
        {
            Add-Content -Path ($_.FullName.Substring(0,$_.FullName.Length-3)+"xml") -Value $xmlLine;
        }
        
        if($currentTag -ne "")
        {
            $LastTag =$currentTag;
        }
        if($currentPos -ne 0)
        {
           $LastPos = $currentPos;
        }
        $currentTag = "";
        $currentPos =0;
        $xmlLine="";
        
   }
 }
}
}