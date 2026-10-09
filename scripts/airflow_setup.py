"""Prepare the official Compose template and local dotenv configuration."""

import os
from pathlib import Path
import re
import subprocess
import sys


def configure_compose(path):
    text = path.read_text()
    for name, value in (
        ("AIRFLOW__CORE__FERNET_KEY", "${FERNET_KEY}"),
        ("AIRFLOW__CORE__LOAD_EXAMPLES", "${AIRFLOW__CORE__LOAD_EXAMPLES:-false}"),
    ):
        text, count = re.subn(
            rf"^(\s*{name}:)[^\n]*$", rf"\g<1> {value}", text, flags=re.MULTILINE
        )
        if count != 1:
            raise SystemExit(f"Expected one {name} setting in {path}; found {count}")
    path.write_text(text)


def update_env(updates):
    path = Path(".env")
    lines = path.read_text().splitlines() if path.exists() else []
    result = []
    remaining = dict(updates)
    for line in lines:
        name = line.partition("=")[0].strip()
        if name in updates:
            if name in remaining:
                result.append(f"{name}={remaining.pop(name)}")
        else:
            result.append(line)
    result.extend(f"{name}={value}" for name, value in remaining.items())
    path.touch(mode=0o600, exist_ok=True)
    path.chmod(0o600)
    path.write_text("\n".join(result) + "\n")


def prepare_env():
    path = Path(".env")
    text = path.read_text() if path.exists() else ""
    updates = {"AIRFLOW_UID": str(os.getuid())}
    key = re.search(r"^FERNET_KEY\s*=\s*(.*?)\s*$", text, re.MULTILINE)
    if not key or not key.group(1).strip("\"'"):
        compose = Path("docker-compose.yaml").read_text()
        image = re.search(r"apache/airflow:([^}\s]+)", compose)
        if not image:
            raise SystemExit("Cannot determine the Airflow image from docker-compose.yaml")
        updates["FERNET_KEY"] = subprocess.check_output(
            ["docker", "run", "--rm", f"apache/airflow:{image.group(1)}", "python", "-c",
             "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"],
            text=True,
        ).strip()
    if not re.search(r"^AIRFLOW__CORE__LOAD_EXAMPLES\s*=", text, re.MULTILINE):
        updates["AIRFLOW__CORE__LOAD_EXAMPLES"] = "false"
    update_env(updates)


if __name__ == "__main__":
    action = sys.argv[1]
    if action == "compose":
        configure_compose(Path(sys.argv[2]))
    elif action == "env":
        prepare_env()
    elif action == "examples":
        update_env({"AIRFLOW__CORE__LOAD_EXAMPLES": sys.argv[2]})
    else:
        raise SystemExit(f"Unknown action: {action}")
