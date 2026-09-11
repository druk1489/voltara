#!/usr/bin/env python3
"""
Voltara local host
==================
Раздаёт КОРЕНЬ репозитория по HTTP, чтобы VoltaraLoader.lua грузил модули
с твоего компьютера вместо GitHub. Правь source/MainModule.lua,
source/SecondModule.lua, server/*.lua и т.д. и перезапускай скрипт в игре.

Запуск:  python voltara_host.py            -> http://127.0.0.1:8000
         python voltara_host.py 8080
         python voltara_host.py 8080 0.0.0.0   (для телефона в той же сети)

Только стандартная библиотека, зависимостей нет.
"""
import os
import sys
import mimetypes
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import unquote

# ROOT = корень репо = папка на уровень выше этой (local_test/)
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
HOST = sys.argv[2] if len(sys.argv) > 2 else "127.0.0.1"


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, body, ctype="text/plain; charset=utf-8"):
        if isinstance(body, str):
            body = body.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        try:
            self.wfile.write(body)
        except Exception:
            pass

    def do_GET(self):
        path = unquote(self.path.split("?", 1)[0])

        if path in ("/", "/health"):
            self._send(200, "Voltara host OK\nroot=" + ROOT + "\n")
            return

        safe = os.path.normpath(os.path.join(ROOT, path.lstrip("/")))
        if not safe.startswith(ROOT):
            self._send(403, "forbidden\n")
            return

        if os.path.isdir(safe):
            try:
                lines = ["index of " + path + "\n"]
                for e in sorted(os.listdir(safe)):
                    full = os.path.join(safe, e)
                    lines.append("  " + e + ("/" if os.path.isdir(full) else "") + "\n")
                self._send(200, "".join(lines))
            except Exception as ex:
                self._send(500, "dir error: %s\n" % ex)
            return

        if os.path.isfile(safe):
            if safe.endswith((".lua", ".Build", ".json", ".txt", ".md", ".py")):
                ctype = "text/plain; charset=utf-8"
            else:
                ctype = mimetypes.guess_type(safe)[0] or "application/octet-stream"
            try:
                with open(safe, "rb") as f:
                    self._send(200, f.read(), ctype)
            except Exception as ex:
                self._send(500, "read error: %s\n" % ex)
            return

        self._send(404, "not found: " + path + "\n")

    def log_message(self, fmt, *args):
        sys.stderr.write("[host] %s - %s\n" % (self.address_string(), fmt % args))


def main():
    print("=" * 60)
    print(" Voltara local host")
    print(" root   :", ROOT)
    print(" url    : http://%s:%d" % (HOST, PORT))
    print(" health : http://%s:%d/health" % (HOST, PORT))
    print(" Ctrl+C чтобы остановить")
    print("=" * 60)
    with ThreadingHTTPServer((HOST, PORT), Handler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nstopped.")


if __name__ == "__main__":
    main()
