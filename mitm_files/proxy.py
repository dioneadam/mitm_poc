from mitmproxy import http

def response(flow: http.HTTPFlow) -> None:
    flow.response.content = flow.response.content.decode().replace("The conection is just fine!", "Just the same website, nothing unusual here! :)").encode()
