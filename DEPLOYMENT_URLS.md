# BI WorkTracker - Deployment URLs Configuration

## 🌐 **Current API Configuration**

### **Flutter App API Endpoint**
- **Current URL**: `https://remote-worktracker.replit.app`
- **Configured in**: `lib/main.dart` line 45
- **API Endpoints**:
  - Login: `https://remote-worktracker.replit.app/api/login`
  - Check-in: `https://remote-worktracker.replit.app/api/checkin`
  - Check-out: `https://remote-worktracker.replit.app/api/checkout`
  - Status: `https://remote-worktracker.replit.app/api/status`
  - Logs: `https://remote-worktracker.replit.app/api/logs`

### **Deployment Options**

#### **Option 1: Replit Deployment**
- Use Replit's built-in deployment feature
- URL format: `https://[repl-name].replit.app`
- Example: `https://remote-worktracker.replit.app`

#### **Option 2: Custom Domain**
- Deploy to your own domain
- Update `baseUrl` in Flutter app to your domain
- Example: `https://biworktracker.com`

### **How to Update API URL**

If you need to change the API endpoint:

1. **Edit Flutter App**:
   ```dart
   // In lib/main.dart, line 45
   static const String baseUrl = 'https://your-new-url.com';
   ```

2. **Rebuild Flutter App**:
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release  # For Android
   flutter build ios --release        # For iOS
   ```

### **Testing API Connection**

To test if the API is working:
```bash
curl -X POST https://remote-worktracker.replit.app/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### **Current Demo Accounts**
- **Admin**: username=`admin`, password=`admin123`
- **Employee**: username=`ahmed`, password=`123456`

## 🚀 **Deployment Steps**

1. **Deploy Backend**: Use Replit Deployments or custom hosting
2. **Update Flutter URL**: Match the deployed backend URL
3. **Test Connection**: Verify API endpoints work
4. **Build & Deploy**: Create production Flutter builds

Your BI WorkTracker Flutter app is now configured to connect to the specified API endpoint.