$defaulttagdata = new-object psobject
$defaulttagdata | add-member -MemberType NoteProperty -Name table -value "style='table-layout: fixed; border-collapse: collapse; box-shadow: 0 10px 6px -6px #777;'"
$defaulttagdata | add-member -MemberType NoteProperty -Name theadtr -Value "style='background: #A9A9A9;'"
$defaulttagdata | add-member -MemberType NoteProperty -Name tbodytr -Value "style='background: #D3D3D3;'"
$defaulttagdata | Add-Member -MemberType NoteProperty -name theadtd -value "style='border: 1px solid #000000;'"
$defaulttagdata | Add-Member -MemberType NoteProperty -name tbodytd -value "style='border: 1px solid #000000;'"

function ConvertObjectTo-HTMLTable {
    <#
        .SYNOPSIS
            Converts an object array to an HTML table
        .DESCRIPTION
            This function will convert an object array to an HTML table.
            Not every object in the array has to have the same properties.
            It will create the table with all unique properties passed, leaving empty ones blank.
        .PARAMETER object
            Any object
        .PARAMETER tagdata
            An object with extra data to be added to the HTML tags used, such as styling data.
            Accepted tags:
                - table   : styling for the entire table
                - thead   : styling for the thead
                - theadtr : styling for the tr in thead
                - theadtd : styling for the td's in thead
                - tbody   : styling for the tbody
                - tbodytr : styling for the tr's in tbody
                - tbodytd : styling for the td's in tbody
        .PARAMETER defaultstyle
            If set, the default styling will be used. Note that this will override any passed tagdata.
        .EXAMPLE
            ConvertObjectTo-HTMLTable -object $foobar

            <table>
	            <thead>
		            <tr>
			            <td>Foo</td>
			            <td>Bar</td>
		            </tr>
	            <tbody>
		            <tr>
			            <td>Foo1</td>
			            <td>Bar1</td>
		            </tr>
		            <tr>
			            <td>Foo2</td>
			            <td>Bar2</td>
		            </tr>
	            </tbody>
            </table>

            Description
            -----------
            Object foobar gets converted to table
        .NOTES
            FunctionName : ConvertObjectTo-HTMLTable
            Created by   : ThatAstronautGuy
            Date Coded   : 18/12/2018
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [psobject[]]$object,

        [ValidateNotNullorEmpty()]
        [psobject]$tagdata,

        [switch]$defaultstyle
    )

    PROCESS {
        $keylist = @()

        $object | %{
            foreach ($key in $_.PSObject.Properties) {
                if($keylist -notcontains $key.Name){
                    $keylist += $key.Name
                }
            }
        }

        if($defaultstyle){
            $tagdata = $defaulttagdata
        }

        return ObjectTo-Table -object $object -keys $keylist -tagdata $tagdata
    }
}

function ConvertObjectTo-HTMLTableOrdered {
    <#
        .SYNOPSIS
            Converts an object array to an HTML table
        .DESCRIPTION
            This function will convert an object array to an HTML table using the only the passed headings.
        .PARAMETER object
            Any object
        .PARAMETER parameters
            An array of the properties to be included in the table in the order you want
        .PARAMETER tagdata
            An object with extra data to be added to the HTML tags used, such as styling data.
            Accepted tags:
                - table   : styling for the entire table
                - thead   : styling for the thead
                - theadtr : styling for the tr in thead
                - theadtd : styling for the td's in thead
                - tbody   : styling for the tbody
                - tbodytr : styling for the tr's in tbody
                - tbodytd : styling for the td's in tbody
        .PARAMETER defaultstyle
            If set, the default styling will be used. Note that this will override any passed tagdata.
        .EXAMPLE
            ConvertObjectTo-HTMLTableOrdered -object $foobar -parameters $params

            <table>
	            <thead>
		            <tr>
			            <td>Foo</td>
			            <td>FooBar</td>
		            </tr>
	            <tbody>
		            <tr>
			            <td>Foo1</td>
			            <td></td>
		            </tr>
		            <tr>
			            <td></td>
			            <td>Foobar1</td>
		            </tr>
	            </tbody>
            </table>

            Description
            -----------
            Object foobar gets converted to table with the given properties
        .NOTES
            FunctionName : ConvertObjectTo-HTMLTableOrdered
            Created by   : ThatAstronautGuy
            Date Coded   : 18/12/2018
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [psobject[]]$object,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$parameters,

        [ValidateNotNullorEmpty()]
        [psobject]$tagdata,

        [switch]$defaultstyle
    )

    PROCESS {

        if($defaultstyle){
            $tagdata = $defaulttagdata
        }
        
        return ObjectTo-Table -object $object -keys $parameters -tagdata $tagdata
    }
}

function ObjectTo-Table {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [psobject[]]$object,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$keys,

        #[ValidateNotNullorEmpty()]
        [psobject]$tagdata
    )

    PROCESS {
        $table = "<table $($tagdata.table)>`n"
        $table += "`t<thead $($tagdata.thead)>`n"
        $table += "`t`t<tr $($tagdata.theadtr)>`n"
        foreach($parameter in $keys){
            $table += "`t`t`t<td $($tagdata.theadtd)>$parameter</td>`n"
        }
        $table += "`t`t</tr>`n"
        $table += "`t</thead>`n"

        $table += "`t<tbody $($tagdata.tbody)>`n"
        $object | %{
            $table += "`t`t<tr $($tagdata.tbodytr)>`n"
            foreach($parameter in $keys){
                $table += "`t`t`t<td $($tagdata.tbodytd)>$($_.$parameter)</td>`n"
            }
            $table += "`t`t</tr>`n"
        }
        $table += "`t</tbody>`n"
        $table += "</table>`n"

        return $table
    }
}

Export-ModuleMember -Function ConvertObjectTo-HTMLTable, ConvertObjectTo-HTMLTableOrdered
