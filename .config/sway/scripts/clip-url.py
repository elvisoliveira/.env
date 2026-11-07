#!/usr/bin/python3 -I
"""Tidies a copied link: joins wrapped lines and safely URL-decodes it.

Run via: wl-paste --type text --watch clip-url.py   (--test runs the self-check)
Only acts when the whole copied text is one http(s) link. Safe decode =
%XX becomes a literal only for unreserved ASCII (A-Z a-z 0-9 - . _ ~) and
printable non-ASCII (é, ç, 中...), which browsers re-encode to the same bytes.
Delimiters (/ ? # & = + % ...), spaces and invisible chars stay encoded, so
the link still points to the same place.
"""
import os
import re
import subprocess
import sys
import unicodedata

URL = re.compile(r"https?://\S+")
UNRESERVED = re.compile(r"[A-Za-z0-9._~-]")


def keep_encoded(ch):
    if ord(ch) < 0x80:
        return not UNRESERVED.fullmatch(ch)
    return unicodedata.category(ch)[0] in "CZ"  # control/format/space (RTL tricks, NBSP)


def decode_run(m):
    raw = m.group(0)
    try:
        text = bytes.fromhex(raw.replace("%", "")).decode("utf-8")
    except UnicodeDecodeError:
        return raw.upper()  # not UTF-8 (e.g. latin-1 %E7): leave as is
    return "".join(
        "".join(f"%{b:02X}" for b in ch.encode()) if keep_encoded(ch) else ch
        for ch in text
    )


def tidy(text):
    """Returns the tidied link, or None when text is not a single link."""
    joined = "".join(line.strip() for line in text.splitlines())
    if not URL.fullmatch(joined):
        return None
    return re.sub(r"(?:%[0-9A-Fa-f]{2})+", decode_run, joined)


def test():
    cases = {
        "https://pt.wikipedia.org/wiki/S%C3%A3o_Paulo": "https://pt.wikipedia.org/wiki/São_Paulo",
        "https://x.com/a%20b": "https://x.com/a%20b",
        "https://x.com/?r=https%3A%2F%2Fy.com%2F%3Fa%3D1%26b%3D2":
            "https://x.com/?r=https%3A%2F%2Fy.com%2F%3Fa%3D1%26b%3D2",
        "https://x.com/%2541%2B%23": "https://x.com/%2541%2B%23",
        "https://x.com/%7Euser/%41%62": "https://x.com/~user/Ab",
        "https://x.com/%E2%80%AEevil": "https://x.com/%E2%80%AEevil",  # RTL override
        "https://x.com/%E7": "https://x.com/%E7",
        "  https://x.com/very/long/\n   path?q=caf%C3%A9\n": "https://x.com/very/long/path?q=café",
    }
    for src, want in cases.items():
        got = tidy(src)
        assert got == want, f"{src!r}: {got!r} != {want!r}"
    for not_link in ("veja https://x.com", "ftp://x.com", "texto\nqualquer", ""):
        assert tidy(not_link) is None, not_link
    assert tidy(tidy(next(iter(cases)))) == tidy(next(iter(cases)))  # idempotent
    print("ok")


if __name__ == "__main__":
    if sys.argv[1:] == ["--test"]:
        test()
        sys.exit()
    if os.environ.get("CLIPBOARD_STATE") == "sensitive":
        sys.exit()
    text = sys.stdin.read()
    out = tidy(text)
    if out is not None and out != text:  # unchanged = our own copy coming back: stop
        subprocess.run(["wl-copy", "--", out])
