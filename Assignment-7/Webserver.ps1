<#
https://stackoverflow.com/questions/11403333/httplistener-with-https-support
[1] makecert -n "CN=vMargeCA" -r -sv vMargeCA.pvk vMargeCA.cer
[2] makecert -sk vMargeSignedByCA -iv vMargeCA.pvk -n "CN=vMargeSignedByCA" -ic vMargeCA.cer vMargeSignedByCA.cer -sr localmachine -ss My
[3] Use MMC GUI to install CA in Trusted Authority store
[4] Use MMC GUI to install ssl cert in Personal store

[5] netsh http add sslcert ipport=0.0.0.0:8443 certhash=9ae7a6f3701a96f5635b8927b594e3c63f2db3ed "appid={df8c8073-5a4b-4810-b469-5975a9c95230}"
#>


#Credit for the Webserver to "https://gist.githubusercontent.com/19WAS85/5424431/raw/213e726a088060edd746e1c5fafd6387e4983ec2/powershell-web-server.ps1"
function Webserver
{ 
<#
.SYNOPSIS
A Simple PowerShell Webserver which could be used to list, delete, download and upload files over HTTP and HTTPS

.DESCRIPTION
This is a powershell script to run a webserver that uses GET and POST to to list, delete, download and upload files as well as having a 404 page if page does not exists.

.PARAMETER IP
The IP of the server Ex: localhost or 127.0.0.1, [ Defult is localhost ]

.PARAMETER PORT
To a bind Port for runing the webserver on Ex: 80 ,443 [ Defult is 80 ]

.SWITCH HTTP
Use HTTP as a protocol for running the webserver

.SWITCH HTTPS
Use HTTPS as a protocol for running the webserver

.EXAMPLE
PS C:\> . .\Webserver.ps1
PS C:\> webserver -IP localhost -port 8443 -https

.LINK
https://gist.githubusercontent.com/19WAS85/5424431/raw/213e726a088060edd746e1c5fafd6387e4983ec2/powershell-web-server.ps1
https://gallery.technet.microsoft.com/scriptcenter/Powershell-Webserver-74dcf466
https://stackoverflow.com/questions/11403333/httplistener-with-https-support

.NOTES
Assignment 7
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam.
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP - 3224
#>           
    [CmdletBinding()] 
    Param( 

    [Parameter(Mandatory = $false)]
    [String]
    $IP = "localhost",
       
    [Parameter(Mandatory = $false)]
    [String]
    $port = '80',

    [switch]
    $HTTP,

    [switch]
    $HTTPS

    )
   
   
   #HTML Codes for the pages
    $routes = @{
        "/" = { return '
    <div style="text-align: center;"><b><font size="5">Welcome to Simple Powershell Webserver</font></b></div>
    <div style="text-align: left;"><b><font size="5">Services:</font></b></div>
    <div style="text-align: left;"><b style="font-size: x-large;">[1] <a href="/list">List files page</a></b></div>
    <div style="text-align: left;"><font size="5"><b>[2] <a href="/download">Download files page</a></b></font></div>
    <div style="text-align: left;"><font size="5"><b>[3] <a href="/upload">Upload files page</a></b></font></div>
    <div style="text-align: left;"><font size="5"><b>[4] <a href="/delete">Delete files page</a></b></font></div>' }
        "/test" = { return '<html><body> test!</body></html>
    '}
        "/list" = { return "
    <h1>Listing files Page</h1>
    <form action='/list' method='post'>
        <p>File Path:</p><input type='text' name='path'>
        <br>
        <input type='submit' value='Submit'>
    </form>
    "}
        "/delete" = { return "
    <h1>Deleting files Page</h1>
    <form action='/delete' method='post'>
        <p>File Path:</p><input type='text' name='path'>
        <br>
        <input type='submit' value='Submit'>
    </form>
    "}
        "/download" = { return "
    <h1>Download files Page</h1>
    <form action='/download' method='post'>
        <p>File Path:</p><input type='text' name='path'>
        <br>
        <input type='submit' value='Submit'>
    </form>
    "}

        "/upload" = { return "
    <html><body>
	    <form method='POST' enctype='multipart/form-data' action='/upload'>
	    <p><b>File to upload:</b><input type='file' name='filedata'></p>
	    <b>Path to store on webserver:</b><input type='text' maxlength=255 size=80 name='filepath'>
	    <input type='submit' name='button' value='Upload'>
	    </form>
    </body></html>
    "}

    
    }

    #checking either HTTP or HTTPS
    if ($http){ $url = 'http://' + $ip + ':' + $port +'/' }
    if ($https){ $url = 'https://' + $ip + ':' + $port +'/' }
    if (!$https -and !$http) {
        write-output "You must choose either -HTTP or -HTTPS"
        break
        }

    #Here we create a lisener 
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($url)
    $listener.Start()
    Add-Type -AssemblyName System.Web

    Write-Host "Listening at $url..."


    # While loop so we maintain the server running
    while ($listener.IsListening)
    {


        $context = $listener.GetContext()
        $requestUrl = $context.Request.Url
        $response = $context.Response
        $request = $context.Request
        $AbsolutePath = $requestUrl.AbsolutePath

        Write-Host ''
        Write-Host "> $requestUrl"

        $localPath = $requestUrl.LocalPath
        $route = $routes.Get_Item($requestUrl.LocalPath)

        if ($route -eq $null)
        {
          # Status 404
            [string]$contents = '<html><head><title>404 Page Not Found</title></head><body><div id="main"><div class="fof"> <h1>Error 404</h1></div></div></body></html>' 
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($contents)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }


        elseif ($AbsolutePath -eq "/list" -and $context.Request.HttpMethod -eq 'POST')
        {

            # Reading POST requests
            $FormContent = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()
            $urldecode = [System.Web.HttpUtility]::UrlDecode($FormContent)
            $inputpath = $urldecode.Split("=")[1]
        
            $inputfromuser = Get-ChildItem $inputpath
        
            [string]$contents = @"
                    <h1>Listing files Page</h1>
                    <form action='/list' method='post'>
                        <p>File Path:</p><input type='text' name='path'>
                        <br>
                        <input type='submit' value='Submit'>
                    </form>
                    <p>Output:</p>
                    $inputfromuser 
"@
            # Returing response
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($contents)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)

        }

        elseif ($AbsolutePath -eq "/download" -and $context.Request.HttpMethod -eq 'POST')
        { # Download file

            # Reading POST requests
            $FormContent = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()
            $urldecode = [System.Web.HttpUtility]::UrlDecode($FormContent)
            $inputpath = $urldecode.Split("=")[1]
            $Filename = Split-Path -Leaf $inputpath

            # Checking if the file exists
            $output = Test-Path $inputpath 
                        
            if (!$output){
                $nofile = "file does not exists"
                [string]$contents = @"
                <h1>Download files Page</h1>
                <form action='/download' method='post'>
                    <p>File Path:</p><input type='text' name='path'>
                    <br>
                    <input type='submit' value='Submit'>
                </form>
                <p>Output:</p>
                $nofile 
"@
                # Returing response
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($contents)
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            }
            else {
                # If file exists Download the file        
		        $buffer = [System.IO.File]::ReadAllBytes($inputpath)
		        $response.ContentLength64 = $BUFFER.Length
		        $response.SendChunked = $buffer
		        $response.ContentType = "application/octet-stream"
		        $response.AddHeader("Content-Disposition", "attachment; filename=$Filename")
		        $response.OutputStream.Write($buffer, 0, $buffer.Length)
                }
        }

        elseif ($AbsolutePath -eq "/delete" -and $context.Request.HttpMethod -eq 'POST')
        { # Delete file

            # Reading POST requests
            $FormContent = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()
            $urldecode = [System.Web.HttpUtility]::UrlDecode($FormContent)
            $inputpath = $urldecode.Split("=")[1]
        
            # Checking if the file exists
            $output = Test-Path $inputpath 
                        
            if (!$output){
                $nofile = "file not deleted"
                [string]$contents = @"
                <h1>Deleting files Page</h1>
                <form action='/delete' method='post'>
                    <p>File Path:</p><input type='text' name='path'>
                    <br>
                    <input type='submit' value='Submit'>
                </form>
                <p>Output:</p>
                $nofile 
"@
                # Returing response
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($contents)
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                 }
            else {
                 # If file exists Delete the file 
                $inputfromuser = Remove-Item $inputpath 
                $mess = "file deleted successfully"
                [string]$contents = @"
                        <h1>Deleting files Page</h1>
                        <form action='/delete' method='post'>
                            <p>File Path:</p><input type='text' name='path'>
                            <br>
                            <input type='submit' value='Submit'>
                        </form>
                        <p>Output:</p>
                        $mess 
"@
                # Returing response
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($contents)
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            }
        }
    
        
        #Credit for the Uoload function to "https://gallery.technet.microsoft.com/scriptcenter/Powershell-Webserver-74dcf466"
        elseif ($AbsolutePath -eq "/upload" -and $context.Request.HttpMethod -eq 'POST')
        { # Upload file

	        # only if there is body data in the request
	        if ($REQUEST.HasEntityBody)
	        {
		        # set default message to error message (since we just stop processing on error)
		        $RESULT = "Received corrupt or incomplete form data"

		        # check content type
		        if ($REQUEST.ContentType)
		        {
			        # retrieve boundary marker for header separation
			        $BOUNDARY = $NULL
			        if ($REQUEST.ContentType -match "boundary=(.*);")
			        {	$BOUNDARY = "--" + $MATCHES[1] }
			        else
			        { # marker might be at the end of the line
				        if ($REQUEST.ContentType -match "boundary=(.*)$")
				        { $BOUNDARY = "--" + $MATCHES[1] }
			        }

			        if ($BOUNDARY)
			        { # only if header separator was found

				        # read complete header (inkl. file data) into string
				        $READER = New-Object System.IO.StreamReader($REQUEST.InputStream, $REQUEST.ContentEncoding)
				        $DATA = $READER.ReadToEnd()
				        $READER.Close()
				        $REQUEST.InputStream.Close()

				        # variables for filenames
				        $FILENAME = ""
				        $SOURCENAME = ""

				        # separate headers by boundary string
				        $DATA -replace "$BOUNDARY--\r\n", "$BOUNDARY`r`n--" -split "$BOUNDARY\r\n" | % {
					        # omit leading empty header and end marker header
					        if (($_ -ne "") -and ($_ -ne "--"))
					        {
						        # only if well defined header (seperation between meta data and data)
						        if ($_.IndexOf("`r`n`r`n") -gt 0)
						        {
							        # header data before two CRs is meta data
							        # first look for the file in header "filedata"
							        if ($_.Substring(0, $_.IndexOf("`r`n`r`n")) -match "Content-Disposition: form-data; name=(.*);")
							        {
								        $HEADERNAME = $MATCHES[1] -replace '\"'
								        # headername "filedata"?
								        if ($HEADERNAME -eq "filedata")
								        { # yes, look for source filename
									        if ($_.Substring(0, $_.IndexOf("`r`n`r`n")) -match "filename=(.*)")
									        { # source filename found
										        $SOURCENAME = $MATCHES[1] -replace "`r`n$" -replace "`r$" -replace '\"'
										        # store content of file in variable
										        $FILEDATA = $_.Substring($_.IndexOf("`r`n`r`n") + 4) -replace "`r`n$"
									        }
								        }
							        }
							        else
							        { # look for other headers (we need "filepath" to know where to store the file)
								        if ($_.Substring(0, $_.IndexOf("`r`n`r`n")) -match "Content-Disposition: form-data; name=(.*)")
								        { # header found
									        $HEADERNAME = $MATCHES[1] -replace '\"'
									        # headername "filepath"?
									        if ($HEADERNAME -eq "filepath")
									        { # yes, look for target filename
										        $FILENAME = $_.Substring($_.IndexOf("`r`n`r`n") + 4) -replace "`r`n$" -replace "`r$" -replace '\"'
									        }
								        }
							        }
						        }
					        }
				        }

				        if ($FILENAME -ne "")
				        { # upload only if a targetname is given
					        if ($SOURCENAME -ne "")
					        { # only upload if source file exists

						        # check or construct a valid filename to store
						        $TARGETNAME = ""
						        # if filename is a container name, add source filename to it
						        if (Test-Path $FILENAME -PathType Container)
						        {
							        $TARGETNAME = Join-Path $FILENAME -ChildPath $(Split-Path $SOURCENAME -Leaf)
						        } else {
							        # try name in the header
							        $TARGETNAME = $FILENAME
						        }

						        try {
							        # ... save file with the same encoding as received
							        [IO.File]::WriteAllText($TARGETNAME, $FILEDATA, $REQUEST.ContentEncoding)
						        }
						        catch	{}
						        if ($Error.Count -gt 0)
						        { # retrieve error message on error
							        $RESULT += "`nError saving '$TARGETNAME'`n`n"
							        $RESULT += $Error[0]
							        $Error.Clear()
						        }

                                else {

                                    [string]$contents = @"
                                            <html><body>
	                                            <form method='POST' enctype='multipart/form-data' action='/upload'>
	                                            <p><b>File to upload:</b><input type='file' name='filedata'></p>
	                                            <b>Path to store on webserver:</b><input type='text' maxlength=255 size=80 name='filepath'>
	                                            <input type='submit' name='button' value='Upload'>
	                                            </form>
                                            </body></html>
                                            File <b> $SOURCENAME </b>successfully uploaded as <b> $TARGETNAME  </b>
"@

                                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($contents)
                                    $response.ContentLength64 = $buffer.Length
                                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                                }

					        }
				        }
			        }
		        }
	        }
	    
        }


        else 
        {
            # For Paths in $route return response
            $content = & $route
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
    
        $response.Close()

        # Writing Status code and URL in Powershell terminal
        $responseStatus = $response.StatusCode
        Write-Host "< $responseStatus"

    }
}