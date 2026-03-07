# 🏗️ CampusBites — System Design Document

> **Project:** CampusBites – Smart College Canteen Management System  
> **Version:** 1.0  
> **Date:** March 2026  
> **Technology:** Django 6.0 (Python), MySQL / PostgreSQL, Stripe, WebSockets  
> **Live URL:** https://campusbites-yps6.onrender.com

---

## 1. Introduction

### 1.1 Purpose
CampusBites is a full-stack web application that digitizes and automates the food ordering process in a college canteen. It replaces manual counter queues with an online ordering platform that supports real-time order tracking, multiple payment methods, and role-based dashboards.

### 1.2 Scope
The system covers:
- **Student/Teacher** — Browse menu, place orders, track status, pay online/wallet/cash, review food items
- **Kitchen Staff** — View incoming orders, update preparation status, sales analytics
- **Admin** — Manage menu, users, orders, feedback, system settings, and view analytics
- **Chatbot** — AI-powered rule-based assistant for quick queries

### 1.3 Key Features
| Feature | Description |
|---|---|
| 🍔 Digital Menu | Category-based menu with search, filters, veg/non-veg tags, today's specials |
| 🛒 Cart & Checkout | Session-based cart with delivery options (counter, classroom, staffroom) |
| 💳 Multi-Payment | Cash, UPI, Wallet, Stripe (online card payments) |
| 📦 Order Tracking | Real-time status via WebSockets + QR code tokens |
| 👨‍🍳 Kitchen Dashboard | Live order queue with sales analytics |
| 📊 Admin Dashboard | Revenue charts, user management, order export (CSV) |
| 🤖 Chatbot | Rule-based assistant for menu, orders, and canteen info |
| 🔐 Security | OTP login, OAuth (Google/Facebook), rate-limiting, CSRF, session hardening |
| 💰 Digital Wallet | In-app wallet with top-up and transaction history |
| ⭐ Reviews & Favorites | Per-item ratings, comments, and favorites list |

---

## 2. System Architecture

### 2.1 High-Level Architecture Diagram

```mermaid
graph TB
    subgraph Client["🖥️ Client Layer"]
        Browser["Web Browser (HTML/CSS/JS)"]
        WS["WebSocket Client"]
    end

    subgraph Server["⚙️ Application Server"]
        Django["Django 6.0 (WSGI)"]
        Daphne["Daphne (ASGI/WebSockets)"]
        Channels["Django Channels"]
    end

    subgraph Apps["📦 Django Apps"]
        Accounts["accounts"]
        Menu["menu"]
        Orders["orders"]
        Payments["payments"]
        Chatbot["chatbot"]
    end

    subgraph External["☁️ External Services"]
        Stripe["Stripe Payment Gateway"]
        Google["Google OAuth"]
        Facebook["Facebook OAuth"]
        Firebase["Firebase (Phone Auth)"]
        SMTP["SMTP Email Server"]
    end

    subgraph Data["🗄️ Data Layer"]
        DB["MySQL (Local) / PostgreSQL (Production)"]
        Sessions["Django Sessions"]
        Media["Media Storage (Uploaded Images)"]
    end

    Browser -->|HTTP/HTTPS| Django
    WS -->|WebSocket| Daphne
    Daphne --> Channels
    Django --> Apps
    Channels --> Orders
    Channels --> Menu
    Payments -->|API| Stripe
    Accounts -->|OAuth| Google
    Accounts -->|OAuth| Facebook
    Accounts -->|Phone OTP| Firebase
    Accounts -->|Email OTP| SMTP
    Apps --> DB
    Apps --> Sessions
    Apps --> Media
```

### 2.2 Architecture Pattern
- **Pattern:** Monolithic MVC (MTV in Django terminology)
- **Frontend:** Server-rendered templates (Django Templates) + AJAX for dynamic features
- **Backend:** Django 6.0 with function-based views
- **Real-time:** Django Channels + Daphne (ASGI) for WebSocket communication
- **Deployment:** Render.com with Gunicorn (HTTP) + WhiteNoise (static files)

### 2.3 Technology Stack

| Layer | Technology |
|---|---|
| Language | Python 3.12 |
| Framework | Django 6.0 |
| ASGI Server | Daphne 4.2 |
| WSGI Server | Gunicorn 23.0 |
| Database (Dev) | MySQL 8.x |
| Database (Prod) | PostgreSQL (via `dj-database-url`) |
| Static Files | WhiteNoise |
| Payments | Stripe Checkout API |
| OAuth | django-allauth (Google, Facebook) |
| Phone Auth | Firebase Authentication (Pyrebase) |
| Real-time | Django Channels (InMemoryChannelLayer) |
| Rate Limiting | django-axes |
| Admin UI | django-jazzmin |
| QR Codes | python-qrcode |
| Deployment | Render.com |

---

## 3. Module Design

### 3.1 Module Overview

```mermaid
graph LR
    subgraph Core["Core (canteen/)"]
        Settings["settings.py"]
        URLs["urls.py"]
        ASGI["asgi.py"]
    end

    subgraph Acc["accounts"]
        Auth["Authentication"]
        Profile["User Profiles"]
        AdminPanel["Custom Admin Panel"]
        Kitchen["Kitchen Dashboard"]
    end

    subgraph MenuApp["menu"]
        Browse["Menu Browsing"]
        Search["Search API"]
        ReviewMod["Reviews & Ratings"]
        Fav["Favorites"]
    end

    subgraph Ord["orders"]
        Cart["Session Cart"]
        Checkout["Checkout Flow"]
        Track["Order Tracking"]
        QR["QR Token"]
    end

    subgraph Pay["payments"]
        Cash["Cash Payment"]
        Wallet["Wallet System"]
        StripeInt["Stripe Integration"]
        Webhook["Stripe Webhook"]
    end

    subgraph Bot["chatbot"]
        RuleEngine["Rule Engine"]
        ChatAPI["Chat API"]
    end

    Core --> Acc
    Core --> MenuApp
    Core --> Ord
    Core --> Pay
    Core --> Bot
    Ord --> Pay
    Ord --> MenuApp
    Bot --> MenuApp
    Bot --> Ord
```

### 3.2 Module Details

#### 📁 `accounts` — Authentication & User Management
| Component | Description |
|---|---|
| `views.py` | Registration (with college ID validation), login (username/email), phone OTP login, email OTP verification, password reset (OTP-based), profile management, account deactivation |
| `admin_views.py` | Custom admin dashboard: overview stats, order management, menu CRUD, user management, feedback handling, system settings, analytics charts (JSON API), CSV export |
| `models.py` | `UserProfile` (roles: student/teacher/admin/kitchen, wallet), `ValidStudent`/`ValidStaff` (whitelist), `SystemSettings` (singleton config), `Feedback` (with status workflow) |
| `email_otp.py` | Email OTP generation and verification |
| `phone_auth.py` | Firebase phone authentication integration |
| `adapters.py` | Custom social account adapter for Google/Facebook OAuth |

#### 📁 `menu` — Menu & Food Item Management
| Component | Description |
|---|---|
| `views.py` | Menu listing (category filter, search, veg filter, pagination), item detail, review CRUD, favorites toggle, real-time availability API, fuzzy search API |
| `models.py` | `Category`, `MenuItem` (with availability, veg tag, specials, prep time), `Review` (1-5 star + comment), `Favorite` |
| `consumers.py` | WebSocket consumer for live menu availability updates |
| `services.py` | Business logic services for menu operations |

#### 📁 `orders` — Cart & Order Processing
| Component | Description |
|---|---|
| `views.py` | Session-based cart (add/remove/update/clear), checkout (delivery type selection), order placement, order history with pagination, order detail with QR code, cancel with wallet refund, reorder |
| `models.py` | `Order` (state machine with valid transitions), `OrderItem` |
| `consumers.py` | WebSocket consumer for real-time order status updates |
| `signals.py` | Post-save signal for order status change notifications |
| `utils.py` | Utility functions for order processing |

#### 📁 `payments` — Payment Processing
| Component | Description |
|---|---|
| `views.py` | Payment page (method selection), cash payment, wallet payment (atomic transactions), Stripe Checkout session creation, Stripe success callback, Stripe webhook handler, wallet top-up, payment status API |
| `models.py` | `Payment` (with audit fields, refund tracking), `WalletTransaction` (credit/debit ledger) |

#### 📁 `chatbot` — AI Assistant
| Component | Description |
|---|---|
| `views.py` | Chat API endpoint (POST JSON → response + quick replies) |
| `rules.py` | Comprehensive rule engine (~36KB) with intent matching for menu queries, order status, wallet info, canteen hours, specials, and more |

---

## 4. Data Model Design

### 4.1 Entity Relationship Diagram

```mermaid
erDiagram
    User ||--|| UserProfile : "has"
    User ||--o{ Order : "places"
    User ||--o{ Review : "writes"
    User ||--o{ Favorite : "saves"
    User ||--o{ Feedback : "submits"
    User ||--o{ WalletTransaction : "has"

    Category ||--o{ MenuItem : "contains"
    MenuItem ||--o{ Review : "has"
    MenuItem ||--o{ Favorite : "in"
    MenuItem ||--o{ OrderItem : "ordered as"

    Order ||--o{ OrderItem : "contains"
    Order ||--o{ Payment : "paid by"

    UserProfile {
        string role "student/teacher/admin/kitchen"
        string full_name
        string phone
        string college_id
        decimal wallet_balance
    }

    ValidStudent {
        string register_no "Unique whitelist ID"
        bool is_registered
    }

    ValidStaff {
        string staff_id "Unique whitelist ID"
        bool is_registered
    }

    SystemSettings {
        decimal delivery_fee
        string upi_id
        bool maintenance_mode
    }

    Category {
        string name
        string description
        image image
        bool is_active
    }

    MenuItem {
        string name
        decimal price
        int preparation_time
        bool is_available
        bool is_todays_special
        bool is_vegetarian
    }

    Review {
        int rating "1-5 stars"
        string comment
        string admin_response
    }

    Order {
        string token_number "TKN-ABC123"
        string status "State machine"
        string payment_method
        bool is_paid
        decimal total_amount
        string delivery_type
        string delivery_location
        decimal delivery_fee
        datetime scheduled_for
    }

    OrderItem {
        string item_name
        decimal price
        int quantity
    }

    Payment {
        decimal amount
        string method
        string status
        string transaction_id
        string stripe_session_id
        string ip_address
        string failure_reason
        json gateway_response
        bool is_refunded
    }

    WalletTransaction {
        decimal amount
        string transaction_type "credit/debit"
        string description
        string reference_id
    }

    Feedback {
        string subject
        string message
        int rating "1-5"
        string status "open/in_progress/resolved"
        string admin_response
    }
```

### 4.2 Database Indexes
| Model | Index | Purpose |
|---|---|---|
| `MenuItem` | `is_available` | Fast filter for available items |
| `MenuItem` | `category + is_available` | Category-based menu queries |
| `MenuItem` | `is_todays_special` | Today's specials listing |
| `Order` | `status` | Dashboard order filtering |
| `Order` | `created_at` | Chronological ordering |
| `Order` | `user + status` | User's order history |
| `Order` | `status + created_at` | Admin order analytics |

---

## 5. Order State Machine

```mermaid
stateDiagram-v2
    [*] --> payment_pending : Order Created
    payment_pending --> pending : Cash Payment
    payment_pending --> confirmed : Online/Wallet Payment
    payment_pending --> cancelled : User Cancels

    pending --> confirmed : Admin Confirms
    pending --> cancelled : Admin/User Cancels

    confirmed --> preparing : Kitchen Accepts
    preparing --> ready : Food Prepared
    preparing --> cancelled : Emergency Cancel

    ready --> out_for_delivery : Delivery Order
    ready --> collected : Counter Pickup

    out_for_delivery --> delivered : Delivered

    delivered --> [*]
    collected --> [*]
    cancelled --> [*]
```

| From | Allowed Transitions |
|---|---|
| `payment_pending` | `pending`, `confirmed`, `cancelled` |
| `pending` | `confirmed`, `cancelled` |
| `confirmed` | `preparing`, `cancelled` |
| `preparing` | `ready`, `cancelled` |
| `ready` | `out_for_delivery`, `collected` |
| `out_for_delivery` | `delivered` |
| `delivered` | — (terminal) |
| `collected` | — (terminal) |
| `cancelled` | — (terminal) |

---

## 6. Payment Flow

### 6.1 Payment Methods

```mermaid
flowchart TD
    Start["User at Checkout"] --> Select{"Select Payment"}

    Select -->|Cash| Cash["Mark as Pending<br>Pay at Counter"]
    Select -->|Wallet| WalletCheck{"Balance >= Total?"}
    Select -->|Online| Stripe["Create Stripe Session"]

    WalletCheck -->|Yes| Debit["Atomic: Debit Wallet<br>+ Create Payment<br>+ Mark Paid"]
    WalletCheck -->|No| Fail["Insufficient Balance"]

    Stripe --> Redirect["Redirect to Stripe Checkout"]
    Redirect --> Success["stripe_success callback"]
    Redirect --> Webhook["stripe_webhook (backup)"]
    Success --> Verify["Verify session.payment_status == paid"]
    Webhook --> Verify
    Verify --> Confirm["Mark Order Confirmed + Paid"]

    Cash --> Done["Order Created"]
    Debit --> Done
    Confirm --> Done
    Fail --> Start
```

### 6.2 Wallet System
- **Max Balance:** ₹10,000
- **Max Single Top-up:** ₹5,000
- **Min Top-up:** ₹10
- **Ledger:** Every transaction recorded in `WalletTransaction` (credit/debit with description)
- **Refund:** Automatic wallet credit on order cancellation (atomic transaction)

---

## 7. Authentication & Security

### 7.1 Authentication Methods

```mermaid
flowchart LR
    Auth["Authentication"] --> UP["Username/Password"]
    Auth --> Phone["Phone OTP (Firebase)"]
    Auth --> OAuth["Social OAuth"]
    Auth --> Email["Email + OTP Verification"]

    OAuth --> Google["Google"]
    OAuth --> Facebook["Facebook"]

    UP --> Validate["Validate College ID<br>(ValidStudent/ValidStaff)"]
    Phone --> FireVerify["Firebase ID Token → Django User"]
```

### 7.2 Security Features

| Feature | Implementation |
|---|---|
| **Rate Limiting** | django-axes: 5 failed attempts → 1 hour lockout |
| **CSRF Protection** | Django CSRF middleware + trusted origins |
| **Session Hardening** | HttpOnly cookies, SameSite=Lax, 24hr expiry, extend on activity |
| **Password Validation** | Min 8 chars, not common, not numeric-only, not similar to user info |
| **SSL/TLS** | Enforced in production (Render proxy handles SSL) |
| **XSS Protection** | Secure browser headers (X-Frame-Options: DENY, X-Content-Type-Options) |
| **College ID Whitelist** | Only pre-approved register numbers can sign up |
| **OTP Password Reset** | 6-digit OTP via email with cooldown protection |

### 7.3 Role-Based Access

```mermaid
graph TD
    Roles["User Roles"] --> Student["Student"]
    Roles --> Teacher["Teacher"]
    Roles --> KitchenStaff["Kitchen Staff"]
    Roles --> Admin["Admin"]

    Student --> SM["Menu, Cart, Orders, Wallet, Reviews, Feedback, Chatbot"]
    Teacher --> TM["Same as Student + Staffroom Delivery"]
    KitchenStaff --> KM["Kitchen Dashboard, Order Status Updates, Sales Analytics"]
    Admin --> AM["Everything + Admin Dashboard:<br>Menu CRUD, User Mgmt, Order Mgmt,<br>Feedback, Settings, Analytics, CSV Export"]
```

---

## 8. API Endpoints

### 8.1 Public / Auth Pages
| Method | Endpoint | Description |
|---|---|---|
| GET/POST | `/register/` | User registration with college ID |
| GET/POST | `/login/` | Username/email login |
| GET | `/logout/` | User logout |
| GET/POST | `/phone-login/` | Phone OTP login page |
| POST | `/phone-verify/` | Verify Firebase token |
| GET/POST | `/forgot-password/` | Password reset (OTP) |

### 8.2 Menu
| Method | Endpoint | Description |
|---|---|---|
| GET | `/menu/` | Menu listing with filters |
| GET | `/menu/<id>/` | Item detail with reviews |
| POST | `/menu/<id>/review/` | Add/update review |
| POST | `/menu/<id>/favorite/` | Toggle favorite |
| GET | `/api/menu-availability/` | Realtime item availability (JSON) |
| GET | `/api/search/?q=` | Fuzzy search API (JSON) |

### 8.3 Cart & Orders
| Method | Endpoint | Description |
|---|---|---|
| GET | `/cart/` | View cart |
| POST | `/cart/add/<id>/` | Add item to cart |
| POST | `/cart/remove/<id>/` | Remove item |
| POST | `/cart/update/<id>/` | Update quantity |
| POST | `/cart/clear/` | Clear all items |
| GET | `/checkout/` | Checkout page |
| POST | `/place-order/` | Create order |
| GET | `/orders/` | Order history |
| GET | `/order/<id>/` | Order detail + QR code |
| POST | `/order/<id>/cancel/` | Cancel order |
| POST | `/order/<id>/reorder/` | Re-add to cart |

### 8.4 Payments
| Method | Endpoint | Description |
|---|---|---|
| GET | `/payment/<order_id>/` | Payment method selection |
| POST | `/payment/<order_id>/cash/` | Process cash payment |
| POST | `/payment/<order_id>/wallet/` | Process wallet payment |
| POST | `/payment/<order_id>/online/` | Create Stripe session |
| GET | `/payment/<order_id>/stripe/success/` | Stripe success callback |
| POST | `/stripe/webhook/` | Stripe webhook (backup) |
| GET | `/wallet/` | Wallet dashboard |
| POST | `/wallet/add/` | Top-up wallet |
| GET | `/api/payment/<id>/status/` | Payment status poll (JSON) |

### 8.5 Admin Dashboard (JSON APIs)
| Method | Endpoint | Description |
|---|---|---|
| GET | `/admin-dashboard/` | Admin overview |
| GET | `/admin-dashboard/api/stats/` | Dashboard stats (AJAX) |
| GET | `/admin-dashboard/api/chart-data/` | Revenue/order charts |
| GET | `/admin-dashboard/api/orders/` | Orders table (AJAX) |
| POST | `/admin-dashboard/api/users/` | User role/status management |
| GET | `/admin-dashboard/orders/export/` | CSV export |

### 8.6 Chatbot
| Method | Endpoint | Description |
|---|---|---|
| POST | `/chatbot/chat/` | Send message → get response + quick replies |

---

## 9. Real-Time Communication

### 9.1 WebSocket Architecture

```mermaid
sequenceDiagram
    participant Browser
    participant Daphne
    participant Channels
    participant OrderConsumer
    participant MenuConsumer

    Browser->>Daphne: WebSocket Connect
    Daphne->>Channels: Route to Consumer
    Channels->>OrderConsumer: ws/orders/
    Channels->>MenuConsumer: ws/menu/

    Note over OrderConsumer: Kitchen updates order status
    OrderConsumer->>Browser: {"status": "ready", "token": "TKN-ABC123"}

    Note over MenuConsumer: Admin toggles item availability
    MenuConsumer->>Browser: {"item_id": 5, "is_available": false}
```

### 9.2 WebSocket Endpoints
| Path | Consumer | Purpose |
|---|---|---|
| `ws/orders/` | `OrderConsumer` | Real-time order status updates |
| `ws/menu/` | `MenuConsumer` | Live menu availability changes |

- **Channel Layer:** InMemoryChannelLayer (suitable for single-server deployment)

---

## 10. Deployment Architecture

```mermaid
graph TB
    subgraph Internet
        User["👤 User Browser"]
    end

    subgraph Render["Render.com"]
        LB["Load Balancer / SSL Proxy"]
        Web["Web Service<br>(Gunicorn + Django)"]
        PG["PostgreSQL Database<br>(Managed)"]
    end

    subgraph Build["Build Process"]
        Git["GitHub Repository"]
        BuildScript["build.sh<br>pip install, collectstatic, migrate"]
    end

    User -->|HTTPS| LB
    LB --> Web
    Web --> PG
    Git -->|Auto Deploy| BuildScript
    BuildScript --> Web

    Web -->|Static| WhiteNoise["WhiteNoise<br>(Compressed Static Files)"]
    Web -->|Stripe API| StripeExt["Stripe"]
    Web -->|OAuth| GoogleExt["Google/Facebook"]
    Web -->|Email| SMTPExt["SMTP Server"]
```

### 10.1 Environment Variables
| Variable | Purpose |
|---|---|
| `SECRET_KEY` | Django secret key |
| `DEBUG` | Debug mode (False in production) |
| `DATABASE_URL` | PostgreSQL connection string |
| `STRIPE_PUBLISHABLE_KEY` | Stripe frontend key |
| `STRIPE_SECRET_KEY` | Stripe backend key |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signature |
| `EMAIL_HOST` / `EMAIL_HOST_USER` / `EMAIL_HOST_PASSWORD` | SMTP credentials |
| `FIREBASE_API_KEY` / `FIREBASE_AUTH_DOMAIN` | Firebase phone auth config |

---

## 11. Non-Functional Requirements

| Requirement | Implementation |
|---|---|
| **Performance** | DB indexes on hot columns, WhiteNoise compressed static, session-based cart (no DB writes for cart) |
| **Scalability** | Stateless app server (can scale horizontally on Render), PostgreSQL handles concurrent connections |
| **Reliability** | Stripe webhook as backup for payment confirmation, atomic transactions for wallet operations |
| **Security** | OWASP best practices: CSRF, XSS, clickjacking, rate-limiting, session hardening |
| **Availability** | Render.com auto-restart on failure, health checks |
| **Maintainability** | Modular Django apps, state-machine pattern for orders/feedback, singleton for settings |

---

## 12. Future Enhancements

| Enhancement | Description |
|---|---|
| 🔔 Push Notifications | FCM/Web Push for order-ready alerts |
| 📱 Mobile App | React Native or Flutter frontend |
| 🤖 AI Chatbot | Replace rule engine with LLM (GPT/Gemini) |
| 📈 ML Recommendations | Personalized menu suggestions based on order history |
| 🏪 Multi-Canteen | Support multiple canteens on one campus |
| ⏰ Pre-Order Scheduling | Enhanced scheduled ordering with time-slot management |
| 🔄 Redis Channel Layer | Replace InMemoryChannelLayer for multi-server WebSockets |
| 📊 Advanced Analytics | Heatmaps, demand forecasting, waste reduction metrics |

---

*Document generated from codebase analysis — CampusBites v1.0*
