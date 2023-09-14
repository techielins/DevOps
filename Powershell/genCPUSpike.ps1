#Basic PowerShell script that generates a CPU spike for 10 minutes
# Define the duration for which you want to generate the CPU spike in seconds (10 minutes = 600 seconds)
$durationInSeconds = 600

# Get the current time
$startTime = Get-Date

# Loop for the specified duration, generating CPU load
while ((Get-Date) -lt ($startTime.AddSeconds($durationInSeconds))) {
    # Perform a CPU-intensive operation (e.g., calculation)
    1 + 1
}

# Display a message when the script is done
Write-Host "CPU spike generation completed."

# Here's how you can run the script:

# Open PowerShell as an administrator (right-click on PowerShell and select "Run as administrator").
# Navigate to the directory where you saved the script using the cd command.
# Run the script by typing .\GenerateCPUSpike.ps1 and pressing Enter.
# Make sure to adjust the $durationInSeconds variable if you want the CPU spike to last for a different duration.
