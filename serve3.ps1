$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://127.0.0.1:9876/')
$listener.Start()
Write-Host 'Server started at http://127.0.0.1:9876/color-mind-ai.html'
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $p = $ctx.Request.Url.LocalPath.TrimStart('/')
    if ($p -eq '') { $p = 'color-mind-ai.html' }
    $f = Join-Path 'e:\-\shuimo' $p
    if (Test-Path $f -PathType Leaf) {
        $b = [IO.File]::ReadAllBytes($f)
        $ctx.Response.StatusCode = 200
        $ctx.Response.ContentType = 'text/html; charset=utf-8'
        $ctx.Response.ContentLength64 = $b.Length
        $ctx.Response.OutputStream.Write($b, 0, $b.Length)
    } else {
        $ctx.Response.StatusCode = 404
    }
    $ctx.Response.Close()
}
