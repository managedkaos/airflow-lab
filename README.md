# Airflow Lab

A lab to experiment with Apache Airflow.

## Draft lab table of contents

The chapter and lesson READMEs contain goals, planned activities, and checkpoints for discussion. Detailed walkthroughs and DAG code will be added as the lessons are developed. Start with bundled examples for the UI and CLI chapters, then create your own workflow in Chapter 3.

- [Chapter 0: Introduction and lab orientation](ch0_intro/README.md)
- [Chapter 1: Explore the Airflow web UI](ch1_web_ui/README.md)
- [Chapter 2: Explore Airflow through Docker and the CLI](ch2_cli/README.md)
- [Chapter 3: Write, test, run, and schedule your first DAG](ch3_first_dag/README.md)
- [Chapter 4: Make the workflow more resilient and flexible](ch4_advanced/README.md)
- [Chapter 5: Challenge: build and troubleshoot a workflow](ch5_challenge/README.md)
- [Chapter 6: Review and close the lab](ch6_conclusion/README.md)

## Requirements and setup

1. You'll need to have the following tools installed:

  - A container management system:
    - [Docker Desktop](https://www.docker.com/products/docker-desktop/)
    - [Podman](https://podman.io/)
    - [Orbstack](https://orbstack.dev/)
  - `python3`
  - `make`
  - `curl`

2. Allocate at least 4 GB of memory for Docker (8 GB recommended).
3. Inside the lab directory, run the following commands to set up and start the lab environment:

  ```bash
  make setup init up
  ```

>  [!TIP] `setup` downloads the latest stable [official Compose template](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html) and configures it to read the Fernet key and example setting from `.env`. It uses your macOS/Linux UID, generates a Fernet key with the downloaded template's Airflow image, and preserves an existing key. To select a specific version, use `make setup AIRFLOW_VERSION=3.3.2`. Downloading replaces the existing Compose file.

4. Open <http://localhost:8080> after services become healthy; the default login is `airflow` / `airflow`.
5. Proceed to the first chapter and lesson.

## Explore the lab environment

| Command | Action |
| --- | --- |
| `make` | Show available targets |
| `make setup` | Download Compose, prepare `.env`, and create local directories |
| `make init` | Initialize the database and default account |
| `make up` | Initialize and start without examples |
| `make up-examples` | Initialize and start with examples |
| `make shell` | Open Bash in the running Airflow worker; type `exit` to leave |
| `make status` | Show service status and a snapshot of resource usage |
| `make logs` | Follow service logs; press Ctrl+C to exit |
| `make down` | Stop containers and retain all data |
| `make clean` | Remove containers, volumes, and local lab files |
| `make nuke` | Clean and remove all images used by this stack |


Run `make setup` before the first `make init`, `make up`, or `make up-examples`; those targets expect the Compose file, `.env`, and local directories to exist. `up` and `up-examples` both run initialization, so a separate `make init` is optional. The `_download` and `_env` targets are internal setup helpers.

Switching startup targets preserves the database, so previously loaded examples may remain. For a fresh database without examples, save custom workflows, run `make clean`, then `make setup` and `make up`. Setup recreates the deleted local directories and downloads Compose again.

> [!CAUTION] **`clean` and `nuke` delete all database metadata and the local `dags`, `logs`, `plugins`, and `config` directories, including custom workflows.**
> They retain `.env`, `docker-compose.yaml`, and other repository files.
> `nuke` also removes all images used by this stack. `clean` ignores errors from Compose shutdown and proceeds with local file deletion; `nuke` requires shutdown to succeed before deleting local files.

<!-- FooterStart -->
---
[00.01: What you will build →](ch0_intro/00_01_overview/README.md)
<!-- FooterEnd -->
