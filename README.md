# airflow-lab

A lab to experiment with Apache Airflow.

## Draft lab table of contents

The chapter and lesson READMEs contain goals, planned activities, and checkpoints for discussion. Detailed walkthroughs and DAG code will be added as the lessons are developed. Start with bundled examples for the UI and CLI chapters, then create your own workflow in Chapter 3.

- [Chapter 0: Introduction and lab orientation](ch0_intro/README.md)
  - [00.01: What you will build](ch0_intro/00_01_overview/README.md)
  - [00.02: Prerequisites and readiness](ch0_intro/00_02_prerequisites/README.md)
  - [00.03: How the lab environment fits together](ch0_intro/00_03_environment/README.md)
- [Chapter 1: Explore the Airflow web UI](ch1_web_ui/README.md)
  - [01.01: Sign in and navigate](ch1_web_ui/01_01_login_navigation/README.md)
  - [01.02: Read a DAG and its tasks](ch1_web_ui/01_02_dags_tasks/README.md)
  - [01.03: Inspect runs, task states, and logs](ch1_web_ui/01_03_runs_logs/README.md)
  - [01.04: Trigger and pause a workflow](ch1_web_ui/01_04_trigger_pause/README.md)
- [Chapter 2: Explore Airflow through Docker and the CLI](ch2_cli/README.md)
  - [02.01: Inspect Docker services](ch2_cli/02_01_services/README.md)
  - [02.02: Open the worker shell](ch2_cli/02_02_worker_shell/README.md)
  - [02.03: Discover Airflow CLI commands](ch2_cli/02_03_cli_discovery/README.md)
  - [02.04: Inspect and trigger DAGs from the CLI](ch2_cli/02_04_dags_runs/README.md)
  - [02.05: Manage the lab lifecycle](ch2_cli/02_05_lifecycle/README.md)
- [Chapter 3: Write, test, run, and schedule your first DAG](ch3_first_dag/README.md)
  - [03.01: Design the sample workflow](ch3_first_dag/03_01_design/README.md)
  - [03.02: Write a TaskFlow DAG](ch3_first_dag/03_02_write/README.md)
  - [03.03: Validate discovery and imports](ch3_first_dag/03_03_validate/README.md)
  - [03.04: Test tasks and the complete DAG](ch3_first_dag/03_04_test/README.md)
  - [03.05: Run and observe the DAG](ch3_first_dag/03_05_run/README.md)
  - [03.06: Schedule recurring runs](ch3_first_dag/03_06_schedule/README.md)
- [Chapter 4: Make the workflow more resilient and flexible](ch4_advanced/README.md)
  - [04.01: Handle failures and retries](ch4_advanced/04_01_retries/README.md)
  - [04.02: Parameterize the workflow](ch4_advanced/04_02_parameters/README.md)
  - [04.03: Add branching and trigger rules](ch4_advanced/04_03_branching/README.md)
  - [04.04: Use XComs and reusable task groups](ch4_advanced/04_04_data_exchange/README.md)
  - [04.05: Control overlapping work](ch4_advanced/04_05_concurrency/README.md)
- [Chapter 5: Challenge: build and troubleshoot a workflow](ch5_challenge/README.md)
  - [05.01: Build a parameterized summary DAG](ch5_challenge/05_01_challenge/README.md)
  - [05.02: Diagnose a broken workflow](ch5_challenge/05_02_troubleshoot/README.md)
  - [05.03: Review the challenge solution](ch5_challenge/05_03_solution/README.md)
- [Chapter 6: Review and close the lab](ch6_conclusion/README.md)
  - [06.01: Review what you learned](ch6_conclusion/06_01_recap/README.md)
  - [06.02: Save your work and choose next steps](ch6_conclusion/06_02_next_steps/README.md)

## Requirements and setup

1. Install Docker Desktop, `make`, `curl`, and Python 3.
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
