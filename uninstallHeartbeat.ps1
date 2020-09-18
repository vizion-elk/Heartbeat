Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser	
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope LocalMachine
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

$ServiceName = "heartbeat"

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    #Change Directory to Heartbeat
    $currentLocation = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

    If ( -Not (Test-Path -Path "$currentLocation\heartbeat") )
    {
        Write-Host -Object "Path $currentLocation\heartbeat does not exit, exiting..." -ForegroundColor Red
        Exit 1
    }
    Else
    {
        Set-Location -Path "$currentLocation\heartbeat"
    }

    #Stops heartbeat from running
    Stop-Service -Force $ServiceName

    #Get The heartbeat Status
    Get-Service $ServiceName
    C:\Windows\System32\sc.exe delete $ServiceName

    #Change Directory to heartbeat5
    Set-Location -Path 'c:\'

    "`nUninstalling Heartbeat Now..."

    Get-ChildItem -Path $currentLocation -Recurse -force |
        Where-Object { -not ($_.pscontainer)} |
            Remove-Item -Force -Recurse

    Remove-Item -Recurse -Force $currentLocation

    "`nHeartbeat Uninstall Successful."

    #Close Powershell window
    #Stop-Process -Id $PID
}
else {
    Start-Process -FilePath "powershell" -ArgumentList "$('-File ""')$(Get-Location)$('\')$($MyInvocation.MyCommand.Name)$('""')" -Verb runAs
}