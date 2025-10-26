# Phase 3: Connectivity Features - Complete Guide

**Status**: ⏳ **NOT STARTED** (0%)  
**Target**: Q4 2025  
**Priority**: Medium  
**Effort**: 10-12 weeks

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Cloud Integration](#cloud-integration)
3. [Mobile App Companion](#mobile-app-companion)
4. [Voice Assistant Ecosystem](#voice-assistant-ecosystem)
5. [5G/LTE Connectivity](#5glte-connectivity)
6. [Security & Privacy](#security--privacy)
7. [Setup & Configuration](#setup--configuration)
8. [API Documentation](#api-documentation)

---

## 🎯 Overview

### Objectives

Phase 3: Connectivity extends the voice assistant with cloud services and external integrations:

- **Cloud Integration**: Data backup, OTA updates, remote diagnostics
- **Mobile App**: Companion smartphone application for remote control
- **Ecosystem Integration**: Alexa, Google Assistant, IFTTT
- **Cellular Connectivity**: 5G/LTE for always-connected features

### Success Criteria

- [ ] Cloud backup operational
- [ ] OTA update system functional
- [ ] Mobile app released (iOS + Android)
- [ ] Alexa/Google Assistant integration
- [ ] LTE modem working
- [ ] End-to-end encryption enabled
- [ ] <200ms cloud API latency

---

## ☁️ Cloud Integration

### Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    Cloud Services                           │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   User Data  │  │  OTA Update  │  │  Analytics   │    │
│  │   Storage    │  │   Service    │  │   Service    │    │
│  │  (S3/GCS)    │  │              │  │              │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                  │                  │            │
│  ┌──────▼──────────────────▼──────────────────▼───────┐   │
│  │            REST API Gateway                        │   │
│  │  - Authentication (JWT)                            │   │
│  │  - Rate limiting                                    │   │
│  │  - Load balancing                                   │   │
│  └─────────────────────────┬──────────────────────────┘   │
│                            │                               │
└────────────────────────────┼───────────────────────────────┘
                             │ HTTPS
                             │
┌────────────────────────────▼───────────────────────────────┐
│              Raspberry Pi Voice Assistant                   │
│  ┌────────────────────────────────────────────────────┐   │
│  │           Cloud Sync Service                       │   │
│  │  - Data synchronization                            │   │
│  │  - OTA update client                               │   │
│  │  - Telemetry reporting                             │   │
│  └────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────┘
```

### Cloud Backend

**AWS Example** (`backend/cloud_service.py`):

```python
import boto3
import requests
import json
from datetime import datetime

class CloudService:
    def __init__(self, api_endpoint, api_key, device_id):
        self.api_endpoint = api_endpoint
        self.api_key = api_key
        self.device_id = device_id
        
        # AWS clients
        self.s3 = boto3.client('s3')
        self.dynamodb = boto3.resource('dynamodb')
    
    def backup_user_data(self, user_id, data):
        """Backup user preferences and history to cloud"""
        backup_data = {
            "device_id": self.device_id,
            "user_id": user_id,
            "timestamp": datetime.now().isoformat(),
            "data": data
        }
        
        # Upload to S3
        key = f"backups/{self.device_id}/{user_id}/{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        self.s3.put_object(
            Bucket='voice-assistant-backups',
            Key=key,
            Body=json.dumps(backup_data),
            ServerSideEncryption='AES256'
        )
        
        return {"success": True, "backup_key": key}
    
    def restore_user_data(self, user_id):
        """Restore user data from cloud"""
        # List backups for user
        prefix = f"backups/{self.device_id}/{user_id}/"
        
        response = self.s3.list_objects_v2(
            Bucket='voice-assistant-backups',
            Prefix=prefix
        )
        
        if 'Contents' not in response or not response['Contents']:
            return {"success": False, "error": "No backups found"}
        
        # Get latest backup
        latest = sorted(response['Contents'], key=lambda x: x['LastModified'])[-1]
        
        # Download
        obj = self.s3.get_object(
            Bucket='voice-assistant-backups',
            Key=latest['Key']
        )
        
        backup_data = json.loads(obj['Body'].read())
        
        return {
            "success": True,
            "data": backup_data["data"],
            "timestamp": backup_data["timestamp"]
        }
    
    def check_for_updates(self):
        """Check for OTA updates"""
        response = requests.get(
            f"{self.api_endpoint}/updates/check",
            headers={"Authorization": f"Bearer {self.api_key}"},
            params={"device_id": self.device_id}
        )
        
        if response.status_code == 200:
            update_info = response.json()
            return {
                "update_available": update_info.get("available", False),
                "version": update_info.get("version"),
                "download_url": update_info.get("download_url"),
                "changelog": update_info.get("changelog")
            }
        
        return {"update_available": False}
    
    def download_and_install_update(self, download_url):
        """Download and install OTA update"""
        import subprocess
        
        # Download update package
        response = requests.get(download_url, stream=True)
        
        update_file = "/tmp/update.tar.gz"
        with open(update_file, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        # Verify signature (important for security)
        # ... signature verification code ...
        
        # Extract and install
        subprocess.run(["tar", "-xzf", update_file, "-C", "/tmp/update"])
        subprocess.run(["/tmp/update/install.sh"])
        
        return {"success": True}
    
    def send_telemetry(self, metrics):
        """Send usage metrics to cloud"""
        telemetry_data = {
            "device_id": self.device_id,
            "timestamp": datetime.now().isoformat(),
            "metrics": metrics
        }
        
        response = requests.post(
            f"{self.api_endpoint}/telemetry",
            headers={"Authorization": f"Bearer {self.api_key}"},
            json=telemetry_data
        )
        
        return {"success": response.status_code == 200}
```

### OTA Update System

**Update Manager**:

```python
import os
import hashlib
import subprocess

class OTAUpdateManager:
    def __init__(self, cloud_service):
        self.cloud = cloud_service
        self.current_version = "2.0.0"
        self.update_in_progress = False
    
    def check_and_update(self):
        """Check for updates and install if available"""
        if self.update_in_progress:
            return {"success": False, "error": "Update already in progress"}
        
        # Check for updates
        update_info = self.cloud.check_for_updates()
        
        if not update_info["update_available"]:
            return {"success": True, "message": "No updates available"}
        
        # Download and install
        self.update_in_progress = True
        
        try:
            result = self.cloud.download_and_install_update(
                update_info["download_url"]
            )
            
            if result["success"]:
                # Schedule reboot
                subprocess.run(["sudo", "shutdown", "-r", "+1"])
                return {
                    "success": True,
                    "message": "Update installed, rebooting in 1 minute"
                }
        except Exception as e:
            return {"success": False, "error": str(e)}
        finally:
            self.update_in_progress = False
```

---

## 📱 Mobile App Companion

### App Architecture

**Flutter Cross-Platform App**:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoiceAssistantApp extends StatefulWidget {
  @override
  _VoiceAssistantAppState createState() => _VoiceAssistantAppState();
}

class _VoiceAssistantAppState extends State<VoiceAssistantApp> {
  String _deviceStatus = "Connecting...";
  String _currentTemperature = "22°C";
  bool _isConnected = false;
  
  final String apiEndpoint = "http://raspberrypi.local:8000";
  
  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }
  
  Future<void> _connectToDevice() async {
    try {
      final response = await http.get(Uri.parse('$apiEndpoint/status'));
      
      if (response.statusCode == 200) {
        setState(() {
          _isConnected = true;
          _deviceStatus = "Connected";
        });
        _fetchDeviceData();
      }
    } catch (e) {
      setState(() {
        _deviceStatus = "Connection failed";
      });
    }
  }
  
  Future<void> _fetchDeviceData() async {
    final response = await http.get(Uri.parse('$apiEndpoint/climate/status'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _currentTemperature = "${data['temperature']}°C";
      });
    }
  }
  
  Future<void> _setTemperature(int temp) async {
    final response = await http.post(
      Uri.parse('$apiEndpoint/climate/temperature'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"value": temp})
    );
    
    if (response.statusCode == 200) {
      _fetchDeviceData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Voice Assistant Control'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isConnected ? Icons.check_circle : Icons.error,
                size: 64,
                color: _isConnected ? Colors.green : Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                _deviceStatus,
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 40),
              
              // Climate Control
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Climate Control',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Current Temperature',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        _currentTemperature,
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Slider(
                        value: double.parse(_currentTemperature.replaceAll('°C', '')),
                        min: 16,
                        max: 30,
                        divisions: 14,
                        label: _currentTemperature,
                        onChanged: (value) {
                          _setTemperature(value.toInt());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.navigation),
                    label: Text('Navigate Home'),
                    onPressed: () => _sendCommand('navigate_home'),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.music_note),
                    label: Text('Play Music'),
                    onPressed: () => _sendCommand('play_music'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _sendCommand(String command) async {
    await http.post(
      Uri.parse('$apiEndpoint/command'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"command": command})
    );
  }
}

void main() => runApp(VoiceAssistantApp());
```

### Mobile App Features

**Implemented**:
1. Device connection status
2. Climate control interface
3. Navigation quick actions
4. Media player controls
5. Voice command history
6. Settings synchronization
7. Push notifications for alerts
8. Vehicle location tracking

### API Endpoints

**Device API** (`backend/mobile_api.py`):

```python
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/status', methods=['GET'])
def get_status():
    """Get device status"""
    return jsonify({
        "online": True,
        "version": "2.0.0",
        "uptime": get_uptime(),
        "battery": get_battery_level()
    })

@app.route('/climate/status', methods=['GET'])
def get_climate_status():
    """Get climate control status"""
    return jsonify({
        "temperature": 22,
        "fan_speed": 3,
        "ac_enabled": True
    })

@app.route('/climate/temperature', methods=['POST'])
def set_temperature():
    """Set temperature"""
    data = request.json
    temp = data.get('value')
    
    # Send to vehicle control service
    vehicle_service.set_temperature(temp)
    
    return jsonify({"success": True, "temperature": temp})

@app.route('/command', methods=['POST'])
def execute_command():
    """Execute voice command"""
    data = request.json
    command = data.get('command')
    
    # Process command
    result = command_handler.execute(command)
    
    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
```

---

## 🌐 Voice Assistant Ecosystem Integration

### Alexa Integration

**Alexa Skill** (`alexa_skill/lambda_function.py`):

```python
import logging
import requests

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """Handle Alexa requests"""
    request_type = event['request']['type']
    
    if request_type == "LaunchRequest":
        return build_response("Welcome to Voice Assistant Control")
    
    elif request_type == "IntentRequest":
        intent_name = event['request']['intent']['name']
        
        if intent_name == "SetTemperatureIntent":
            temp = int(event['request']['intent']['slots']['temperature']['value'])
            
            # Call device API
            response = requests.post(
                'https://device.example.com/api/climate/temperature',
                json={"value": temp},
                headers={"Authorization": "Bearer TOKEN"}
            )
            
            if response.status_code == 200:
                return build_response(f"Setting temperature to {temp} degrees")
            else:
                return build_response("Failed to set temperature")
        
        elif intent_name == "NavigateIntent":
            location = event['request']['intent']['slots']['location']['value']
            
            response = requests.post(
                'https://device.example.com/api/navigation/start',
                json={"destination": location},
                headers={"Authorization": "Bearer TOKEN"}
            )
            
            return build_response(f"Starting navigation to {location}")
    
    return build_response("Sorry, I didn't understand that")

def build_response(speech_text):
    """Build Alexa response"""
    return {
        'version': '1.0',
        'response': {
            'outputSpeech': {
                'type': 'PlainText',
                'text': speech_text
            },
            'shouldEndSession': True
        }
    }
```

### Google Assistant Integration

**Actions on Google** (`actions.json`):

```json
{
  "actions": [
    {
      "name": "actions.intent.MAIN",
      "intent": {
        "name": "actions.intent.MAIN"
      },
      "fulfillment": {
        "conversationName": "voice-assistant"
      }
    },
    {
      "name": "com.example.SetTemperature",
      "intent": {
        "name": "com.example.SetTemperature",
        "parameters": [
          {
            "name": "temperature",
            "type": "SchemaOrg_Number"
          }
        ],
        "trigger": {
          "queryPatterns": [
            "set temperature to $SchemaOrg_Number:temperature degrees",
            "make it $SchemaOrg_Number:temperature degrees"
          ]
        }
      },
      "fulfillment": {
        "conversationName": "voice-assistant"
      }
    }
  ]
}
```

### IFTTT Integration

**IFTTT Webhook**:

```python
import requests

class IFTTTIntegration:
    def __init__(self, webhook_key):
        self.webhook_key = webhook_key
        self.base_url = "https://maker.ifttt.com/trigger"
    
    def trigger_event(self, event_name, value1=None, value2=None, value3=None):
        """Trigger IFTTT applet"""
        url = f"{self.base_url}/{event_name}/with/key/{self.webhook_key}"
        
        data = {}
        if value1:
            data["value1"] = value1
        if value2:
            data["value2"] = value2
        if value3:
            data["value3"] = value3
        
        response = requests.post(url, json=data)
        
        return {"success": response.status_code == 200}
    
    def on_arriving_home(self):
        """Trigger when arriving home"""
        self.trigger_event(
            "vehicle_arriving_home",
            value1="Living Room Lights",
            value2="ON"
        )
    
    def on_engine_start(self):
        """Trigger when engine starts"""
        self.trigger_event(
            "vehicle_engine_start",
            value1="Garage Door",
            value2="OPEN"
        )
```

---

## 📡 5G/LTE Connectivity

### Hardware Setup

**LTE Module Options**:

| Module | Interface | Speed | Price |
|--------|-----------|-------|-------|
| **Quectel EC25** | Mini PCIe | Cat 4 LTE | $40 |
| **SIM7600** | USB | Cat 1 LTE | $30 |
| **Sierra Wireless EM7455** | M.2 | Cat 6 LTE | $60 |

**Setup SIM7600 USB LTE Modem**:

```bash
# Install dependencies
sudo apt-get install ppp usb-modeswitch

# Configure PPP
sudo nano /etc/ppp/peers/gprs

# Add:
connect "/usr/sbin/chat -v -f /etc/chatscripts/gprs"
/dev/ttyUSB0
115200
noipdefault
defaultroute
replacedefaultroute
hide-password
noauth
persist
usepeerdns

# Start connection
sudo pon gprs

# Check connection
ifconfig ppp0
```

### LTE Manager

```python
import serial
import time

class LTEManager:
    def __init__(self, port='/dev/ttyUSB0', baud=115200):
        self.ser = serial.Serial(port, baud, timeout=1)
        time.sleep(2)
    
    def send_at_command(self, command):
        """Send AT command to modem"""
        self.ser.write((command + '\r\n').encode())
        time.sleep(1)
        response = self.ser.read_all().decode()
        return response
    
    def connect(self, apn, username='', password=''):
        """Connect to cellular network"""
        # Set APN
        self.send_at_command(f'AT+CGDCONT=1,"IP","{apn}"')
        
        # Authenticate if needed
        if username and password:
            self.send_at_command(f'AT+CGAUTH=1,1,"{username}","{password}"')
        
        # Activate PDP context
        self.send_at_command('AT+CGACT=1,1')
        
        # Check connection
        response = self.send_at_command('AT+CGPADDR=1')
        
        if 'OK' in response:
            return {"success": True, "ip": self._extract_ip(response)}
        return {"success": False}
    
    def get_signal_strength(self):
        """Get signal strength"""
        response = self.send_at_command('AT+CSQ')
        # Parse response: +CSQ: <rssi>,<ber>
        if '+CSQ:' in response:
            rssi = int(response.split(':')[1].split(',')[0].strip())
            return {"rssi": rssi, "bars": self._rssi_to_bars(rssi)}
        return None
    
    def _rssi_to_bars(self, rssi):
        """Convert RSSI to signal bars (0-5)"""
        if rssi >= 20:
            return 5
        elif rssi >= 15:
            return 4
        elif rssi >= 10:
            return 3
        elif rssi >= 5:
            return 2
        elif rssi >= 2:
            return 1
        else:
            return 0
```

---

## 🔒 Security & Privacy

### End-to-End Encryption

```python
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.backends import default_backend

class SecureConnection:
    def __init__(self):
        # Generate RSA key pair
        self.private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048,
            backend=default_backend()
        )
        self.public_key = self.private_key.public_key()
    
    def encrypt_data(self, data, recipient_public_key):
        """Encrypt data for recipient"""
        encrypted = recipient_public_key.encrypt(
            data.encode(),
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
        return encrypted
    
    def decrypt_data(self, encrypted_data):
        """Decrypt received data"""
        decrypted = self.private_key.decrypt(
            encrypted_data,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
        return decrypted.decode()
```

---

## 🛠️ Setup & Configuration

### Complete Setup

**1. Cloud Setup**:

```bash
# Configure AWS credentials
aws configure

# Deploy cloud infrastructure
cd cloud_infrastructure
terraform init
terraform apply
```

**2. Mobile App Setup**:

```bash
# Install Flutter
flutter doctor

# Build mobile app
cd mobile_app
flutter pub get
flutter build apk  # Android
flutter build ios  # iOS
```

**3. LTE Setup**:

```bash
# Install modem
# Configure PPP
sudo pon gprs
```

**4. Test Connectivity**:

```bash
# Test cloud API
curl https://api.voice-assistant.com/v1/status

# Test mobile app connection
python backend/mobile_api.py
```

---

**Phase 3 (Connectivity) Status**: ⏳ **NOT STARTED** (0%)  
**Next Phase**: [Phase 4: Technical Improvements](PHASE_4_TECHNICAL_IMPROVEMENTS.md)

---

*Last Updated: October 2024*  
*Document Version: 1.0*

