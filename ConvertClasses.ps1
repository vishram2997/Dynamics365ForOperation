
$filePath=Convert-Path .
$xmlLine ="";
$ReservedTag = "FIELD","GROUP","INDICES","FULLTEXTINDICES","SOURCE";




Get-ChildItem $filePath -Filter *.xpo |  ForEach-Object {
 $classXML=$_.FullName.Substring(0,$_.FullName.Length-3)+"xml";
if((Test-Path $classXML) -eq (1-eq 0))
{
    

    $xmlLine="<?xml version=`"1.0`" encoding=`"utf-8`"?>";
    Set-Content -Path ($_.FullName.Substring(0,$_.FullName.Length-3)+"xml") -Value $xmlLine
    $count=0;
    $count=0;
    $LastPos=0;
    $LastTag ="";
    $currentTag = "";
    $currentPos = 0;
    $trimLine = "";
    foreach ($line in get-content $_.FullName) {
    $count++;

   if(($count -gt 9) -and ($line.Trim() -ne "") )
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
                if($ReservedTag -ccontains $currentTag )
                {
                    if($currentTag -eq "FIELD" -and $LastTag -eq "/PROPERTIES")
                    {

                        $xmlLine= "</"+ $currentTag +">";
                    }
                    else
                    {
                        if($currentTag -ne "FIELD")
                         {
                            if($currentTag -eq "SOURCE")
                            {
                                $xmlLine= "<Method><Name>"+$value[1]+"</Name>"+"<"+ $currentTag +">"+"<![CDATA[ ";
                            }
                            else
                            {
                       
                                $xmlLine= "<"+ $currentTag +">";
                            }
                         }
                         
                    }

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
                }

                
                 
                    if($LastTag -eq "FIELD")
                    {
                         $xmlLine= "<"+ $LastTag +" type=`"AxTableField"+$currentTag+"`"" +">";
                    }
                    else
                    {
                       if($currentTag -eq "/FIELDS")
                       {
                            $xmlLine= "</FIELD><"+ $currentTag +">";
                       }
                       ELSE
                       {
                            if($currentTag -ne "EnforceFKRelation" -and !$currentTag.StartsWith("*"))
                            {
                                
                                if($currentTag -eq "/SOURCE")
                                {
                                    $xmlLine= " ]]>"+"<"+ $currentTag +">"+"</Method>";
                                }
                                else
                                {
                                    $xmlLine= "<"+ $currentTag +">";

                                }
                            }
                       }
                    }
                

            }
         }
         else 
         {
 

             
                $xmlLine = $trimLine.Substring(1,$trimLine.Length-1);
             
         }

        if ($currentTag -ne "PROPERTIES" -and $currentTag -ne "/PROPERTIES")
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

 
 $count=0;
 [xml]$XmlDc = Get-Content -Path $classXML
 $xmlLine="<?xml version=`"1.0`" encoding=`"utf-8`"?>";
 
 
 
 Set-Content -Path ($classXML) -Value $xmlLine
 $xmlLine= "<AxClass xmlns:i=`"http://www.w3.org/2001/XMLSchema-instance`">";
 Add-Content -Path ($classXML) -Value $xmlLine

 $xmlLine="<Name>" +$XmlDc.CLASS.Name +"</Name>";

 Add-Content -Path ($classXML) -Value $xmlLine

 $xmlLine="<SourceCode><Declaration>";

 Add-Content -Path ($classXML) -Value $xmlLine

 $xmlLine=$XmlDc.CLASS.METHODS.Method[0].SOURCE.InnerXml;
 Add-Content -Path ($classXML) -Value $xmlLine
 $xmlLine="</Declaration><Methods>";
 Add-Content -Path ($classXML) -Value $xmlLine
 foreach($method in $XmlDc.CLASS.METHODS.Method)
 {
    $count++;
    if($count -ge 1 -and $XmlDc.CLASS.METHODS.Method[$count].Name)
    {
       $xmlLine="<Method><Name>"+$XmlDc.CLASS.METHODS.Method[$count].Name+"</Name><Source>"; 
       Add-Content -Path ($classXML) -Value $xmlLine

       $xmlLine=$XmlDc.CLASS.METHODS.Method[$count].SOURCE.InnerXml; 
       Add-Content -Path ($classXML) -Value $xmlLine
        $xmlLine="</Source></Method>"; 
       Add-Content -Path ($classXML) -Value $xmlLine
    }
 }

 $xmlLine="</Methods></SourceCode></AxClass>";

 Add-Content -Path ($classXML) -Value $xmlLine
}
}