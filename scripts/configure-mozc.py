"""Enable Mozc in Fcitx5's active group without changing hotkeys or layout."""
import configparser
import re
import shutil
import sys
from datetime import datetime
from pathlib import Path

path = Path(sys.argv[1])
original = path.read_text() if path.exists() else ""
config = configparser.ConfigParser(interpolation=None)
config.optionxform = str
config.read_string(original)
order = config.get("GroupOrder", "0", fallback="0")
group = next((s for s in config.sections() if re.fullmatch(r"Groups/\d+", s) and config.get(s, "Name", fallback="") == order), f"Groups/{order}")
if group not in config:
    if original.strip():
        raise SystemExit("Cannot identify the active Fcitx5 group; inspect profile manually.")
    original = "[Groups/0]\nName=Default\nDefault Layout=us\nDefaultIM=mozc\n\n[Groups/0/Items/0]\nName=keyboard-us\n\n[GroupOrder]\n0=Default\n"
    config.read_string(original)
    group = "Groups/0"
prefix = group + "/Items/"
items = [s for s in config.sections() if s.startswith(prefix)]
has_mozc = any(config.get(s, "Name", fallback="") == "mozc" for s in items)
updated = original
if not has_mozc:
    index = max([int(s[len(prefix):]) for s in items if s[len(prefix):].isdigit()], default=-1) + 1
    updated = original.rstrip() + f"\n\n[{prefix}{index}]\nName=mozc\n"
if config.get(group, "DefaultIM", fallback="") != "mozc":
    pattern = rf"(\[{re.escape(group)}\]\n)(.*?)(?=\n\[|\Z)"
    def change(match):
        body = match.group(2)
        if re.search(r"^DefaultIM=", body, re.M):
            body = re.sub(r"^DefaultIM=.*$", "DefaultIM=mozc", body, flags=re.M)
        else:
            body = "DefaultIM=mozc\n" + body
        return match.group(1) + body
    updated = re.sub(pattern, change, updated, count=1, flags=re.S)
if updated != (path.read_text() if path.exists() else ""):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        shutil.copy2(path, path.with_name(path.name + ".bak." + datetime.now().strftime("%Y%m%d-%H%M%S-%f")))
    path.write_text(updated)
    print("Mozc profile updated; keyboard layout and hotkeys preserved.")
else:
    print("Mozc is already configured.")
