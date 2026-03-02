# 🚀 CampusBites — Render.com Deployment Guide

Ninte CampusBites app Render.com-il deploy cheyyaan ulla step-by-step guide aanu ithu.

---

## Step 1: GitHub-lekk Code Push Cheyyuka

Aadhyam code GitHub-il upload cheyyaNam. Terminal-il ee commands run cheyyuka:

```bash
cd "c:\Project\canteen_project 2"
git init
git add .
git commit -m "Initial commit - CampusBites ready for deployment"
```

Ennitt GitHub.com-il poyitt oru **puthiya repository** undaakkuka (name: `campusbites`).
Repository undaakkiyathinnu shesham:

```bash
git remote add origin https://github.com/YOUR_USERNAME/campusbites.git
git branch -M main
git push -u origin main
```

> ⚠️ `YOUR_USERNAME` maattuka ninte actual GitHub username-lekk!

---

## Step 2: Render.com-il Login Cheyyuka

1. [render.com](https://render.com/) poyitt **GitHub account** vech login cheyyuka
2. Free plan mathiyaakunnu

---

## Step 3: PostgreSQL Database Create Cheyyuka

1. Render Dashboard-il **"New +"** button click cheyyuka
2. **"PostgreSQL"** select cheyyuka
3. Settings:
   - **Name**: `campusbites-db`
   - **Region**: Default mathi
   - **Plan**: Free
4. **"Create Database"** click cheyyuka
5. Database create aayal, **"Internal Database URL"** copy cheyyuka — ithu pinne veNam!

---

## Step 4: Web Service Create Cheyyuka

1. **"New +"** → **"Web Service"** click cheyyuka
2. Ninte GitHub repo (`campusbites`) connect cheyyuka
3. Ee details kodukuka:

| Setting | Value |
|---------|-------|
| **Name** | `campusbites` |
| **Region** | Default |
| **Branch** | `main` |
| **Runtime** | `Python 3` |
| **Build Command** | `./build.sh` |
| **Start Command** | `gunicorn canteen.wsgi` |
| **Plan** | Free |

---

## Step 5: Environment Variables Set Cheyyuka ⚡

Ithaan ettavum important step! **"Environment"** tab-il poyitt ee variables add cheyyuka:

| Variable | Value |
|----------|-------|
| `PYTHON_VERSION` | `3.12` |
| `SECRET_KEY` | Oru valiya random string (e.g., `django-insecure-xxxx...`) |
| `DEBUG` | `False` |
| `DATABASE_URL` | Step 3-il copy cheytha **Internal Database URL** paste cheyyuka |
| `RENDER` | `true` |
| `ALLOWED_HOSTS` | `campusbites.onrender.com` (ninte actual domain) |

### Optional (features work aakaan):

| Variable | Value |
|----------|-------|
| `EMAIL_HOST` | `smtp.gmail.com` |
| `EMAIL_PORT` | `587` |
| `EMAIL_USE_TLS` | `True` |
| `EMAIL_HOST_USER` | Ninte Gmail |
| `EMAIL_HOST_PASSWORD` | App password |
| `DEFAULT_FROM_EMAIL` | Ninte Gmail |
| `STRIPE_PUBLISHABLE_KEY` | Ninte Stripe key |
| `STRIPE_SECRET_KEY` | Ninte Stripe secret |
| `FIREBASE_API_KEY` | Ninte Firebase key |
| `FIREBASE_AUTH_DOMAIN` | Ninte Firebase domain |
| `FIREBASE_PROJECT_ID` | Ninte Firebase project ID |

---

## Step 6: Deploy! 🎉

**"Create Web Service"** button click cheyyuka!

Render automatic-aayi:
1. `requirements.txt` install cheyyum
2. `build.sh` run cheyyum (collectstatic + migrate)
3. `gunicorn canteen.wsgi` start cheyyum

Kuracchu samayam kazhinjaal **"Live" 🟢** kaaNaam!

Ninte site: **`https://campusbites.onrender.com`**

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Build failed | Render logs check cheyyuka — usually dependency issue |
| Static files kaaNunnilla | `build.sh`-il `collectstatic` undo ennu check cheyyuka |
| Database error | `DATABASE_URL` correct aano ennu nokkuka |
| CSRF error | `ALLOWED_HOSTS`-il ninte domain add cheytho ennu check cheyyuka |
| 500 error | `DEBUG=True` aakkittu deploy cheyyuka kuracchu neram, error kaaNaam |

---

Enthenkkilum doubt undenkil chodikku! 💪
