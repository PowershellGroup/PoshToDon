BeforeAll {
    Import-Module .\PoshToDon -Force
}

# function ConvertTo-QueryParameters {
#     [Internal()]
#     param(
#         [Parameter(ValueFromPipeline)]
#         [hashtable] $Data,

#         [System.Collections.Generic.List[string]] $QueryParameters = [System.Collections.Generic.List[string]]::new()
#     )

Describe 'ConvertTo-QueryParameters' {
    It 'should handle normal entries' {
        InModuleScope PoshToDon {
            @{ entry = "test" } | ToQuery | Should -Be "?entry=test"
        }
    }
    It 'should handle array entries' {
        InModuleScope PoshToDon {
            @{ entry = @( 1, 2 ) } | ToQuery | Should -Be "?entry[]=1&entry[]=2"
        }
    }
    It 'should handle existing parameters' {
        InModuleScope PoshToDon {
            $query = @{ entry = "test" } | AddData @{ other = "test2" } | ToQuery 
            $query | Should -BeLike "?*entry=test*"
            $query | Should -BeLike "?*other=test2*"
        }
    }
}

