# Admin API (Financial Dashboard Backend)

A Ruby on Rails 7 REST API backend that manages daily financial data and generates ECharts options configurations for the frontend dashboard. 

The application facilitates JWT-based secure user authentication, manages daily financial reports (`POS Revenue`, `EatClub Revenue`, and `Labour Cost`), and aggregates these metrics into rich datasets optimized for chart visualization.

---

## 🚀 Key Features

*   **Secure Authentication**: JWT-based session tokens using `bcrypt` and custom payload encryption.
*   **Daily Finance Reports CRUD**: Manage daily financial records with validated metrics (`pos_revenue`, `eatclub_revenue`, `labour_cost`).
*   **Analytics & Reporting Engine**: Generates dashboard-ready ECharts configurations (line, bar, pie charts) directly from backend aggregations.
*   **Comparison Analytics**: Support for comparing metrics with prior periods (e.g., this week vs. last week, this month vs. last month) with dynamic date range resolving.
*   **Containerized Environment**: Production-ready docker configuration.

---

## 🛠️ Technology Stack

*   **Core**: Ruby 3.1.0, Rails 7.1.6 (API mode)
*   **Database**: PostgreSQL
*   **Authentication**: JWT (JSON Web Tokens) & BCrypt
*   **Testing**: RSpec, FactoryBot, Faker
*   **Development Tools**: dotenv-rails, puma, bootsnap, debug/byebug

---

## 🏗️ Architecture (Modular Monolith)

This project is built using a **Modular Monolith** architectural pattern to ensure clean boundaries between different domain contexts. The design principles and constraints are defined in rules/backend-architecture.md

### High-Level Design
* **Bounded Contexts**: Business domains are separated into modules inside `app/modules/<module_name>/` (for example, the reports analytics module is located at app/modules/reports).
* **Persistence & Models**: Active Record models reside in the standard Rails location (app/models/) and are shared across contexts to allow standard migrations and persistence.

---

## 📡 API Endpoints

### 🔐 Authentication
*   `POST /api/v1/auth/register` - Create a new user account.
*   `POST /api/v1/auth/login` - Authenticate and receive a JWT access token.

### 📊 Daily Finance Reports
*   `GET /api/v1/reports/daily_finance_reports` - List daily reports.
*   `POST /api/v1/reports/daily_finance_reports` - Create a daily report entry.
*   `PUT /api/v1/reports/daily_finance_reports/:id` - Update an existing report entry.
*   `DELETE /api/v1/reports/daily_finance_reports/:id` - Remove a report entry.

### 📈 Dashboard Analytics
*   `GET /api/v1/reports/finance_reports` - Get ECharts dashboard configuration.
    *   **Query Params**:
        *   `date_range_mode`: `this_week`, `this_month`, `this_year` (default: `this_week`)
        *   `value_types`: Comma-separated list (e.g. `pos_revenue,labour_cost`)
        *   `compare_with_previous`: Boolean to include comparisons.

---

## ⚙️ Getting Started

### Prerequisites

*   **Ruby**: 3.1.0
*   **PostgreSQL** (running locally or accessible via URL)

### 1. Install Dependencies
```bash
bundle install
```

### 2. Configure Environment Variables
Copy or create `.env.development` and `.env.test` in the project root:

```bash
# Example .env.development
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/admin_api_development
```

### 3. Setup Database
Create the database, run migrations, and seed sample daily reports spanning the last 3 months:
```bash
bundle exec rails db:setup
```

### 4. Running the Server
Start the Rails server on the default port (3000):
```bash
bundle exec rails server
```

---

## 🧪 Testing

Run the test suite via RSpec:
```bash
bundle exec rspec
```

---

## 🐳 Docker & Cloud Deployment

### Local Docker Build
The project includes a production-ready multi-stage `Dockerfile`. To build and run locally:
```bash
docker build -t admin-api .
docker run -p 3000:3000 --env-file .env.production admin-api
```

### Deploying to Render
This repository includes a [render.yaml](file:///Users/nhan/works/admin_api/render.yaml) Blueprint configuration for quick deployment to **Render**.

1. Connect your GitHub repository to your Render account.
2. Click **New +** on the Render dashboard and choose **Blueprint**.
3. Connect this repository. Render will automatically detect `render.yaml` and configure:
   * A managed PostgreSQL database (`admin-api-db`).
   * A web service running the Rails API using the `Dockerfile`.
4. Render will prompt you for the `RAILS_MASTER_KEY` environment variable. Paste the contents of your local `config/master.key` file.
5. Click **Apply**. Render will build the Docker container, run database migrations automatically via `db:prepare` in the entrypoint, and launch the service.
