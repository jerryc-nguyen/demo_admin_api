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

## 🐳 Docker Deployment

The project includes a production-ready multi-stage `Dockerfile`. To build and run:
```bash
docker build -t admin-api .
docker run -p 3000:3000 --env-file .env.production admin-api
```
