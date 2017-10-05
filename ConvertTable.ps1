
$filePath=Convert-Path .
$xmlLine ="";
$ReservedTag = "FIELD","GROUP","INDICES","FULLTEXTINDICES","SOURCE","REFERENCE","EVENTHANDLER","EVENTS";
$xmlLine="<?xml version=`"1.0`" encoding=`"utf-8`"?>";

Get-ChildItem $filePath -Filter *.xpo |  
ForEach-Object {
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
                                $xmlLine= "<Method><Name>"+$value[1]+"</Name>"+"<Source>"+"<![CDATA[ ";
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
                         $xmlLine= "<"+ $LastTag +" type=`""+$currentTag+"`"" +">";
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
                                    $xmlLine= " ]]>"+"</Source>"+"</Method>";
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

        if ($currentTag -ne "REFERENCETYPE")
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

# <#
 
 $classXML=$_.FullName.Substring(0,$_.FullName.Length-3)+"xml";

[xml]$XmlDc = Get-Content -Path ($_.FullName.Substring(0,$_.FullName.Length-3)+"xml")
$xmlLine="";
$xmlLine+="<?xml version=`"1.0`" encoding=`"utf-8`"?>";
 
#Set-Content -Path ($classXML) -Value $xmlLine
$xmlLine+= "`n<AxTable xmlns:i=`"http://www.w3.org/2001/XMLSchema-instance`">";
#Add-Content -Path ($classXML) -Value $xmlLine
$xmlLine += "`n<Name>"+$Xmldc.TABLE.PROPERTIES.Name +"</Name>";

$xmlLine += "`n<SourceCode><Declaration><![CDATA[";
$xmlLine +=  "`npublic class "+$XmlDc.TABLE.PROPERTIES.Name +" extends common";
$xmlLine +=  "`n{";
$xmlLine +=  "`n}";
$xmlLine +=  "`n]]></Declaration><Methods>";

$xmlLine += $Xmldc.TABLE.METHODS.InnerXml
$xmlLine += "`n</Methods></SourceCode>"


foreach ($node in $Xmldc.TABLE.PROPERTIES.ChildNodes)
{
    
    if($node.ChildNodes.Count -eq 1)
    {
        $xmlLine+= "`n<"+$node.Name+">"+ $node.InnerXml+"</"+$node.Name+">";
    }

    
}

$xmlLine += "`n<DeleteActions>"

foreach ($node in $Xmldc.TABLE.DELETEACTIONS.PROPERTIES)
{
    
    $xmlLine+= "`n<AxTableDeleteAction><Name>"+$node.FirstChild.InnerText+"</Name>"
    foreach($childNode in $node.ChildNodes)
    {
           $xmlLine+= "`n<"+$childNode.Name+">"+ $childNode.InnerXml+"</"+$childNode.Name+">"; 
        
    }    

    $xmlLine+= "`n</AxTableDeleteAction>"
}

$xmlLine += "`n</DeleteActions>"
$xmlLine += "`n<FieldGroups>"

foreach ($node in $Xmldc.TABLE.GROUPS.ChildNodes)
{
    $count =0;
    $xmlLine+= "`n<AxTableFieldGroup><Name>"+$node.FirstChild.Name+"</Name><Fields>"
    $fieldsList= $node.GROUPFIELDs.Split("`n")

    foreach($field in $fieldsList)
    {
       if($field -ne "")
       {
           $xmlLine+= "`n<AxTableFieldGroupField><DataField>"+ $field+"</DataField></AxTableFieldGroupField>"; 
        }
    }    

    $xmlLine+= "`n</Fields></AxTableFieldGroup>"
}

$xmlLine += "`n</FieldGroups>"


$xmlLine += "`n<Fields>"

foreach ($node in $Xmldc.TABLE.FIELDS.FIELD)
{
    $count =0;

    if($node.GetAttribute("type") -eq "DATETIME")
    {
     $xmlLine+= "`n<AxTableField xmlns=`"`" i:type=`"AxTableFieldUtcDateTime`">"
    }
    else
    {

    $xmlLine+= "`n<AxTableField xmlns=`"`" i:type=`"AxTableField"+(Get-Culture).textinfo.ToTitleCase($node.GetAttribute("type").ToLower())+ "`">"
    }

    foreach($childNode in $node.ChildNodes)
    {
       
            $xmlLine+= $childNode.InnerXml;        
    }    

    $xmlLine+= "`n</AxTableField>"
}

$xmlLine += "`n</Fields>"

$xmlLine += "`n<Indexes>"

$count =0;
foreach ($node in $Xmldc.TABLE.INDICES.PROPERTIES)
{
 $count++;   
    $xmlLine+= "`n<AxTableIndex>"
    $xmlLine += $node.InnerXML; 
    $xmlLine+= "`n<Fields>"
    if($Xmldc.TABLE.INDICES.INDEXFIELDS[$count].contains("`n"))
    {
        $fieldsList= $Xmldc.TABLE.INDICES.INDEXFIELDS[$count].Split("`n");
    }
    else
    {
        $fieldsList= $Xmldc.TABLE.INDICES.INDEXFIELDS[$count]
    }

    foreach($field in $fieldsList)
    {
       if($field -ne "")
       {
           $xmlLine+= "`n<AxTableIndexField><DataField>"+ $field+"</DataField></AxTableIndexField>"; 
        }
    }    

    $xmlLine+= "`n</Fields></AxTableIndex>"   

    
}


$xmlLine += "`n</Indexes>"
$xmlLine += "`n<Relations>"

$count =0;
foreach ($node in $Xmldc.TABLE.REFERENCES.REFERENCE.PROPERTIES)
{
 $count++;   
    $xmlLine+= "`n<AxTableRelation>"
    

    #$xmlLine += $node.InnerXML; 
    foreach($relationProp in $node.ChildNodes)
    {
        if($relationProp.Name -eq "Table")
        {
            $xmlLine +=  "`n<Related"+$relationProp.Name+">"+$relationProp.'#text' +"</Related"+$relationProp.Name+">"
        }
        else
        {
            $xmlLine +=  "`n<"+$relationProp.Name+">"+$relationProp.'#text' +"</"+$relationProp.Name+">"
        }
    }
   
   $xmlLine+= "`n<Constraints><AxTableRelationConstraint xmlns=`"`" i:type=`"AxTableRelationConstraintField`">"; 

    foreach($field in $Xmldc.TABLE.REFERENCES.REFERENCE.FIELDREFERENCES.PROPERTIES)
    {
           
           $name=$field.Field;
           $xmlLine+="`<Name>"+$name+"</Name>";   
                
            
           
           $xmlLine+=$field.innerXML
           
        
    }
     
    $xmlLine+= "`n</AxTableRelationConstraint></Constraints>"; 


    $xmlLine+= "`n</AxTableRelation>"   

    
}


$xmlLine += "`n</Relations></AxTable>"



Set-Content -Path $classXML -Value $xmlLine
#$xmlLine



}
}