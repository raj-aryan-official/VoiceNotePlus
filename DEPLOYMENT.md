# 🚀 Voice Notes Plus - Deploy to Vercel

## Quick Deploy Guide (5 Minutes)

### Step 1: Build Flutter Web Release

```bash
cd c:\Users\rajar\OneDrive\Desktop\projectflutter\Voice-notes-plus

flutter clean
flutter pub get
flutter build web --release
```

Wait for the build to complete. You should see "✓ Built build/web" message.

---

### Step 2: Push Code to GitHub

The repo is already at: https://github.com/raj-aryan-official/VoiceNotePlus.git

Just commit and push your changes:

```bash
git add .
git commit -m "Add deployment configuration"
git push origin main
```

---

### Step 3: Deploy Using Vercel CLI (Easiest)

#### 3.1 Install Vercel CLI (one-time)

```bash
npm install -g vercel
```

#### 3.2 Login to Vercel

```bash
vercel login
```

Follow browser prompts to authenticate with GitHub.

#### 3.3 Deploy to Production

```bash
vercel --prod
```

When prompted:
- **"Set up and deploy?"** → Type `y` and press Enter
- **"Which scope?"** → Select your account
- **"Link to existing project?"** → Type `n` and press Enter (first time)
- **"What's your project's name?"** → Type `voice-notes-plus`
- **"In which directory is your code?"** → Press Enter (accept default `.`)
- **"Auto-detected project settings for web"** → Press Enter to continue

#### 3.4 Wait for Deployment

Vercel will:
1. Install Flutter SDK automatically
2. Run your build command
3. Deploy to CDN

You'll see:
```
✓ Production: https://voice-notes-plus.vercel.app
```

**That's your live app URL! 🎉**

---

## Alternative: Deploy via Vercel Dashboard (GitHub Integration)

### Step 1: Go to Vercel Dashboard

Visit: https://vercel.com/dashboard

### Step 2: Click "New Project"

### Step 3: Select GitHub Repository

1. Click "Import Git Repository"
2. Paste: `https://github.com/raj-aryan-official/VoiceNotePlus.git`
3. Click "Import"

### Step 4: Configure (Should be Auto-Detected)

Vercel will auto-detect from `vercel.json`:
- **Build Command:** `flutter build web --release` ✓
- **Output Directory:** `build/web` ✓

### Step 5: Deploy

Click "Deploy" button and wait 2-3 minutes.

---

## Test Your Deployed App

### After Deployment:

1. **Visit your URL:** https://voice-notes-plus.vercel.app
2. **Test Recording:** Tap microphone and speak
3. **Test Search:** Search for notes
4. **Test Like/Unlike:** Click heart icon
5. **Test Edit:** Edit title and content
6. **Test Delete:** Delete a note

### Check for Errors:

Open DevTools (F12):
- Console tab - check for JavaScript errors
- Network tab - check for failed requests
- Application tab - check IndexedDB storage

---

## Continuous Deployment (Auto-Deploy)

After first deployment, every time you push to GitHub, Vercel automatically redeploys:

```bash
# Make changes to your code
git add .
git commit -m "Your changes"
git push origin main
```

Vercel automatically detects the push and redeploys! ✓

---

## Troubleshooting

### ❌ Build Fails: "flutter: command not found"

**Solution:** The `vercel.json` file tells Vercel where to find Flutter. Make sure it's in project root.

Check if file exists:
```bash
dir vercel.json
```

If missing, see "Files Created" section below.

---

### ❌ App Shows Blank Page

**Solution:** Check browser console (F12 → Console tab):
- Look for red error messages
- Common issues:
  - Missing `index.html`
  - JavaScript errors in `main.dart.js`
  - SPA routing not configured

The `vercel.json` includes SPA routing fix, so this shouldn't happen.

---

### ❌ Microphone Not Working

**Solution:** 
- On localhost (development): Microphone may not work - use HTTPS
- On Vercel: Should work (HTTPS by default)
- Check browser microphone permissions in site settings
- Restart browser and allow permissions when prompted

---

### ❌ Cannot Find `build/web`

**Solution:** Make sure you ran the build command:

```bash
flutter clean
flutter pub get
flutter build web --release
```

Verify build succeeded:
```bash
dir build\web\index.html
```

If this file doesn't exist, build failed. Check terminal output for errors.

---

### ❌ Vercel Shows "No Build Output"

**Solution:** 
1. Check `vercel.json` exists in project root
2. Check `outputDirectory` is set to `build/web`
3. Run build locally to verify it works
4. Check Vercel build logs for errors

---

## Files Created for Deployment

| File | Location | Purpose |
|------|----------|---------|
| `vercel.json` | Project Root | Build config & routing |
| `.vercelignore` | Project Root | Ignore unnecessary files |
| `DEPLOYMENT.md` | Project Root | This guide |

**None of your lib/ files were changed!** ✓

---

## Performance Tips

### 1. Enable Caching (Already in vercel.json)

Static assets are cached for 1 year, HTML is not cached.

### 2. Monitor Performance

In Vercel dashboard:
- Go to your project
- Click "Analytics" tab
- View Web Vitals and Core Web Performance metrics

### 3. Check Bundle Size

```bash
# Build and check size
flutter build web --release
dir build\web\assets\
```

---

## Custom Domain (Optional)

### Add Custom Domain to Vercel:

1. In Vercel dashboard, click your project
2. Go to "Settings" → "Domains"
3. Add your domain (e.g., `voicenotes.com`)
4. Follow DNS instructions from your domain provider

Your app will be available at: `https://voicenotes.com`

---

## Environment Variables (For Future)

If you need to add API keys later:

```bash
vercel env add MY_API_KEY
# Enter your secret when prompted
```

In your Dart code:
```dart
String apiKey = String.fromEnvironment('MY_API_KEY');
```

---

## Rollback to Previous Version

If something goes wrong after deployment:

1. Go to Vercel dashboard
2. Click "Deployments" tab
3. Find the previous working deployment
4. Click the "..." menu
5. Select "Promote to Production"

Your previous version is now live again!

---

## Support Resources

- 📖 Flutter Web: https://flutter.dev/docs/get-started/web
- 📖 Vercel Docs: https://vercel.com/docs
- 🆘 Vercel Support: https://vercel.com/support
- 💬 GitHub Discussions: https://github.com/raj-aryan-official/VoiceNotePlus/discussions

---

## Summary

✅ Build Flutter web release
✅ Push to GitHub
✅ Run `vercel --prod`
✅ App is live! 🎉

That's all you need to do!

Your Voice Notes Plus app is now deployed on the internet and accessible to everyone!

---

**Questions?** Check the troubleshooting section or visit vercel.com/support
