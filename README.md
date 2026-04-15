# HestiaCP Monitor App - by JAMP

![Flutter](https://img.shields.io/badge/Made_with-Flutter-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android-green.svg)

A modern, fast, and secure native Android application to monitor and manage your Hestia Control Panel servers on the go.

## ✨ Features

* **Multi-Server Support:** Manage multiple VPS/Dedicated servers from a single dashboard.
* **Live Statistics:** Monitor CPU, RAM, Disk usage, and Load Averages in real-time.
* **Service Management:** View the status of core services (Nginx, Apache, PHP, MySQL) and restart them directly from your phone.
* **Domains & Mail:** Quickly check your configured web domains and mail domains.
* **Biometric Security:** The app can be locked using your device's Fingerprint/FaceID or PIN for maximum security.
* **SSL Support:** Compatible with self-signed certificates and custom HestiaCP ports.

## 🚀 How to Connect Your Server

To ensure maximum security, this app **does not** ask for your root SSH passwords. Instead, it uses cryptographic API tokens.

**Step 1: Install the API Addon on your server**
You must install the server-side API bridge on your HestiaCP server. 
👉 **[Click here to get the HestiaCP API Addon & Installation Instructions](https://github.com/jampwebsolutions/hestiacp-api-addon)**

**Step 2: Add to App**
Once the script finishes, it will provide a **Server URL** and a **Secret Key**. Simply open the app, tap the "+" button, and paste those details!

## 🛠️ Build it yourself (For Developers)

If you want to compile the APK yourself using Flutter:

```bash
# Clone the repository
git clone https://github.com/jampwebsolutions/hestiacp_monitor.git

# Navigate to the folder
cd hestiacp_monitor

# Get dependencies
flutter pub get

# Build the Android APK
flutter build apk --release
```

## 🛡️ Security Disclaimer
This app is provided "as is". While it uses cryptographic signing (SHA-256) and secure on-device storage for all credentials, always ensure your server's firewall is correctly configured.

Designed & Developed by JAMP Web Solutions