from mitmproxy import http, ctx
def request(flow: http.HTTPFlow) -> None:
    # ctx.log()
    if flow.request.pretty_host.endswith("api.example.com") and '/oauth2' not in flow.request.path:
        flow.request.host = "127.0.0.1"
        flow.request.port = 8000
        flow.request.scheme = 'http'
        flow.request.path = flow.request.path.replace("ecom/v1", "api")