$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  SIMPLE MOCK WEBSERVER RUNNING ON PORT 8000" -ForegroundColor Cyan
Write-Host "  Mimicking: PHP/8.4.26" -ForegroundColor Yellow
Write-Host "  Press Ctrl+C in this window to stop it" -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor Cyan

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Inject the mock PHP version header
        $response.Headers.Add("X-Powered-By", "PHP/8.4.26")
        
        Write-Host "Received $($request.HttpMethod) request..." -ForegroundColor Green
        
        # Simple HTML landing page
        $html = "Local PHP Development SiteStatus: Active"
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
        
        # Write response
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
        
        Write-Host "Successfully responded!" -ForegroundColor Gray
    }
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
finally {
    $listener.Stop()
}