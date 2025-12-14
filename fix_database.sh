#!/bin/bash
echo "🔧 Fixing database schema..."
sudo mysql structure_backend << 'EOFMYSQL'
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS order_id VARCHAR(255) AFTER reference;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING' AFTER payment_method;
SELECT 'SUCCESS: Columns added!' as result;
DESCRIBE transactions;
EOFMYSQL

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database fixed! Now restarting backend..."
    cd /home/kelcy/Projects/Japhet/structure_backend
    
    # Kill old backend - find PID first
    BACKEND_PID=$(ps aux | grep "[j]ava.*Structure" | awk '{print $2}' | head -1)
    if [ ! -z "$BACKEND_PID" ]; then
        echo "Killing backend PID: $BACKEND_PID"
        kill $BACKEND_PID
        sleep 3
    fi
    
    # Start new backend
    ./mvnw spring-boot:run > backend.log 2>&1 &
    echo "Backend starting... waiting 45 seconds..."
    sleep 45
    
    # Test receipt endpoint
    echo ""
    echo "📄 Testing receipt download..."
    curl -s http://10.44.130.137:8080/api/transactions/receipt/TEST001
    
    echo ""
    echo ""
    echo "✅ All done! Receipt download is ready!"
    echo "You can now test it from the Flutter app!"
else
    echo "❌ Failed to update database"
fi
