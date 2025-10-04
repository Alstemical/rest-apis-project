# Asynchronous E-commerce API (Flask, PostgreSQL, RQ/Redis)

| Status: Complete | Framework: Python 3.x / Flask | Database: PostgreSQL |
| :--- | :--- | :--- |

This is a production-ready **RESTful API** designed for E-commerce or complex inventory management, enabling $\text{CRUD}$ operations on **Stores, Items, and Tags**. The architecture is built on the $\text{Flask}$ Application Factory Pattern and utilizes **Redis/RQ for asynchronous background processing**, demonstrating mastery of database management, advanced authentication, and external service integration (Mailgun).

## Key Technical Features

### 1. Advanced Architecture & Concurrency

* **Asynchronous Task Queue (RQ/Redis):** Implemented $\text{RQ}$ and $\text{Redis}$ to offload non-critical, time-consuming operations (like new user signup email notifications via Mailgun) to a background worker. This ensures the main $\text{API}$ threads remain fast and highly responsive.
* **Application Factory Pattern:** Uses a dynamic `create_app()` function for flexible configuration, dependency injection, and standardized testing.
* **Deployment Ready:** Configured for a production environment using the $\text{WSGI}$ server **Gunicorn**.

### 2. Database & Data Modeling

* **PostgreSQL with SQLAlchemy:** Uses $\text{PostgreSQL}$ as the robust production database, managed via the $\text{SQLAlchemy}$ $\text{ORM}$ for efficient, secure data interaction.
* **Schema Migration:** Implemented $\text{Flask-Migrate}$ to manage database schema evolution safely and professionally.
* **Data Structure:** Models include $\text{One-to-Many}$ (Store-to-Item) and $\text{Many-to-Many}$ (Item-to-Tag) relationships for complex querying.

### 3. Authentication & Security

* **Token-Based Security:** Implements $\text{JSON}$ Web Tokens ($\text{JWTs}$) using `flask-jwt-extended` for state-less, secure authentication.
* **Comprehensive Error Handling:** Features robust handlers for every $\text{JWT}$ failure scenario:
    * `expired_token_loader`
    * `revoked_token_loader` (using a central `BLOCKLIST`)
    * `needs_fresh_token_loader` (for sensitive operations)
    * `additional_claims_loader` (for role-based authorization like "is\_admin").
* **Secure Password Hashing:** Utilizes **Passlib** for secure, salted password hashing before storage.

### 4. API Design & Documentation

* **RESTful Blueprinting:** Uses **`flask-smorest`** to structure the $\text{API}$ into logical $\text{Blueprints}$ (Item, Store, User, Tag) for clean $\text{RESTful}$ design.
* **Self-Documenting:** Configured for automatic $\text{OpenAPI}$ specification generation and display via $\text{Swagger UI}$.

---

## 🛠️ Setup and Usage

### Prerequisites

* Python 3.x
* **PostgreSQL** Database (Locally or remote instance)
* **Redis** Server (For the $\text{RQ}$ worker)
* Mailgun Account (for email sending functionality)

### Installation

1.  Clone the repository and create a virtual environment.
2.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
3.  Set environment variables (`.env` file) for `DATABASE_URL`, `REDIS_URL`, and $\text{JWT}$ configuration.
4.  Run database migration to create tables:
    ```bash
    flask db upgrade
    ```

### Running the Application

1.  **Start Redis Server:** Ensure Redis is running locally.
2.  **Start the RQ Worker:** In a separate terminal, start the background worker:
    ```bash
    rq worker emails
    ```
3.  **Start the API Server (Development):**
    ```bash
    flask run
    ```
4.  **View Documentation:** The interactive $\text{Swagger UI}$ documentation is available at the root $\text{URL}$.