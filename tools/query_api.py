#!/usr/bin/env python3
"""Query one installed SDK's exported barrel metadata without loading private faces.

Metadata is an index, not a replacement for source declarations or API contracts:
interface members and variadic/default details can be absent in a serialized face.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def public_entries(sdk: Path, package: str, profile: str) -> list[dict[str, Any]]:
    """Read only the selected kernel/stdlib public barrel, preserving identities."""
    if package not in {"kernel", "stdlib"}:
        raise ValueError("package must be kernel or stdlib")
    if not profile or profile in {".", ".."} or Path(profile).name != profile or "\\" in profile:
        raise ValueError("profile must be one explicit SDK target directory name")
    sdk = sdk.resolve()
    manifest = json.loads((sdk / "manifest.json").read_text(encoding="utf-8"))
    relative = package + ".ny"
    encoded = relative.encode("utf-8")
    face_path = sdk / "packages" / package / "targets" / profile / "faces" / f"{len(encoded)}_{encoded.hex()}.json"
    face = json.loads(face_path.read_text(encoding="utf-8"))
    names = face.get("names")
    if not isinstance(names, dict):
        raise ValueError("unsupported public face: expected a names object")
    entries = []
    for qualified_name, item in sorted(names.items()):
        if not isinstance(item, dict) or item.get("pub") is not True:
            continue
        # Do not expose record layouts, link internals or private provider paths.
        entries.append({
            "sdk_version": str(manifest.get("version", "unknown")),
            "package": package,
            "profile": profile,
            "name": qualified_name,
            "kind": item.get("kind", "unknown"),
            "static": bool(item.get("isStatic", False)),
            "receiver": item.get("recv", ""),
            "result": item.get("ret", ""),
            "parameters": item.get("paramInfos", []),
        })
    return entries


def search(entries: list[dict[str, Any]], query: str, exact: bool = False) -> list[dict[str, Any]]:
    """Match public qualified names only; exact lookup remains case-sensitive."""
    if exact:
        return [entry for entry in entries if entry["name"] == query]
    needle = query.casefold()
    return [entry for entry in entries if needle in entry["name"].casefold()]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sdk", required=True, type=Path)
    parser.add_argument("--package", required=True, choices=("kernel", "stdlib"))
    parser.add_argument("--profile", required=True, help="exact directory under packages/PACKAGE/targets")
    parser.add_argument("--query", required=True)
    parser.add_argument("--exact", action="store_true")
    parser.add_argument("--json", action="store_true", dest="as_json")
    args = parser.parse_args(argv)
    try:
        found = search(public_entries(args.sdk, args.package, args.profile), args.query, args.exact)
    except (OSError, ValueError, TypeError) as exc:
        parser.exit(2, f"API lookup failed: {exc}\n")
    if args.as_json:
        print(json.dumps(found, ensure_ascii=False, indent=2))
    else:
        print("Public barrel metadata index; inspect declarations for interface members, variadics and defaults.")
        for item in found:
            role = ("static " if item["static"] else "") + item["kind"]
            print(f"{item['package']} {item['name']} [{role}] SDK {item['sdk_version']} / {item['profile']}")
            if item["receiver"]:
                print(f"  receiver: {item['receiver']}")
            if item["parameters"]:
                print("  face parameters: " + ", ".join(f"{p.get('name', '?')}: {p.get('typ', '?')}" for p in item["parameters"]))
            if item["result"]:
                print(f"  result: {item['result']}")
    return 0 if found else 1


if __name__ == "__main__":
    raise SystemExit(main())
