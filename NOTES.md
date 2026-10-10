# Notes

## Inspect Python libraries in the worker

With the environment running, open an interactive Bash session in the Airflow worker container:

```bash
make shell
```

At the container's shell prompt, list the installed Python libraries and their versions:

```bash
pip list
```

These are the packages available inside the worker container, where Airflow tasks execute. To leave the container shell and return to your local terminal, run:

```bash
exit
```

## Local setup

Based on the official [Airflow Docker Compose guide](https://airflow.apache.org/docs/apache-airflow/3.3.2/howto/docker-compose/index.html).

1. Install and start Docker Desktop with Compose v2.14.0 or newer. Allocate at least 4 GB of RAM, ideally 8 GB, in **Settings > Resources**.

2. Open a terminal in this repository:

   ```bash
   cd airflow-lab
   ```

   The following manual example targets Airflow 3.3.2; `make setup` downloads the latest stable version by default. For a separate, fresh project, download the template with:

   ```bash
   curl -LfO 'https://airflow.apache.org/docs/apache-airflow/3.3.2/docker-compose.yaml'
   ```

   Download the YAML file itself, not the documentation HTML page. In its shared Airflow environment, set `AIRFLOW__CORE__FERNET_KEY: ${FERNET_KEY}` so the key in step 5 is used. `make setup` applies this change automatically.

3. Create the local directories:

   ```bash
   mkdir -p dags logs plugins config
   ```

4. Create or edit `.env`. On Linux/macOS, get your user ID with `id -u` and add it as `AIRFLOW_UID`; on Windows, use `50000`:

   ```dotenv
   AIRFLOW_UID=YOUR_USER_ID
   ```

   Preserve existing entries when editing `.env`.

5. Generate a Fernet key using the same Airflow version as the lab:

   ```bash
   docker run --rm apache/airflow:3.3.2 python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
   ```

   Copy the output into `.env`:

   ```dotenv
   FERNET_KEY=YOUR_GENERATED_KEY_HERE
   ```

   This key encrypts stored connection passwords and resolves the unset `FERNET_KEY` warnings in this repository's Compose file. Keep it for subsequent runs; `.env` is ignored by Git.

6. Initialize the metadata database and default account. If you previously saw Fernet warnings, rerun this after completing step 5:

   ```bash
   docker compose run --rm airflow-init
   ```

   Wait for successful completion (exit code 0).

7. Start services and check their status:

   ```bash
   docker compose up --detach
   docker compose ps
   ```

8. Once services are healthy, open <http://localhost:8080> and sign in with username `airflow` and password `airflow`.

## Disable example DAGs

1. Add or update this entry in `.env`, preserving your existing user ID and Fernet key:

   ```dotenv
   AIRFLOW__CORE__LOAD_EXAMPLES=False
   ```

2. In `docker-compose.yaml`, replace the hardcoded `AIRFLOW__CORE__LOAD_EXAMPLES: 'true'` in the shared Airflow environment with:

   ```yaml
   AIRFLOW__CORE__LOAD_EXAMPLES: ${AIRFLOW__CORE__LOAD_EXAMPLES:-false}
   ```

   The explicit Compose environment setting overrides `.env`, so both changes are needed for an unmodified template. `make setup` applies the Compose change automatically, and `make up` sets the `.env` value to `false`. For a new manual setup, complete these steps before initializing the database.

3. For an existing setup, stop the stack and delete the database volume to clear previously loaded examples. **This deletes all Airflow metadata, including run history, stored connections, and custom user accounts.** Local files in `dags`, `logs`, `plugins`, and `config` remain.

   ```bash
   docker compose down --volumes
   docker compose run --rm airflow-init
   ```

   Wait for initialization to finish successfully. It recreates the configured default account (`airflow` / `airflow` unless overridden).

4. Start Airflow again and check service health:

   ```bash
   docker compose up --detach
   docker compose ps
   ```

   Open <http://localhost:8080>. Example DAGs should be absent; any custom DAGs in `./dags` will still appear.

## Management

| Action | Command |
| --- | --- |
| Check status | `docker compose ps` |
| Stop services and retain database data | `docker compose down` |
| Reset the database and remove service images | `docker compose down --volumes --rmi all` |

The reset command deletes the PostgreSQL volume; local DAGs, logs, plugins, and configuration directories remain.

For custom Python dependencies, extend the Airflow image with a `Dockerfile` and `requirements.txt`, configure `build: .` in Compose, and rebuild with `docker compose build`.

## Authoring the lab

Each chapter lives in a root directory such as `ch3_first_dag`, with a chapter `README.md`. Each lesson lives one level below it, such as `ch3_first_dag/03_02_write/README.md`, with its own README. Edit these outlines directly as the lab develops and update the table of contents when adding or renaming lessons.

Use the separate [Author.makefile](Author.makefile) for README maintenance. It requires Aspell with Markdown mode and an English dictionary for spell checking, and Docker for footer generation.

| Command | Action |
| --- | --- |
| `make --file Author.makefile` | Show authoring help |
| `make --file Author.makefile spellcheck` | Interactively spell-check every README |
| `make --file Author.makefile footer` | Pull and run the README footer generator |
| `make --file Author.makefile all` | Spell-check, then generate footers |

README discovery includes the root README and chapter and lesson READMEs, excluding `.git`. Spell checking is interactive and can edit files. The footer generator mounts the repository at `/data` and writes navigation links to the READMEs; review its changes before committing. These authoring commands are separate from the lab environment Makefile.
