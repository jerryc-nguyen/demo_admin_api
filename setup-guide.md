# macOS Local Development Setup Guide

This guide walks you through setting up the `admin_api` development environment on a clean macOS machine from scratch.

---

## 🛠️ Step 1: System Prerequisites

We use **Homebrew** to manage packages and **Docker Desktop** to run the PostgreSQL database.

### 1. Install Homebrew
If you don't have Homebrew installed, run:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Docker Desktop
Install Docker using Homebrew Cask:
```bash
brew install --cask docker
```
*Note: Once installed, open **Docker Desktop** from your Applications folder and complete the initial setup to ensure the Docker daemon is running.*

---

## 💎 Step 2: Ruby & Bundler Environment

We use **rbenv** to manage Ruby versions and ensure we are running Ruby `3.1.0`.

### 1. Install rbenv
Install `rbenv` and `ruby-build`:
```bash
brew install rbenv ruby-build
```

### 2. Configure Shell Initialization
Configure your shell so that `rbenv` is loaded automatically.

**For Zsh (macOS Default):**
```bash
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

**For Bash:**
```bash
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
```

### 3. Install Ruby 3.1.0
Navigate to the project root directory and run:
```bash
rbenv install 3.1.0
rbenv local 3.1.0
```
Verify the active Ruby version matches:
```bash
ruby -v
# Output should indicate ruby 3.1.0
```

### 4. Install Bundler
Install the package manager utility:
```bash
gem install bundler
```

---

## 🐘 Step 3: Database Setup (PostgreSQL in Docker)

Instead of installing PostgreSQL natively, we run it inside a lightweight Docker container.

### 1. Run the PostgreSQL Container
Start a PostgreSQL 15 container. This exposes port `5432` with username `postgres` and password `postgres`:
```bash
docker run --name admin-db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_USER=postgres \
  -d postgres:15-alpine
```

### 2. Verify it is Running
Check the container status:
```bash
docker ps
```
You should see `admin-db` in the list with status `Up`.

---

## ⚙️ Step 4: Application Setup

### 1. Install Project Gems
Run Bundler to install the required gems:
```bash
bundle install
```

### 2. Configure Environment Variables
Copy the default environment configuration files:
```bash
cp .env.development.example .env.development
cp .env.test.example .env.test
```
*(If `.env.development` and `.env.test` already exist, verify that the `DATABASE_URL` matches your Docker setup credentials):*
```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/admin_api_development
```

### 3. Database Creation & Seeding
Create, migrate, and seed the database with sample financial records:
```bash
bundle exec rails db:setup
```
*This command runs `db:create`, `db:schema:load`, and `db:seed` (which generates 3 months of realistic business metrics with weekly seasonality).*

---

## 🧪 Step 5: Verification & Testing

### 1. Run the Server
Boot the development server:
```bash
bundle exec rails server
```
The server will start on [http://localhost:3000](http://localhost:3000). You can hit the health check endpoint to verify it is responsive:
```bash
curl http://localhost:3000/up
```

### 2. Run the Test Suite
Ensure the test environment is healthy and specs pass:
```bash
bundle exec rspec
```

---

## 🔍 Step 6: Troubleshooting

### 1. Port 5432 is Already in Use
If the `docker run` command fails because port `5432` is busy, a native instance of PostgreSQL might be running on your Mac.
*   **Fix**: Stop the local service using Homebrew:
    ```bash
    brew services stop postgresql
    # or stop specific versions, e.g.:
    brew services stop postgresql@14
    ```
    Alternatively, stop the native Postgres app if you are running Postgres.app.

### 2. Apple Silicon (M1/M2/M3) pg Gem Compilation Failure
If `bundle install` fails while compiling native extensions for the `pg` gem:
*   **Fix**: Install the PostgreSQL client libraries locally via Homebrew and configure bundler to point to them:
    ```bash
    brew install libpq
    bundle config build.pg --with-pg-config=$(brew --prefix libpq)/bin/pg_config
    bundle install
    ```
