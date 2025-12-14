#!/bin/bash

# Structure Project - Complete Setup Script
# This script sets up database, backend, and prepares Flutter app

set -e  # Exit on error

echo "🚀 Starting Structure Project Setup..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}⚠️  This script needs sudo access for MariaDB setup${NC}"
    echo "Please run: sudo ./setup_complete.sh"
    exit 1
fi

ACTUAL_USER=${SUDO_USER:-$USER}
PROJECT_DIR="/home/$ACTUAL_USER/Projects/Japhet"

echo -e "${BLUE}📁 Project directory: $PROJECT_DIR${NC}"
echo ""

# Step 1: Setup MariaDB Database
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Step 1: Setting up MariaDB Database${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

echo "🔧 Creating database..."
mariadb -u root -e "DROP DATABASE IF EXISTS structure_backend;" 2>/dev/null || true
mariadb -u root -e "CREATE DATABASE structure_backend CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo -e "${GREEN}✅ Database 'structure_backend' created${NC}"

echo "📥 Importing schema and data..."
mariadb -u root structure_backend < "$PROJECT_DIR/structure_backend.sql"
echo -e "${GREEN}✅ Database schema imported${NC}"

echo "👤 Verifying admin user..."
ADMIN_CHECK=$(mariadb -u root -se "USE structure_backend; SELECT COUNT(*) FROM users WHERE role = 'SUPER_ADMIN';")
if [ "$ADMIN_CHECK" -gt 0 ]; then
    echo -e "${GREEN}✅ Admin user exists${NC}"
    mariadb -u root -e "USE structure_backend; SELECT email, role FROM users WHERE role = 'SUPER_ADMIN';"
else
    echo -e "${RED}❌ Admin user not found!${NC}"
fi

echo ""

# Step 2: Get Machine IP
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Step 2: Network Configuration${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

# Try to get the primary IP address
MACHINE_IP=$(hostname -I | awk '{print $1}')
if [ -z "$MACHINE_IP" ]; then
    MACHINE_IP="localhost"
fi

echo -e "${GREEN}🌐 Your machine IP: $MACHINE_IP${NC}"
echo -e "${YELLOW}Note: For mobile device testing, use: $MACHINE_IP${NC}"
echo -e "${YELLOW}      For emulator, use: 10.0.2.2${NC}"
echo ""

# Step 3: Update Flutter Backend URLs
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Step 3: Updating Flutter Backend URLs${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

echo "📝 Updating backend URLs to: $MACHINE_IP..."

# Update payment_service.dart
if [ -f "$PROJECT_DIR/structure/lib/features/payment/services/payment_service.dart" ]; then
    chown $ACTUAL_USER:$ACTUAL_USER "$PROJECT_DIR/structure/lib/features/payment/services/payment_service.dart"
    sed -i "s/192\.168\.1\.179/$MACHINE_IP/g" "$PROJECT_DIR/structure/lib/features/payment/services/payment_service.dart"
    echo -e "${GREEN}✅ Updated payment_service.dart${NC}"
fi

# Update auth_provider.dart
if [ -f "$PROJECT_DIR/structure/lib/features/auth/providers/auth_provider.dart" ]; then
    chown $ACTUAL_USER:$ACTUAL_USER "$PROJECT_DIR/structure/lib/features/auth/providers/auth_provider.dart"
    sed -i "s/192\.168\.1\.179/$MACHINE_IP/g" "$PROJECT_DIR/structure/lib/features/auth/providers/auth_provider.dart"
    echo -e "${GREEN}✅ Updated auth_provider.dart${NC}"
fi

# Update payments_tab.dart
if [ -f "$PROJECT_DIR/structure/lib/features/admin/widgets/payments_tab.dart" ]; then
    chown $ACTUAL_USER:$ACTUAL_USER "$PROJECT_DIR/structure/lib/features/admin/widgets/payments_tab.dart"
    sed -i "s/192\.168\.1\.179/$MACHINE_IP/g" "$PROJECT_DIR/structure/lib/features/admin/widgets/payments_tab.dart"
    echo -e "${GREEN}✅ Updated payments_tab.dart${NC}"
fi

echo ""

# Step 4: Check Java
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Step 4: Checking Java Installation${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo -e "${GREEN}✅ Java found: $JAVA_VERSION${NC}"
else
    echo -e "${RED}❌ Java not found! Please install Java 17+${NC}"
    echo "Install with: sudo apt install openjdk-17-jdk"
fi

echo ""

# Step 5: Check Flutter
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Step 5: Checking Flutter Installation${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo -e "${GREEN}✅ Flutter found: $FLUTTER_VERSION${NC}"
    
    echo "📦 Installing Flutter dependencies..."
    cd "$PROJECT_DIR/structure"
    sudo -u $ACTUAL_USER flutter pub get
    echo -e "${GREEN}✅ Flutter dependencies installed${NC}"
else
    echo -e "${RED}❌ Flutter not found! Please install Flutter SDK${NC}"
    echo "Visit: https://docs.flutter.dev/get-started/install"
fi

echo ""

# Step 6: Check ADB and connected devices
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Step 6: Checking Mobile Devices${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

if command -v adb &> /dev/null; then
    echo "📱 Checking connected devices..."
    sudo -u $ACTUAL_USER adb devices
    DEVICE_COUNT=$(sudo -u $ACTUAL_USER adb devices | grep -v "List" | grep "device" | wc -l)
    if [ "$DEVICE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Found $DEVICE_COUNT connected device(s)${NC}"
    else
        echo -e "${YELLOW}⚠️  No devices connected${NC}"
        echo "Connect your device via USB or start an emulator"
    fi
else
    echo -e "${YELLOW}⚠️  ADB not found (needed for physical devices)${NC}"
fi

echo ""

# Summary
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  ✨ Setup Complete! Next Steps:${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}1. Start Backend:${NC}"
echo "   cd $PROJECT_DIR/structure_backend"
echo "   ./mvnw spring-boot:run"
echo ""
echo -e "${GREEN}2. Run Flutter App (in new terminal):${NC}"
echo "   cd $PROJECT_DIR/structure"
echo "   flutter run"
echo ""
echo -e "${GREEN}3. Login Credentials:${NC}"
echo "   Email: admin@example.com"
echo "   Password: admin123"
echo ""
echo -e "${YELLOW}📱 For Physical Device:${NC}"
echo "   - Backend will be at: http://$MACHINE_IP:8080"
echo "   - Make sure device is on same WiFi network"
echo ""
echo -e "${YELLOW}📱 For Android Emulator:${NC}"
echo "   - Backend will be at: http://10.0.2.2:8080"
echo "   - (Already configured if you selected emulator option)"
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Create quick start scripts
echo "📝 Creating quick start scripts..."

cat > "$PROJECT_DIR/start_backend.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/structure_backend"
echo "🚀 Starting backend server..."
./mvnw spring-boot:run
EOF

cat > "$PROJECT_DIR/start_app.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/structure"
echo "📱 Starting Flutter app..."
flutter run
EOF

chmod +x "$PROJECT_DIR/start_backend.sh"
chmod +x "$PROJECT_DIR/start_app.sh"
chown $ACTUAL_USER:$ACTUAL_USER "$PROJECT_DIR/start_backend.sh"
chown $ACTUAL_USER:$ACTUAL_USER "$PROJECT_DIR/start_app.sh"

echo -e "${GREEN}✅ Created start_backend.sh and start_app.sh${NC}"
echo ""
echo -e "${GREEN}🎉 All done! Happy coding!${NC}"
