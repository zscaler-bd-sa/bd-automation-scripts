 param(
        [Parameter(Mandatory=$true)]
        [string]
        $dest_storageAccountName,

        [Parameter(Mandatory=$true)]
        [string]
        $destContainerName,

        [Parameter(Mandatory=$true)]
        [string]
        $destBlob,

        [Parameter(Mandatory=$true)]
        [string]
        $sourceVhdURL,

        [Parameter(Mandatory=$true)]
        [string]
        $SasToken,
        [Parameter(Mandatory=$true)]
        [string]
        $StorageAccountKey

)

        # Credentials
        $myCredential = Get-AutomationPSCredential -Name 'automationCredentials'
        $userName = $myCredential.UserName
	$securePassword = $myCredential.Password
	$destContext = New-AzStorageContext -StorageAccountName $dest_storageAccountName -StorageAccountKey $StorageAccountKey
	$sasVHDurl=$sourceVhdURL+'?'+$SasToken


        Write-Output 'Start the copy'
	Start-AzStorageBlobCopy  -AbsoluteUri $sasVHDurl -DestContainer $destContainerName -DestBlob $destBlob -DestContext $destContext -Force
	Write-Output 'Start chekcking '
	$vhdCopyStatus=Get-AzStorageBlobCopyState -Context $destContext -Blob $destBlob -Container $destContainerName
	While($vhdCopyStatus.Status -ne "Success") {
    		if($vhdCopyStatus.Status -ne "Pending") {
        		Write-Output "Error Copying the VHD"
        		exit
        		}
	$vhdCopyStatus=Get-AzStorageBlobCopyState -Context $destContext -Blob $destBlob -Container $destContainerName
        Write-Output "VHD Copying is in Progress" $vhdCopyStatus.BytesCopied "bytes copied of" $vhdCopyStatus.TotalBytes
    		sleep 5
			}
                        Write-Output "The VHD has been successfully copied"
