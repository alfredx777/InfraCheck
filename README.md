🛠️ InfraCheck v3.0
Minimalist automation for the daily IT "Morning Walk." One script to monitor LAN, Servers, UPS, and VoIP systems.

⚡ Quick Start
Download: git clone https://github.com/alfredx777/InfraCheck.git

Config: Update IPs in InfraCheck.ps1.

Run: Right-click → Run with PowerShell.

📊 System Coverage
Module,Check Performed,Protocol/Port
Connectivity,WAN + Gateway + WiFi,ICMP / Netsh
Server Health,CPU + RAM + SMART Disk,CIM/WMI
Power,UPS Management Card,TCP 80
VoIP,PBX Signaling,SIP 5060

📂 Log Management
Logs are auto-organized on your Desktop:

- Infrastructure_Logs/ — Active daily reports.
- Infrastructure_Logs/Archive/ — Auto-moved logs > 30 days.
