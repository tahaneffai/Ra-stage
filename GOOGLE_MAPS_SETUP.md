# Google Maps API Setup Guide

## 🗺️ **Google Maps Configuration**

### **For Development (Current Setup)**
The app is currently configured to use a **fallback mode** for development, which provides all functionality without requiring Google Maps API keys. This approach:

- ✅ **Works immediately** without API key setup
- ✅ **Provides all features** (search, filter, phone calls, details)
- ✅ **Modern UI** with beautiful station cards
- ✅ **No API restrictions** or billing concerns
- ✅ **Perfect for demos** and development

### **For Production**

#### **1. Get a Google Maps API Key**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - **Maps JavaScript API**
   - **Places API** (for location search)
   - **Geocoding API** (for address conversion)

#### **2. Create API Key**

1. Go to **Credentials** in the Google Cloud Console
2. Click **"Create Credentials"** → **"API Key"**
3. Copy the generated API key

#### **3. Configure API Key**

Replace the API key in `web/index.html`:

```html
<!-- Replace YOUR_API_KEY with your actual API key -->
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>
```

#### **4. Restrict API Key (Recommended)**

1. In Google Cloud Console, click on your API key
2. Under **"Application restrictions"**, select **"HTTP referrers"**
3. Add your domain(s):
   - `localhost:port/*` (for development)
   - `yourdomain.com/*` (for production)

#### **5. Enable Billing**

Google Maps API requires billing to be enabled:
1. Go to **Billing** in Google Cloud Console
2. Link a billing account to your project
3. Google provides $200 free credit monthly

### **API Usage Limits**

- **Maps JavaScript API**: 28,500 free requests/month
- **Places API**: 1,000 free requests/month
- **Geocoding API**: 2,500 free requests/month

### **Troubleshooting**

#### **"Cannot read properties of undefined (reading 'maps')"**
- Ensure Google Maps JavaScript API is enabled
- Check that the API key is valid
- Verify the script is loaded before Flutter initialization

#### **"Google Maps API error: RefererNotAllowedMapError"**
- Add your domain to the API key restrictions
- For development, add `localhost:*`

#### **"Google Maps API error: ApiNotActivatedMapError"**
- Enable the Maps JavaScript API in Google Cloud Console

### **Alternative: Use Fallback Mode**

If Google Maps API is not available, the app includes a fallback mode that displays stations as a list with full functionality.

### **Environment Variables (Optional)**

For better security, you can use environment variables:

1. Create a `.env` file in the project root
2. Add: `GOOGLE_MAPS_API_KEY=your_api_key_here`
3. Update the HTML to use a placeholder that gets replaced during build

### **Testing**

After setup, test the map functionality:
1. Run `flutter run -d chrome`
2. Navigate to the Map screen
3. Verify markers appear and are clickable
4. Test the BottomSheet functionality

---

**Note**: The current development setup should work for testing purposes. For production deployment, follow the steps above to get your own API key. 