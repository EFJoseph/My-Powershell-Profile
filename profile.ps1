###############
#region posh git stuff
Set-Alias gs Get-Service

# Load posh-git example profile
. ($global:POSH_HOME + '\posh-git\profile.example.ps1')
#endregion
###############


###############
#region aliases
New-Alias n++ 'C:\Program Files (x86)\Notepad++\notepad++.exe'
New-Alias vs 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe'
New-Alias Elastic 'C:\Projects\elasticsearch-0.17.7\bin\elasticsearch.bat'
New-Alias EX explorer.exe
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
    vim $home\_vimrc
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
		$slns | %{devenv $_ /build Debug}
		
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
    vim C:\Windows\System32\drivers\etc\hosts
}

Function Edit-Profile
{
    vim 'C:\Users\Joseph\Documents\My Dropbox\work\Posh\profile.ps1' 
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
