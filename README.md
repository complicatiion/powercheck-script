# Windows 11 Battery & Power Diagnostic Script

Small administrative batch script for quickly analyzing battery status, power configuration, and sleep/wake behavior on Windows 11 systems.

The script collects several built-in Windows diagnostics and stores the results in a structured report directory for review or troubleshooting.

## Purpose

Designed for IT administrators who need a quick overview of:

- Battery condition
- Power plan configuration
- Sleep / wake behavior
- Energy efficiency problems
- Network power settings
- Hibernate / Fast Startup status

Works on laptops and desktop systems (battery checks are skipped automatically if no battery is present).

## Features

The script performs the following checks:

### System Power Status
- Current AC / battery state
- Active Windows power plan
- List of available power plans

### Battery Diagnostics
- Generates a Windows **battery report**
- Detects installed battery devices
- Useful for capacity and wear analysis

### Energy Analysis
- Runs Windows **energy report**
- Identifies drivers or services preventing optimal power usage

### Sleep / Wake Diagnostics
- Last wake source
- Wake timers
- Devices allowed to wake the system
- Sleep study report (supported hardware only)

### Power Configuration
Checks status of:

- Hibernate
- Fast Startup
- Active power schemes

### Network Adapter Power Details
Displays network adapters with power management capabilities relevant for:

- Wake-on-LAN
- Energy Efficient Ethernet
- Power saving states

### Optional Actions
The script can also:

- Switch system to **Balanced power plan**
- Enable or disable **Hibernation**

## Output

All generated reports are saved to: Desktop\PowerReports

## Notes

- On desktop systems without batteries, battery diagnostics are skipped automatically.
- Some reports (`energy-report`, `sleepstudy`) require elevated privileges.
- The script focuses on **analysis and diagnostics**, not aggressive system modification.

## Typical Use Cases

- Battery health evaluation
- Diagnosing sleep / wake problems
- Investigating unexpected power consumption
- Preparing support reports
- Verifying enterprise power configuration

## License

Internal administrative utility. Use and modify as needed.


