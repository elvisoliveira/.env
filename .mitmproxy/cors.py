# based on https://gist.github.com/jhass/652dd780d23c1e236ff913e8a2b77eb2
# http://jsbin.com/wonitaqode/edit?js,output

# mitmproxy -s cors.py
# mitmdump -s cors.py

from mitmproxy import http

def response(flow):
    h = flow.request.headers
    origin = h['origin'] if 'origin' in h else '*'
    flow.response.headers["Access-Control-Allow-Origin"] = origin
    #flow.response.headers["Access-Control-Expose-Headers"] = "Authorization"


def request(flow):
    print(flow.request.method, flow.request.url)
    # print(flow.request.headers)
    # print(dir(flow.request)) # method host path  url pretty_url port pretty_host
    # print(flow.request.host)
    # print(flow.request.path)
    if flow.request.method == "OPTIONS":
        h = flow.request.headers
        origin = h['origin'] if 'origin' in h else '*'
        flow.response = http.HTTPResponse.make(200, b"",
                                               {
                                                   "Access-Control-Allow-Origin": origin,
                                                   "Access-Control-Allow-Methods": "GET,POST",
                                                   "Access-Control-Allow-Headers": "Authorization",
                                                   "Access-Control-Max-Age": "1728000"
                                               })
