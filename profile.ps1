###############
#region posh git stuff
Set-Alias gs Get-Service

# Load posh-git example profile
. ($global:POSH_HOME + '\posh-git\profile.example.ps1') #be sure to set the $global:POSH_HOME variable correctly in your profile before importing this file
#endregion
###############


###############
#region aliases
New-Alias vs $global:VISUAL_STUDIO
New-Alias EX explorer.exe
New-Alias subl $global:SUBL_PATH
#endregion
###############


###############
#region vim stuff
$SCRIPTPATH = "~\Scripts"
$VIMPATH    = "C:\Program Files (x86)\Vim\vim73\vim.exe"

Set-Alias vi   $VIMPATH
Set-Alias vim  $VIMPATH

# for editing your Vim settings
Function Edit-Vimrc
{
    vim ~\_vimrc
}
#endregion
###############


###############
#region utils
Function Build(){
	if (IsGitDirectory)
	{
		$Directory = [System.IO.Directory];
		$Thread = [System.Threading.Thread];

		$currDir = Convert-Path (Get-Location -PSProvider FileSystem)
		$sourceDir = $currDir + "\Source\";

		$slns = $Directory::GetFiles($sourceDir, "*.sln", "AllDirectories");

		$preBuildDevelopmentProcessIDs = get-process dev* | %{$_.id}

		#Start a visual studio session for every solution file found under the root
		$slns | %{vs $_ /build Debug}

		$postBuildDevelopmentProcessIDs = get-process dev* | %{$_.id}

		if($preBuildDevelopmentProcessIDs -ne $nothing){
			$buildProcessId = (Compare-Object $preBuildDevelopmentProcessIDs $postBuildDevelopmentProcessIDs | Where{ $_.SideIndicator -eq '=>'}).InputObject
		}
		else{
			$buildProcessId = $postBuildDevelopmentProcessIDs
		}

		Write-Host 'Building .' -noNewLine
		do{
			$Thread::Sleep(1000)
			Write-Host '.' -noNewLine
			$devProcessIDs = (, (get-process dev* | %{$_.Id}) )
		}while( $devProcessIDs -contains $buildProcessID)
		Write-Host ' ' -noNewLine
		Write-Host 'Done'
	}
}

Function Dev(){
	#Search recursively through the source folder of the git project for all *.sln file found
	#Open the *.sln file with
	#'C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe'
	if (IsGitDirectory)
	{
		$Directory = [System.IO.Directory];

		$currDir = Convert-Path (Get-Location -PSProvider FileSystem)
		$sourceDir = $currDir + "\Source\";

		$slns = $Directory::GetFiles($sourceDir, "*.sln", "AllDirectories");

		#Start a visual studio session for every solution file found under the root
		$slns | %{vs $_}
	}
}

Function Edit-Host
{
    subl C:\Windows\System32\drivers\etc\hosts
}

Function Edit-Profile
{
    subl ($global:POSH_HOME + '\..\Microsoft.Powershell_profile.ps1')
}

Function JRemote([string]$key)
{
	mstsc $global:RDC[$key]
}

Function JVPN-Connect([string]$vpn){
	$connected = ((ping livedb -n 1 -w 10).count -eq 8) #would be 6 if we aren't connected

	if(-not $connected){
		#there was no open connection go ahead and open it
		rasdial $vpn $global:VPN[$vpn] *
	}
	elseif($connected){
		if(Ask-YesOrNo -message 'Your connection is currently open would you like to close it?'){
			rasdial $vpn /d
		}
		#the connection was already open when this was called
		#so just close the connection and don't do anything else
	}
}

Function JLog([string]$fileKey)
{
	notepad $global:LOGS[$fileKey]
}

Function JSSH([string]$sshKey)
{
	ssh ('root@' + $global:SSH[$sshKey])
}
#endregion
###############


###############
#region helpers
Function Ask-YesOrNo(){
	param([string]$title="",[string]$message="Are you sure?")

	$choiceYes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Answer Yes."
	$choiceNo = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Answer No."

	$options = [System.Management.Automation.Host.ChoiceDescription[]]($choiceYes, $choiceNo)

	$result = $host.ui.PromptForChoice($title, $message, $options, 1)

	switch ($result)
	{
		0
		{
		Return $true
		}

		1
		{
		Return $false
		}
	}
}

function IsGitDirectory {
    if ((Test-Path ".git") -eq $TRUE) {
        return $TRUE
    }
    return $FALSE
}
#endregion
###############
