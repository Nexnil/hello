$tcp = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, 7891)
$tcp.Start()
Write-Host 'Server running at http://localhost:7891/color-mind-ai.html'
while ($true) {
    $cl = $tcp.AcceptTcpClient()
    $cl.ReceiveTimeout = 5000
    $s = $cl.GetStream()
    $buf = New-Object byte[] 4096
    $sb = New-Object System.Text.StringBuilder
    $totalRead = 0
    do {
        $n = $s.Read($buf, 0, $buf.Length)
        if ($n -gt 0) {
            $sb.Append([Text.Encoding]::ASCII.GetString($buf, 0, $n)) | Out-Null
            $totalRead += $n
        }
    } while ($s.DataAvailable -and $n -gt 0)
    $req = $sb.ToString()
    $path = 'color-mind-ai.html'
    if ($req -match 'GET\s+(/[^\s]+)') {
        $path = $matches[1].TrimStart('/')
    }
    if ($path -eq '') { $path = 'color-mind-ai.html' }
    $f = Join-Path 'e:\-\shuimo' $path
    if (Test-Path $f -PathType Leaf) {
        $b = [IO.File]::ReadAllBytes($f)
        $resp = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: $($b.Length)`r`nConnection: close`r`n`r`n"
        $rbytes = [Text.Encoding]::UTF8.GetBytes($resp)
        $s.Write($rbytes, 0, $rbytes.Length)
        $s.Write($b, 0, $b.Length)
        $s.Flush()
    } else {
        $resp = "HTTP/1.1 404 Not Found`r`nContent-Length: 0`r`nConnection: close`r`n`r`n"
        $rbytes = [Text.Encoding]::UTF8.GetBytes($resp)
        $s.Write($rbytes, 0, $rbytes.Length)
        $s.Flush()
    }
    Start-Sleep -Milliseconds 50
    $cl.Close()
}
