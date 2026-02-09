# --- CONFIGURATION (Edit these in your local copy) ---
$InternetTarget = "8.8.8.8"
$LocalGateway   = "192.168.x.x" 
$UPSTarget      = "192.168.x.x"
$PhoneSystem    = "192.168.x.x"

# --- FOLDER SETUP ---
$LogFolder = "$env:USERPROFILE\Desktop\Infrastructure_Logs"
$ArchiveFolder = "$LogFolder\Archive"
if (!(Test-Path $LogFolder)) { New-Item -ItemType Directory -Path $LogFolder }
if (!(Test-Path $ArchiveFolder)) { New-Item -ItemType Directory -Path $ArchiveFolder }

# Helper function for logging
function Write-Log {
    param([string]$FileName, [scriptblock]$Content)
    $FilePath = "$LogFolder\$FileName.txt"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Header = "`r`n" + ("-" * 50) + "`r`n[LOG ENTRY: $Timestamp]`r`n" + ("-" * 50)
    
    $Output = & $Content
    $Header + $Output | Out-File -FilePath $FilePath -Append
    $Output 
}

# --- MAIN MENU LOOP ---
do {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Yellow
    Write-Host "   INFRASTRUCTURE MAINTENANCE TOOL v3.0"       -ForegroundColor Yellow
    Write-Host "   Status: Connected to Subnet 192.168.100.x"  -ForegroundColor Gray
    Write-Host "==============================================" -ForegroundColor Yellow
    Write-Host "1. FULL SCAN (All Tasks)"
    Write-Host "2. LAN/Internet & WiFi Check"
    Write-Host "3. Server & Hardware Health"
    Write-Host "4. UPS/Inverter Status"
    Write-Host "5. Telephone Lines Check"
    Write-Host "6. ARCHIVE OLD LOGS (>30 Days)"
    Write-Host "Q. Exit Program"
    Write-Host "==============================================" -ForegroundColor Yellow
    
    $choice = Read-Host "`nSelect an option"

    switch ($choice) {
        "1" {
            Write-Log "Full_Scan" {
                "--- FULL SYSTEM SCAN ---"
                "Internet: $(if(Test-Connection $InternetTarget -Count 1 -Quiet){'UP'}else{'DOWN'})"
                "CPU Load: $(Get-CimInstance Win32_Processor | Select-Object -ExpandProperty LoadPercentage)%"
                "Drive Health: $((Get-PhysicalDisk | Select-Object -ExpandProperty HealthStatus))"
                "UPS: $(if((Test-NetConnection $UPSTarget -Port 80 -WarningAction SilentlyContinue).TcpTestSucceeded){'REACHABLE'}else{'OFFLINE'})"
                "Phones: $(if((Test-NetConnection $PhoneSystem -Port 5060 -WarningAction SilentlyContinue).TcpTestSucceeded){'ACTIVE'}else{'OFFLINE'})"
            }
        }
        "2" {
            Write-Log "Connectivity_Check" {
                $WiFi = (netsh wlan show interfaces | Select-String "^\s+SSID") -replace '^\s+SSID\s+:\s+', ''
                "Internet Connection: $(if(Test-Connection $InternetTarget -Count 1 -Quiet){'ONLINE'}else{'DOWN'})"
                "Gateway (Router):    $(if(Test-Connection $LocalGateway -Count 1 -Quiet){'REACHABLE'}else{'UNREACHABLE'})"
                "Current WiFi SSID:   $WiFi"
            }
        }
        "3" {
            Write-Log "Server_Health" {
                $CPU = Get-CimInstance Win32_Processor | Select-Object -ExpandProperty LoadPercentage
                $RAM = Get-CimInstance Win32_OperatingSystem
                $FreeRAM = [math]::Round($RAM.FreePhysicalMemory / 1MB, 2)
                $Drive = Get-PhysicalDisk | Select-Object HealthStatus
                "CPU Usage:    $CPU %"
                "Free RAM:     $FreeRAM GB"
                "Physical Disk: $($Drive.HealthStatus)"
            }
        }
        "4" {
            Write-Log "UPS_Status" {
                $UPS = Test-NetConnection $UPSTarget -Port 80 -WarningAction SilentlyContinue
                "Checking UPS Web Interface (Port 80)..."
                "Result: $(if($UPS.TcpTestSucceeded){'SUCCESS - Management Card Active'}else{'FAILURE - Check Network/Power'})"
            }
        }
        "5" {
            Write-Log "Phone_Status" {
                $Phone = Test-NetConnection $PhoneSystem -Port 5060 -WarningAction SilentlyContinue
                "Checking SIP Protocol (Port 5060)..."
                "Result: $(if($Phone.TcpTestSucceeded){'ACTIVE - PBX Responding'}else{'OFFLINE - Service Down'})"
            }
        }
        "6" {
            Write-Host "`nCleaning up old logs..." -ForegroundColor Cyan
            $Limit = (Get-Date).AddDays(-30)
            $OldFiles = Get-ChildItem -Path $LogFolder -File | Where-Object { $_.LastWriteTime -lt $Limit }
            
            if ($OldFiles) {
                $OldFiles | Move-Item -Destination $ArchiveFolder
                Write-Host "Moved $($OldFiles.Count) files to Archive." -ForegroundColor Green
            } else {
                Write-Host "No logs older than 30 days found." -ForegroundColor Gray
            }
        }
        "Q" { break }
    }

    if ($choice -ne "Q") {
        Write-Host "`nOperation Finished." -ForegroundColor Gray
        Read-Host "Press Enter to return to Menu"
    }

} while ($choice -ne "Q")