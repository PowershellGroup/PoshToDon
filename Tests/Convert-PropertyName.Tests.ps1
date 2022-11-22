BeforeAll {
    Import-Module .\PoshToDon -Force
}

InModuleScope PoshToDon {
    Describe 'Convert-PropertyName' {
        It 'converts <Name> into <Output> using <Delimiter>-delimiter' -ForEach @(
            @{ Name = 'pe_ter'; Output = 'PeTer'; Delimiter = '_' }
            @{ Name = 'x+y'; Output = 'XY'; Delimiter = '+' }
            @{ Name = 'id_str'; Output = 'IdStr'; Delimiter = '_' }
        ) {
        
            Write-Host $Name $Output $Delimiter
            Convert-PropertyName -Name $Name -Delimiter $Delimiter | Should -Be $Output
        }
    }

    # It 'should handle existing parameters' {
    #     InModuleScope PoshToDon {
    #         $query = @{ entry = "test" } | AddData @{ other = "test2" } | ToQuery 
    #         $query | Should -BeLike "?*entry=test*"
    #         $query | Should -BeLike "?*other=test2*"
    #     }
    # }
}

