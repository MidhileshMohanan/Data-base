# === Termux MQTT + Auto-Start Installer ===
echo "🔧 Setting up Mosquitto + Termux:Boot auto start..."

# Update & upgrade packages
pkg update -y && pkg upgrade -y

# Install dependencies
pkg install -y mosquitto nano

# Create Mosquitto config folder (if missing)
CONFIG_PATH="/data/data/com.termux/files/usr/etc/mosquitto/mosquitto.conf"
mkdir -p "$(dirname "$CONFIG_PATH")"

# Create Mosquitto config file
echo "allow_anonymous true" > "$CONFIG_PATH"
echo "listener 1883 0.0.0.0" >> "$CONFIG_PATH"
echo "✅ Mosquitto config created at: $CONFIG_PATH"

# Create Termux Boot folder
mkdir -p ~/.termux/boot

# Create Boot Script
BOOT_SCRIPT="$HOME/.termux/boot/start_mosquitto.sh"
cat > "$BOOT_SCRIPT" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# === Auto-start Mosquitto & Android Apps ===

# Kill existing Mosquitto process
pkill mosquitto

# Start Mosquitto broker
mosquitto -c "/data/data/com.termux/files/usr/etc/mosquitto/mosquitto.conf" &

# Wait for service to start
sleep 5

# Launch Android apps
am start -n com.example.ip_phone_display/.MainActivity  
#am start -n com.example.linphone2/.MainActivity

# Log start event
echo "$(date) : Mosquitto & apps started" >> /sdcard/termux_boot_log.txt
EOF

# Make boot script executable
chmod +x "$BOOT_SCRIPT"

# Test Mosquitto manually
echo "▶️ Testing Mosquitto service..."
pkill mosquitto
mosquitto -c "$CONFIG_PATH" &
sleep 3

# Log test result
if pgrep mosquitto > /dev/null; then
    echo "✅ Mosquitto started successfully!"
else
    echo "❌ Mosquitto failed to start, please check config."
fi

echo "✅ Boot script created at: $BOOT_SCRIPT"
echo "📦 Install Termux:Boot from F-Droid: https://f-droid.org/en/packages/com.termux.boot/"
echo "🔁 After installation, reboot your phone to auto-start Mosquitto and apps."
echo "✅ Setup complete!"

