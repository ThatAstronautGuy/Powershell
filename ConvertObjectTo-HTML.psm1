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
        [psobject[]]$object
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

        $table = "<table>`n"
        $table += "`t<thead>`n"
        $table += "`t`t<tr>`n"
        foreach($key in $keylist){
            $table += "`t`t`t<td>$key</td>`n"
        }
        $table += "`t`t</tr>`n"
        $table += "`t</thead>`n"

        $table += "`t<tbody>`n"
        $object | %{
            $table += "`t`t<tr>`n"
            foreach($key in $keylist){
                $table += "`t`t`t<td>$($_.$key)</td>`n"
            }
            $table += "`t`t</tr>`n"
        }
        $table += "`t</tbody>`n"
        $table += "</table>`n"

        return $table
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
        [string[]]$parameters
    )

    PROCESS {
        $table = "<table>`n"
        $table += "`t<thead>`n"
        $table += "`t`t<tr>`n"
        foreach($parameter in $parameters){
            $table += "`t`t`t<td>$parameter</td>`n"
        }
        $table += "`t`t</tr>`n"
        $table += "`t</thead>`n"

        $table += "`t<tbody>`n"
        $object | %{
            $table += "`t`t<tr>`n"
            foreach($parameter in $parameters){
                $table += "`t`t`t<td>$($_.$parameter)</td>`n"
            }
            $table += "`t`t</tr>`n"
        }
        $table += "`t</tbody>`n"
        $table += "</table>`n"

        return $table
    }
}
