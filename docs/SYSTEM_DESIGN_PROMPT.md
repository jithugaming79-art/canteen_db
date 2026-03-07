# PROMPT — System Design Chapter for CampusBites

Copy the entire prompt below and paste it into ChatGPT / Gemini / any AI tool:

---

Write a complete **System Design chapter (Chapter 3)** for my college project report titled **"CampusBites – Smart College Canteen Management System"**. Built using Django (Python), MySQL/PostgreSQL, Stripe, Django Channels (WebSockets), Firebase Phone Auth, Google/Facebook OAuth.

The system has **3 external entities (actors): User (Student/Teacher), Admin, and Kitchen Staff.**

Follow the **exact same format** as a standard academic system design chapter with DFD diagrams and ER diagrams. Use formal academic language. Draw all diagrams using **proper DFD notation** — ovals/circles for processes, rectangles for external entities, open-ended rectangles (parallel lines) for data stores, and arrows with labeled data flows.

---

## DATA STORES:

- D1: LOGIN — username, password, successfully logged in / incorrect username/password
- D2: USERS — id, username, email, full_name, phone, college_id, role, wallet_balance
- D3: VALID_STUDENT — register_no, is_registered
- D4: VALID_STAFF — staff_id, is_registered
- D5: CATEGORY — id, name, description, image, is_active
- D6: MENU_ITEM — id, name, category, description, price, image, preparation_time, is_available, is_todays_special, is_vegetarian
- D7: REVIEW — id, user_id, menu_item_id, rating (1-5), comment, admin_response, created_at
- D8: FAVORITE — id, user_id, menu_item_id, created_at
- D9: ORDER — id, user_id, token_number, status, payment_method, is_paid, total_amount, delivery_type, delivery_location, delivery_fee, special_instructions, created_at
- D10: ORDER_ITEM — id, order_id, menu_item_id, item_name, price, quantity
- D11: PAYMENT — id, order_id, amount, method, status, transaction_id, stripe_session_id, ip_address, failure_reason, is_refunded
- D12: WALLET_TRANSACTION — id, user_id, amount, transaction_type (credit/debit), description, reference_id
- D13: FEEDBACK — id, user_id, subject, message, rating, status (open/in_progress/resolved), admin_response
- D14: SYSTEM_SETTINGS — delivery_fee, upi_id, maintenance_mode
- D15: FOOD_CART — session-based (item_id, quantity, item_name, price)

---

## GENERATE THESE EXACT SECTIONS:

### 3.1 Introduction (1 page)
- What is system design
- Why it is important in software development life cycle
- Translating functional/non-functional requirements into blueprints

### 3.2 Context Flow Diagram (1 page)
- Definition of Context Diagram
- **Draw Context Diagram** with:
  - Central process circle: **CampusBites Canteen Management System**
  - External Entity: **User** — arrows: Register/Login, Browse Menu/Place Order/Make Payment (going in), Order Status/Receive Receipt (going out)
  - External Entity: **Admin** — arrows: Manage Menu/Manage Users/Manage Settings (going in), View Analytics/View Orders (going out)
  - External Entity: **Kitchen Staff** — arrows: Update Order Status (going in), View Orders/View Profile (going out)

### 3.3 Data Flow Diagram (1 page)
- Full explanation of what DFD is
- Elements: external entities, processes, data stores, data flows
- DFD levels (Level 0 = Context, Level 1, Level 2)
- Advantages of DFD

### 3.4 Rules Regarding DFD Construction (0.5 page)
- Bullet list: start high-level, define external entities clearly, use consistent symbols, label data flows, avoid control flow, decompose gradually, ensure balancing between levels

### 3.5 DFD Symbols (1 page)
- Table with columns: Name | Notation (draw symbol) | Description
- Rows: Process (oval/circle), Datastore (parallel lines), Dataflows (arrows), External Entity (rectangle)

---

### 3.6 DFD Level 1 (Admin) — Full Page Diagram
**Draw a large DFD Level 1 diagram** for ADMIN with these processes and data stores, all connected with labeled data flow arrows:

- ADMIN (external entity) connects to all processes below:
- **LOGIN** → D1: LOGIN (username, password → successfully logged in/incorrect)
- **VIEW RATINGS** → D7: REVIEW (date, review, rating → successfully displayed/failed)
- **VIEW USERS** → D2: USERS (id, username, email, phone → successfully displayed/failed)
- **VIEW FEEDBACK AND SEND REPLY** → D13: FEEDBACK (date, complaint, reply, reply_date → successfully received)
- **SYSTEM SETTINGS MANAGEMENT** → D14: SYSTEM_SETTINGS (delivery_fee, upi_id, maintenance_mode → successfully recorded/failed)
- **MENU ITEM MANAGEMENT** → D6: MENU_ITEM (id, name, price, category, is_available → successfully recorded/failed)
- **CATEGORY MANAGEMENT** → D5: CATEGORY (id, name, description, image → successfully recorded/failed)
- **VIEW REVIEW ABOUT FOOD** → D7: REVIEW (id, date, review, rating, admin_response → successfully displayed/failed)
- **VIEW ORDER AND VERIFY** → D9: ORDER (id, date, time, status, total_amount → successfully displayed and verified/rejected)
- **VIEW ORDER AND UPDATE STATUS** → D9: ORDER + D10: ORDER_ITEM (displayed successfully)
- **VIEW PAYMENT** → D11: PAYMENT (id, date, status, amount, payment_method → successfully displayed/failed)
- **USER MANAGEMENT** → D2: USERS (id, username, role, is_active → successfully recorded/failed)
- **EXPORT ORDERS CSV** → D9: ORDER (order data → CSV file)
- **VIEW ANALYTICS CHARTS** → D9: ORDER + D11: PAYMENT (revenue, order count → chart data)
- **CHANGE PASSWORD** → D1: LOGIN (password → successfully changed/failed)

---

### 3.6.1 DFD Level 2 (Login)
- ADMIN → LOGIN process → D1: LOGIN (username, password / successfully logged in / incorrect username/password)
- ADMIN → CHANGE PASSWORD process → D1: LOGIN (password / successfully password changed/failed)

### 3.6.2 DFD Level 2 (Menu Item Management)
- ADMIN → **Add** → D6: MENU_ITEM (id, name, price, category, image, is_available, is_vegetarian)
- ADMIN → **View** → D6: MENU_ITEM
- ADMIN → **Edit** → D6: MENU_ITEM
- ADMIN → **Delete** → D6: MENU_ITEM (deleted / successfully recorded/failed)
- ADMIN → **Toggle Availability** → D6: MENU_ITEM
- ADMIN → **Mark Today's Special** → D6: MENU_ITEM

### 3.6.3 DFD Level 2 (Category Management)
- ADMIN → **Add** → D5: CATEGORY (name, description, image, is_active)
- ADMIN → **View** → D5: CATEGORY
- ADMIN → **Edit** → D5: CATEGORY
- ADMIN → **Delete** → D5: CATEGORY (deleted / successfully recorded/failed)

### 3.6.4 DFD Level 2 (User Management)
- ADMIN → **View Users** → D2: USERS (id, username, email, phone, role)
- ADMIN → **Change Role** → D2: USERS (role → successfully updated/failed)
- ADMIN → **Activate/Deactivate** → D2: USERS (is_active → successfully updated/failed)

### 3.6.5 DFD Level 2 (System Settings Management)
- ADMIN → **View Settings** → D14: SYSTEM_SETTINGS
- ADMIN → **Update Settings** → D14: SYSTEM_SETTINGS (delivery_fee, upi_id, maintenance_mode → successfully updated/failed)

### 3.6.6 DFD Level 2 (View Payment)
- ADMIN → **View** → D11: PAYMENT (id, date, status, amount, payment_method → successfully displayed/failed)
- ADMIN → **Process Refund** → D11: PAYMENT (refunded → successfully recorded/failed)

### 3.6.7 DFD Level 2 (View Users)
- ADMIN → **VIEW USERS** → D2: USERS (id, username, email, phone → successfully displayed/failed)

### 3.6.8 DFD Level 2 (View Ratings)
- ADMIN → **VIEW RATINGS** → D7: REVIEW (date, review, rating → successfully displayed/failed)

### 3.6.9 DFD Level 2 (View Orders and Update Status)
- ADMIN → **VIEW ORDER AND VERIFY** process → D9: ORDER (id, date, time, status, total_amount → successfully displayed and verified/rejected)
- Connected to D10: ORDER_ITEM

### 3.6.10 DFD Level 2 (View Review about Food and Reply)
- ADMIN → **VIEW REVIEW ABOUT FOOD** → D7: REVIEW (id, date, review, menu_item_id → successfully displayed/failed)
- ADMIN → **SEND REPLY** → D7: REVIEW (admin_response → successfully sent)

### 3.6.11 DFD Level 2 (View Feedback and Send Reply)
- ADMIN → **VIEW FEEDBACK** → D13: FEEDBACK (date, complaint, reply, reply_date → successfully received)
- ADMIN → **SEND REPLY** → D13: FEEDBACK (admin_response → successfully sent)
- ADMIN → **UPDATE STATUS** → D13: FEEDBACK (status: open → in_progress → resolved)

### 3.6.12 DFD Level 2 (View Food Orders and Update Status)
- ADMIN → **VIEW FOOD ORDER AND UPDATE STATUS** → D9: ORDER (successfully displayed/failed)
- Connected to D10: ORDER_ITEM (displayed successfully)

### 3.6.13 DFD Level 2 (View Analytics)
- ADMIN → **VIEW ANALYTICS** → D9: ORDER + D11: PAYMENT (revenue data, order stats → chart data displayed)

---

### 3.7 DFD Level 1 (Kitchen Staff) — Full Page Diagram
**Draw a large DFD Level 1 diagram** for KITCHEN STAFF:

- KITCHEN STAFF (external entity) connects to:
- **LOGIN** → D1: LOGIN (username, password → successfully logged in / incorrect)
- **VIEW PROFILE** → D2: USERS (id, name, phone, role → successfully viewed/failed)
- **VIEW ORDER QUEUE** → D9: ORDER + D10: ORDER_ITEM (id, status, items, created_at → displayed)
- **UPDATE ORDER STATUS** → D9: ORDER (id, status → successfully status updated/failed) [confirmed → preparing → ready → collected/delivered]
- **VIEW SALES SUMMARY** → D9: ORDER + D11: PAYMENT (daily/weekly/monthly stats → successfully displayed)
- **CHANGE PASSWORD** → D1: LOGIN (password → successfully changed/failed)

### 3.7.1 DFD Level 2 (Login)
- KITCHEN STAFF → LOGIN → D1: LOGIN

### 3.7.2 DFD Level 2 (View Profile)
- KITCHEN STAFF → VIEW PROFILE → D2: USERS (id, name, phone, role → successfully viewed/failed)

### 3.7.3 DFD Level 2 (View Order Queue and Update Status)
- KITCHEN STAFF → **VIEW ORDER QUEUE** → D9: ORDER + D10: ORDER_ITEM
- KITCHEN STAFF → **UPDATE STATUS** → D9: ORDER (id, status → successfully status updated/failed)
- KITCHEN STAFF → **VIEW PREVIOUS ORDERS** → D9: ORDER

### 3.7.4 DFD Level 2 (View Sales Summary)
- KITCHEN STAFF → **VIEW SALES SUMMARY** → D9: ORDER + D11: PAYMENT (date range, daily/weekly/monthly → stats displayed)

---

### 3.8 DFD Level 1 (User) — Full Page Diagram
**Draw a large DFD Level 1 diagram** for USER (Student/Teacher):

- USER (external entity) connects to:
- **REGISTER** → D2: USERS (username, email, password → successfully registered / incorrect) + D3: VALID_STUDENT or D4: VALID_STAFF (validate college ID)
- **LOGIN** → D1: LOGIN (username, password → successfully logged in / incorrect)
- **VIEW MENU AND ADD TO CART** → D6: MENU_ITEM (id, name, price, image, is_available → successfully viewed/failed) + D15: FOOD_CART
- **VIEW ORDER STATUS** → D9: ORDER (date, time, status, total_amount → successfully viewed/failed)
- **MAKE PAYMENT** → D11: PAYMENT (id, date, status, amount, payment_method → paid / successfully sent/failed)
- **PLACE ORDER** → D9: ORDER + D10: ORDER_ITEM (token_number, items → order created)
- **VIEW ORDER HISTORY** → D9: ORDER (date, time, status, total_amount → displayed)
- **VIEW RATING ABOUT FOOD** → D7: REVIEW (id, date, review, rating → successfully displayed/failed)
- **SEND FEEDBACK** → D13: FEEDBACK (id, date, feedback → successfully sent/failed)
- **SEND COMPLAINT AND VIEW REPLIES** → D13: FEEDBACK (date, complaint, reply, reply_date → successfully received/sent)
- **ADD TO FOOD CART AND VIEW CART** → D15: FOOD_CART (menu_item_id, quantity, name → successfully added to cart/failed)
- **MANAGE WALLET** → D12: WALLET_TRANSACTION (amount, type → balance updated)
- **TOGGLE FAVORITE** → D8: FAVORITE (menu_item_id → added/removed)
- **CHANGE PASSWORD** → D1: LOGIN (password → successfully changed/failed)

### 3.8.1 DFD Level 2 (Login)
- USER → LOGIN → D1: LOGIN (username, password → successfully logged in / incorrect)
- USER → CHANGE PASSWORD → D1: LOGIN (password → successfully changed/failed)

### 3.8.2 DFD Level 2 (Register)
- USER → REGISTER → D2: USERS (username, email, password, college_id → successfully registered / incorrect)
- Connected to D3: VALID_STUDENT / D4: VALID_STAFF for college ID validation

### 3.8.3 DFD Level 2 (View Menu)
- USER → VIEW MENU → D6: MENU_ITEM (id, name, price, image, category, is_available → successfully viewed/failed)
- USER → SEARCH MENU → D6: MENU_ITEM (search query → results displayed)
- USER → VIEW TODAY'S SPECIALS → D6: MENU_ITEM (is_todays_special → displayed)

### 3.8.4 DFD Level 2 (Place Order / Cart)
- USER → ADD TO CART → D15: FOOD_CART (menu_item_id, quantity → added)
- USER → VIEW CART → D15: FOOD_CART (items, quantities, prices → displayed)
- USER → CHECKOUT AND PLACE ORDER → D9: ORDER + D10: ORDER_ITEM (delivery_type, delivery_location, items → order created with token TKN-XXX)

### 3.8.5 DFD Level 2 (Food Ordering Flow)
- USER → **VIEW MENU** → D6: MENU_ITEM (id, name, price, image, quantity)
- USER → **ADD TO CART** → D15: FOOD_CART (id, date, status → successfully added/failed)
- USER → **VIEW ORDER STATUS** → D9: ORDER (quantity, order details → successfully viewed/failed)

### 3.8.6 DFD Level 2 (Make Payment)
- USER → **MAKE PAYMENT** → D11: PAYMENT (id, date, status, amount, payment_method → paid / successfully sent/failed)
- Payment methods: Cash (pay at counter), Wallet (debit from D12: WALLET_TRANSACTION), Online Stripe (redirect to Stripe → success callback)

### 3.8.7 DFD Level 2 (View Rating about Food)
- USER → **VIEW RATING ABOUT FOOD** → D7: REVIEW (id, date, review, rating → successfully displayed/failed)
- USER → **ADD REVIEW** → D7: REVIEW (rating 1-5, comment → successfully submitted)

### 3.8.8 DFD Level 2 (Send Complaint/Feedback and View Replies)
- USER → **VIEW FEEDBACK** → D13: FEEDBACK (id, name → date, complaint, reply, reply_date / successfully received)
- USER → **SEND REPLY** → D13: FEEDBACK (successfully sent)

### 3.8.9 DFD Level 2 (Send Feedback)
- USER → **SEND FEEDBACK** → D13: FEEDBACK (id, date, feedback → successfully sent/failed)

### 3.8.10 DFD Level 2 (Wallet Management)
- USER → **VIEW WALLET BALANCE** → D2: USERS (wallet_balance → displayed)
- USER → **TOP UP WALLET** → D12: WALLET_TRANSACTION (amount, credit → balance updated)
- USER → **VIEW TRANSACTION HISTORY** → D12: WALLET_TRANSACTION (displayed)

### 3.8.11 DFD Level 2 (Chatbot)
- USER → **SEND MESSAGE** → CHATBOT RULE ENGINE (message → response + quick_replies)

---

### 3.9 Entity Relationship Diagram (2 pages)

#### 3.9.1 Data Objects
Explain what data objects are. List the data objects in CampusBites:
User, UserProfile, ValidStudent, ValidStaff, Category, MenuItem, Review, Favorite, Order, OrderItem, Payment, WalletTransaction, Feedback, SystemSettings

#### 3.9.2 Attributes
Explain what attributes are. Give examples from CampusBites:
- User: username, email, password, first_name, last_name
- MenuItem: name, price, description, is_available, is_vegetarian
- Order: token_number, status, total_amount, delivery_type

#### 3.9.3 Relationships
Explain relationships. List relationships in CampusBites:
- User HAS ONE UserProfile (1:1)
- User PLACES many Orders (1:M)
- User WRITES many Reviews (1:M)
- User HAS many Favorites (1:M)
- User SUBMITS many Feedbacks (1:M)
- User HAS many WalletTransactions (1:M)
- Category CONTAINS many MenuItems (1:M)
- MenuItem HAS many Reviews (1:M)
- MenuItem HAS many Favorites (1:M)
- MenuItem appears in many OrderItems (1:M)
- Order CONTAINS many OrderItems (1:M)
- Order HAS many Payments (1:M)
- Review belongs to one User AND one MenuItem (M:1, M:1)
- Each User can review each MenuItem only once (unique constraint)

#### 3.9.4 Cardinality
Explain cardinality (1:1, 1:M, M:1, M:M). Give examples:
- 1:1 → User to UserProfile
- 1:M → Category to MenuItem, User to Orders, Order to OrderItems
- M:1 → Review to User, Review to MenuItem
- 1:M → Order to Payment

#### 3.9.5 ER Symbols Table
Table with: Entity (rectangle), Attribute (ellipse), Relationship (diamond), Link (line), Key Attribute (underlined in ellipse), Multivalued Attribute (double ellipse), Derived Attribute (dashed ellipse), Cardinality Ratios (1:1, 1:M, M:1, M:M)

#### 3.9.6 ER Diagram — Full Page
**Draw the complete ER diagram** with all entities, attributes, relationships, and cardinalities:

**Entities and their attributes:**

**User** — id (PK), username, email, password, first_name, last_name, is_active
**UserProfile** — id (PK), user_id (FK), role, full_name, phone, college_id, wallet_balance
**ValidStudent** — id (PK), register_no, is_registered
**ValidStaff** — id (PK), staff_id, is_registered
**Category** — id (PK), name, description, image, is_active
**MenuItem** — id (PK), category_id (FK), name, description, price, image, preparation_time, is_available, is_todays_special, is_vegetarian
**Review** — id (PK), user_id (FK), menu_item_id (FK), rating, comment, admin_response
**Favorite** — id (PK), user_id (FK), menu_item_id (FK)
**Order** — id (PK), user_id (FK), token_number, status, payment_method, is_paid, total_amount, delivery_type, delivery_location, delivery_fee, special_instructions, scheduled_for
**OrderItem** — id (PK), order_id (FK), menu_item_id (FK), item_name, price, quantity
**Payment** — id (PK), order_id (FK), amount, method, status, transaction_id, stripe_session_id, ip_address, failure_reason, is_refunded
**WalletTransaction** — id (PK), user_id (FK), amount, transaction_type, description, reference_id
**Feedback** — id (PK), user_id (FK), subject, message, rating, status, admin_response
**SystemSettings** — id (PK), delivery_fee, upi_id, maintenance_mode

**Relationships:**
- User ——(1:1)—— has ——(1:1)—— UserProfile
- User ——(1)—— places ——(M)—— Order
- User ——(1)—— writes ——(M)—— Review
- User ——(1)—— saves ——(M)—— Favorite
- User ——(1)—— submits ——(M)—— Feedback
- User ——(1)—— has ——(M)—— WalletTransaction
- Category ——(1)—— contains ——(M)—— MenuItem
- MenuItem ——(1)—— has ——(M)—— Review
- MenuItem ——(1)—— has ——(M)—— Favorite
- MenuItem ——(1)—— ordered_as ——(M)—— OrderItem
- Order ——(1)—— contains ——(M)—— OrderItem
- Order ——(1)—— paid_by ——(M)—— Payment

---

## FORMATTING RULES:
1. Use **formal academic language** throughout
2. Use **proper DFD notation**: ovals for processes, rectangles for external entities, parallel lines for data stores, arrows for data flows
3. **Label ALL arrows** with the data being passed (e.g., "username, password", "id, name, price, quantity")
4. Show response arrows back (e.g., "successfully recorded/failed", "successfully displayed/failed")
5. Number all processes and data stores
6. For ER diagram: rectangles for entities, ellipses for attributes, diamonds for relationships, lines for links, underline key attributes
7. Total output: approximately **19-20 pages**
8. Each DFD Level 2 diagram should be on its own section with a clear heading
