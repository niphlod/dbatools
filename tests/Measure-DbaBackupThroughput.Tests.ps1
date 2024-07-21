$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        [object[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object {$_ -notin ('whatif', 'confirm')}
        [object[]]$knownParameters = 'SqlInstance', 'SqlCredential', 'Database', 'ExcludeDatabase', 'Since', 'Last', 'Type', 'DeviceType', 'EnableException'
        $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
        It "Should only contain our specific parameters" {
            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object {$_}) -DifferenceObject $params).Count ) | Should Be 0
        }
    }
}

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    Context "Returns output for single database" {
        BeforeAll {
            $random = Get-Random
            $db = "dbatoolsci_measurethruput$random"
            $null = New-DbaDatabase -SqlInstance $script:instance2 -Database $db | Backup-DbaDatabase
        }
        AfterAll {
            $null = Remove-DbaDatabase -SqlInstance $script:instance2 -Database $db
        }

        $results = Measure-DbaBackupThroughput -SqlInstance $script:instance2 -Database $db
        It "Should return results" {
            $results.Database | Should -Be $db
            $results.BackupCount | Should -Be 1
        }
    }
}