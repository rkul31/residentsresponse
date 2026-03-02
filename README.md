# Residents Response — Static Site Migration

Migrating [residentsresponse.com](https://www.residentsresponse.com) from Wix to **Cloudflare Pages + GitHub**.

## Why?

| Before (Wix)          | After (CF Pages)       |
| --------------------- | ---------------------- |
| ~£13–17/month         | **Free**               |
| Wix CDN               | Cloudflare global CDN  |
| Limited bandwidth     | Unlimited bandwidth    |
| Wix lock-in           | Standard HTML in Git   |
| GUI-only editing      | Edit anywhere          |

---

## Project Structure

```
residentsresponse-site/
├── scrape-assets.sh        ← Run this FIRST to download PDFs & images
├── README.md               ← You are here
└── site/                   ← This is the CF Pages root
    ├── index.html           ← Homepage with all updates
    ├── about.html           ← About page
    ├── media.html           ← Media coverage
    ├── fire-safety.html     ← Fire safety info
    ├── letter.html          ← Blog post (letter to council)
    ├── _redirects           ← Maps old Wix URLs → new paths
    ├── _headers             ← Caching & security headers
    ├── css/
    │   └── style.css        ← Single stylesheet
    ├── documents/           ← All PDFs go here (from scraper)
    └── images/              ← All images go here (from scraper)
```

---

## Step-by-Step Migration

### 1. Run the Asset Scraper

This downloads all PDFs and images from the current Wix site:

```bash
chmod +x scrape-assets.sh
./scrape-assets.sh
```

Then move the downloaded assets into the site:

```bash
mv assets/documents/* site/documents/
mv assets/images/* site/images/
```

**Manual step:** Rename the scraped image files to match the filenames
referenced in the HTML (see the `src` attributes in `about.html` and
`fire-safety.html`). The key images to rename:

- Cladding type chart → `affected-homes-cladding-type.png`
- Ward chart → `affected-homes-ward.png`
- April 2024 meeting photo → `meeting-april-2024.png`
- March 2024 meeting photo → `meeting-march-2024.png`
- Fire safety photo → `fire-safety-photo.jpg`

### 2. Create a GitHub Repository

```bash
cd residentsresponse-site
git init
git add .
git commit -m "Initial migration from Wix"
```

Then push to GitHub:

```bash
gh repo create residentsresponse --public --source=. --push
# OR manually create on github.com, then:
git remote add origin https://github.com/YOUR_USER/residentsresponse.git
git push -u origin main
```

### 3. Deploy to Cloudflare Pages

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com)
2. Navigate to **Workers & Pages** → **Create**
3. Select **Pages** → **Connect to Git**
4. Authorize GitHub and select the `residentsresponse` repo
5. Configure the build:
   - **Build command:** *(leave blank — no build needed)*
   - **Build output directory:** `site`
6. Click **Save and Deploy**

Your site will be live at `residentsresponse.pages.dev` within ~60 seconds.

### 4. Connect Your Custom Domain

1. In the CF Pages project, go to **Custom domains**
2. Add `www.residentsresponse.com` and `residentsresponse.com`
3. If your domain is already on Cloudflare DNS, the CNAME records are
   created automatically
4. If the domain is registered through Wix, you'll need to either:
   - **Option A:** Transfer the domain to Cloudflare Registrar (recommended,
     costs ~£8–10/year at-cost)
   - **Option B:** Update the DNS nameservers at Wix to point to Cloudflare

### 5. Verify Old URLs Still Work

The `_redirects` file maps old Wix URL paths (like `/my-blog`) to the new
filenames (like `/media.html`), so existing links and bookmarks won't break.

---

## How to Update the Site

### Adding a new update to the homepage

1. Open `site/index.html` in any text editor (or GitHub's web editor)
2. Find the comment `<!-- HOW TO ADD A NEW UPDATE -->`
3. Copy/paste a `<div class="update">` block and edit the date and text
4. If linking to a new PDF, drop the PDF file into `site/documents/`
5. Commit and push — Cloudflare auto-deploys in ~30 seconds

### Using GitHub's web editor (no coding tools needed)

1. Go to your repo on github.com
2. Click on `site/index.html`
3. Click the pencil icon (✏️) to edit
4. Make your changes
5. Click **Commit changes**
6. The site auto-deploys

---

## Optional: Add a CMS for Non-Technical Editors

If multiple people need to edit the site without touching HTML, consider
[Decap CMS](https://decapcms.org/) (free, open source). It gives you a
web-based admin panel that commits changes to your GitHub repo. This would
require converting the site to use a static site generator like Hugo or
11ty, but it's a good next step if needed.

---

## Cost Summary

| Item              | Monthly Cost |
| ----------------- | ------------ |
| Cloudflare Pages  | £0           |
| GitHub (free tier)| £0           |
| Domain renewal    | ~£0.80/month |
| **Total**         | **~£0.80/month** |

vs. Wix at £13–17+/month = **saving ~£150–200/year**.
