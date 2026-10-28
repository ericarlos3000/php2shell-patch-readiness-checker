$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ROBUST MOCK WEBSERVER RUNNING ON PORT 8000" -ForegroundColor Cyan
Write-Host "  Mimicking safe version: PHP/8.5.15" -ForegroundColor Green
Write-Host "  Press Ctrl+C to stop it" -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor Cyan

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Inject the mock PHP version header (Fully Patched & Safe)
        $response.Headers.Add("X-Powered-By", "PHP/8.5.15")
        
        Write-Host "Received $($request.HttpMethod) request..." -ForegroundColor Green
        
        # Simple HTML page content
        $html = "Local PHP Development SiteStatus: Fully Secure (8.5.15)"
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
        
        # Set the content length header
        $response.ContentLength64 = $buffer.Length
        
        # CRITICAL SAFEGUARD: Only write to the output stream if it is NOT a HEAD request!
        if ($request.HttpMethod -ne "HEAD") {
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        
        $response.Close()
        Write-Host "Successfully responded to $($request.HttpMethod) request!" -ForegroundColor Gray
    }
}
catch {
    Write-Host "An error occurred inside the loop: $_" -ForegroundColor Red
}
finally {
    # Since this is running as a script file, finally will always clean up properly!
    $listener.Stop()
    Write-Host "Server stopped." -ForegroundColor Yellow
}