$tcp = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, 7890)
$tcp.Start()
Write-Host 'Server running at http://localhost:7890/color-mind-ai.html'
while ($true) {
    $cl = $tcp.AcceptTcpClient()
    $s = $cl.GetStream()
    $sr = New-Object System.IO.StreamReader($s)
    $req = $sr.ReadLine()
    $path = 'color-mind-ai.html'
    if ($req -match 'GET (/[^ ]+)') {
        $path = $matches[1].TrimStart('/')
    }
    if ($path -eq '') { $path = 'color-mind-ai.html' }
    $f = Join-Path 'e:\-\shuimo' $path
    if (Test-Path $f -PathType Leaf) {
        $b = [IO.File]::ReadAllBytes($f)
        $h = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: $($b.Length)`r`nConnection: close`r`n`r`n"
        $hb = [Text.Encoding]::UTF8.GetBytes($h)
        $s.Write($hb, 0, $hb.Length)
        $s.Write($b, 0, $b.Length)
    } else {
        $h = "HTTP/1.1 404 Not Found`r`nContent-Length: 0`r`nConnection: close`r`n`r`n"
        $hb = [Text.Encoding]::UTF8.GetBytes($h)
        $s.Write($hb, 0, $hb.Length)
    }
    $cl.Close()
}
