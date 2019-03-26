function Invoke-dotnetMethod {
    [CmdletBinding(DefaultParameterSetName = 'PositionalArguments')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [psobject[]]
        $InputObject,

        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $MethodName,

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'PositionalArguments')]
        [psobject[]]
        $ArgumentList,

        [Parameter(Mandatory = $false, ParameterSetName = 'NamedParameters')]
        [System.Collections.IDictionary]
        $Parameters
    )

    process {
        :outerLoop
        foreach($target in $InputObject){
            if($PSCmdlet.ParameterSetName -eq 'PositionalArguments'){
                $params = @{
                    MemberName = $MethodName
                }
                if($ArgumentList.Count -gt 0 ){
                    $params['ArgumentList'] = $ArgumentList
                }

                $target |ForEach-Object @params
                continue
            }

            $targetType = $target.GetType()
            $possibleMethods = $targetType.GetMethods() |Where-Object Name -eq $MethodName
            if($possibleMethods.Count -le 0){
                continue
            }

            foreach($possibleMethod in $possibleMethods){
                try {
                    $arguments = Get-ParameterNameMapping $possibleMethod -Parameters $Parameters
                    $possibleMethod.Invoke($target, $arguments)
                }
                catch [System.Management.Automation.MethodInvocationException]{
                    continue
                }
            }
        }
    }
}

function Get-ParameterNameMapping 
{
    param(
        [System.Reflection.MethodInfo]$Method,
        [System.Collections.IDictionary]$Parameters
    )

    $definedParameters = $Method.GetParameters()
    $flattenedParameters = [object[]]::new($definedParameters.Count)

    if($definedParameters.Count -ne $Parameters.Count){
        throw "parameter count is off"
    }

    for($i = 0; $i -lt $definedParameters.Count; $i++){
        $flattenedParameters[$i] = $Parameters[$definedParameters[$i].Name]
    }

    return $flattenedParameters
}