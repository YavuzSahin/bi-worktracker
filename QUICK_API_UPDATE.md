# BI WorkTracker - Quick API URL Update Guide

## 🔧 **How to Update API URL**

### **Step 1: Find Your Backend URL**
After deploying your backend, you'll get a URL like:
- `https://remote-worktracker.replit.app` (Replit deployment)
- `https://your-custom-domain.com` (Custom domain)

### **Step 2: Update Flutter App**
Open `lib/main.dart` and find line ~48:

```dart
// UPDATE THIS URL TO MATCH YOUR DEPLOYED BACKEND
static const String baseUrl = 'https://remote-worktracker.replit.app';
```

Replace with your actual backend URL.

### **Step 3: Test Connection**
Before building the app, test your API:
```bash
curl -X POST https://YOUR-BACKEND-URL/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Should return:
```json
{
  "user": {...},
  "token": "...",
  "message": "Login successful"
}
```

### **Step 4: Build App**
```bash
flutter clean
flutter pub get
flutter build appbundle --release  # Android
flutter build ios --release        # iOS
```

## ⚡ **Quick Deploy Checklist**

- [ ] Backend deployed and accessible
- [ ] API endpoints responding correctly
- [ ] Flutter app URL updated
- [ ] Demo accounts working (admin/admin123, ahmed/123456)
- [ ] App built for production

## 🔍 **Troubleshooting**

### **"Connection refused" errors:**
- Check if backend is deployed and running
- Verify the URL is accessible in browser
- Test API endpoints manually

### **"Invalid credentials" errors:**
- Backend is working but demo accounts might not be initialized
- Check backend logs for database connection issues

### **CORS errors:**
- Backend needs proper CORS configuration for mobile apps
- Usually auto-configured in production deployments

Your BI WorkTracker app will work perfectly once the backend URL is correctly configured!