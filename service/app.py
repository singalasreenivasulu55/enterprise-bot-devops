import json
import os
import socket
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            data = {
                "app": os.environ.get("APP_NAME", "demo"),
                "version": os.environ.get("VERSION", "1.0.0"),
                "pod": socket.gethostname(),
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(data).encode())

        elif self.path == "/healthz":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"healthy")

        else:
            self.send_error(404)

    def log_message(self, format, *args):
        print(format % args, flush=True)


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8080), Handler)
    print("Server running on port 8080", flush=True)
    server.serve_forever()
