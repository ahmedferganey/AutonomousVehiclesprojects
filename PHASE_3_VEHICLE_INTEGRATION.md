# Phase 3: Vehicle Integration - Complete Guide

**Status**: 🚧 **IN PROGRESS** (Qt GUI: ✅ 100%, Backend: 0%)  
**Target**: Q2-Q3 2025  
**Priority**: High  
**Effort**: 14-16 weeks

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [CAN Bus Integration](#can-bus-integration)
4. [Navigation System](#navigation-system)
5. [Climate Control](#climate-control)
6. [Entertainment System](#entertainment-system)
7. [Safety Features](#safety-features)
8. [Hardware Requirements](#hardware-requirements)
9. [Setup & Configuration](#setup--configuration)
10. [Development Guide](#development-guide)
11. [Testing Strategy](#testing-strategy)
12. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

### Objectives

Phase 3: Vehicle Integration connects the voice assistant with actual vehicle systems through:

- **CAN Bus Communication**: Read/write vehicle data via CAN protocol
- **Navigation**: GPS-based routing with voice guidance
- **Climate Control**: HVAC system control via voice
- **Entertainment**: Media playback integration
- **Safety Features**: eCall, driver monitoring, alerts

### Success Criteria

- ✅ Qt GUI interfaces complete (Navigation, Climate, Entertainment)
- [ ] CAN bus driver functional
- [ ] Real-time vehicle data reading
- [ ] Climate control commands working
- [ ] Navigation with turn-by-turn guidance
- [ ] Media playback control
- [ ] Emergency call system
- [ ] Driver attention monitoring active

### Current Status (October 2024)

**GUI Components (✅ Complete)**:
- ✅ NavigationPanel.qml - Map display, POI search, route info
- ✅ ClimateControlPanel.qml - Temperature, fan, mode controls
- ✅ EntertainmentPanel.qml - Media player, source selection

**Backend (⏳ Not Started)**:
- [ ] CAN bus driver integration (0%)
- [ ] GPS module support (0%)
- [ ] Mapping service API (0%)
- [ ] Media streaming APIs (0%)

---

## 🏗️ Architecture

### System Overview

```
┌────────────────────────────────────────────────────────────────┐
│                  Vehicle Integration Layer                      │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Qt6 GUI (Touch Interface)                   │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐        │  │
│  │  │Navigation  │  │  Climate   │  │Entertainment│        │  │
│  │  │   Panel    │  │  Control   │  │   System    │        │  │
│  │  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘        │  │
│  └─────────┼────────────────┼────────────────┼──────────────┘  │
│            │                │                │                  │
│            │ Qt Signals/Slots & D-Bus        │                  │
│            │                │                │                  │
│  ┌─────────▼────────────────▼────────────────▼──────────────┐  │
│  │           Vehicle Control Service (Python)               │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │  Command Router & State Manager                    │ │  │
│  │  └───┬──────────────┬──────────────┬───────────────┬──┘ │  │
│  │      │              │              │               │    │  │
│  │  ┌───▼────┐  ┌──────▼────┐  ┌─────▼──────┐  ┌────▼──┐ │  │
│  │  │  CAN   │  │  GPS      │  │  Streaming │  │Safety │ │  │
│  │  │  Bus   │  │  Module   │  │  APIs      │  │System │ │  │
│  │  │Handler │  │  Handler  │  │  Handler   │  │Handler│ │  │
│  │  └───┬────┘  └──────┬────┘  └─────┬──────┘  └────┬──┘ │  │
│  └──────┼───────────────┼─────────────┼──────────────┼────┘  │
│         │               │             │              │        │
└─────────┼───────────────┼─────────────┼──────────────┼────────┘
          │               │             │              │
    ┌─────▼──────┐  ┌─────▼─────┐  ┌──▼──────┐  ┌────▼───────┐
    │  CAN Bus   │  │ GPS UART  │  │Internet │  │  Camera    │
    │ (SocketCAN)│  │ /dev/tty* │  │ (WiFi)  │  │ /dev/video*│
    └─────┬──────┘  └─────┬─────┘  └──┬──────┘  └────┬───────┘
          │               │            │              │
    ┌─────▼──────┐  ┌─────▼─────┐  ┌──▼──────┐  ┌────▼───────┐
    │  Vehicle   │  │ GPS       │  │Streaming│  │Driver Cam  │
    │  ECUs      │  │ Satellite │  │Services │  │            │
    │  (HVAC,    │  │           │  │(Spotify │  │            │
    │  Engine,   │  │           │  │ etc.)   │  │            │
    │  Body)     │  │           │  │         │  │            │
    └────────────┘  └───────────┘  └─────────┘  └────────────┘
```

### Data Flow Examples

**Climate Control Flow**:
```
User: "Set temperature to 22"
   │
   ▼
Voice Recognition → NLU (intent: climate_control, temp: 22)
   │
   ▼
ClimateControlPanel.qml → Signal: temperatureChanged(22)
   │
   ▼
VehicleControlService → ClimateHandler.set_temperature(22)
   │
   ▼
CAN Bus → Message ID 0x320 [0x01, 22, 0x00, ...]
   │
   ▼
HVAC ECU → Temperature set to 22°C
   │
   ▼
CAN Bus Response → Status confirmation
   │
   ▼
VehicleControlService → Update GUI
   │
   ▼
TTS: "Temperature set to 22 degrees"
```

---

## 🚗 CAN Bus Integration

### Overview

**CAN** (Controller Area Network) is the standard communication protocol in modern vehicles for ECU (Electronic Control Unit) communication.

**Requirements**:
- CAN transceiver hardware (MCP2515 + TJA1050)
- SocketCAN driver support in Linux kernel
- python-can library

### Hardware Setup

**Option 1: MCP2515 CAN HAT for Raspberry Pi**

```
Component: Waveshare RS485 CAN HAT
Interface: SPI (CE0, GPIO 25 interrupt)
Datarate: Up to 1 Mbps
Price: ~$25
```

**Wiring**:
```
Raspberry Pi 4 GPIO → MCP2515 Module
    3.3V → VCC
    GND → GND
    GPIO 10 (MOSI) → SI
    GPIO 9 (MISO) → SO
    GPIO 11 (SCLK) → SCK
    GPIO 8 (CE0) → CS
    GPIO 25 → INT
    
MCP2515 → TJA1050 Transceiver → Vehicle OBD-II Port
    CAN_H → Pin 6 (CAN High)
    CAN_L → Pin 14 (CAN Low)
    GND → Pin 4, 5 (Ground)
```

**Enable SPI**:

Edit `/boot/config.txt`:
```ini
dtparam=spi=on
dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25
dtoverlay=spi-bcm2835
```

Reboot:
```bash
sudo reboot
```

**Verify**:
```bash
ip link show can0
# Should show: can0: <NOARP,UP,LOWER_UP>
```

### SocketCAN Configuration

**Bring up CAN interface**:

```bash
# Set bitrate (typical: 500kbps)
sudo ip link set can0 type can bitrate 500000

# Bring up interface
sudo ip link set can0 up

# Verify
ip -details -statistics link show can0
```

**Make Persistent** (systemd service):

`/etc/systemd/system/can-setup.service`:
```ini
[Unit]
Description=Setup CAN interface
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ip link set can0 type can bitrate 500000
ExecStart=/sbin/ip link set can0 up
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable:
```bash
sudo systemctl enable can-setup.service
sudo systemctl start can-setup.service
```

### Python CAN Library

**Installation**:
```bash
pip3 install python-can
```

**Basic Usage**:

```python
import can
import struct

# Initialize CAN bus
bus = can.interface.Bus(channel='can0', bustype='socketcan')

# Send message
def send_can_message(msg_id, data):
    """Send CAN message"""
    message = can.Message(
        arbitration_id=msg_id,
        data=data,
        is_extended_id=False
    )
    bus.send(message)
    print(f"Sent: ID={hex(msg_id)}, Data={data.hex()}")

# Receive messages
def receive_can_messages():
    """Receive and print CAN messages"""
    print("Listening on CAN bus...")
    for msg in bus:
        print(f"Received: ID={hex(msg.arbitration_id)}, Data={msg.data.hex()}")

# Example: Request engine RPM (OBD-II PID 0x0C)
def get_engine_rpm():
    # OBD-II request: Service 01, PID 0x0C
    send_can_message(0x7DF, bytes([0x02, 0x01, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00]))
    
    # Wait for response (ID 0x7E8)
    msg = bus.recv(timeout=1.0)
    if msg and msg.arbitration_id == 0x7E8:
        # Parse response: bytes 3-4 contain RPM (RPM = (A*256 + B) / 4)
        rpm = ((msg.data[3] * 256) + msg.data[4]) / 4
        return rpm
    return None
```

### Vehicle Control Service

**Location**: `backend/vehicle_control_service.py`

```python
#!/usr/bin/env python3
import can
import json
import sys
from enum import Enum

class CANMessageID(Enum):
    """CAN message IDs for vehicle systems"""
    HVAC_TEMP_SET = 0x320
    HVAC_FAN_SPEED = 0x321
    HVAC_MODE = 0x322
    MEDIA_CONTROL = 0x400
    DOOR_LOCK = 0x210
    WINDOW_CONTROL = 0x220

class VehicleControlService:
    def __init__(self, can_channel='can0'):
        self.bus = can.interface.Bus(
            channel=can_channel,
            bustype='socketcan'
        )
        
    def set_climate_temperature(self, temp_celsius):
        """Set HVAC temperature"""
        # Convert celsius to vehicle-specific format
        temp_value = int((temp_celsius - 16) * 2)  # Example: 16°C = 0, 30°C = 28
        
        data = bytearray([
            0x01,  # Command: Set temperature
            temp_value,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        ])
        
        msg = can.Message(
            arbitration_id=CANMessageID.HVAC_TEMP_SET.value,
            data=data,
            is_extended_id=False
        )
        
        self.bus.send(msg)
        return {"success": True, "temperature": temp_celsius}
    
    def set_fan_speed(self, level):
        """Set HVAC fan speed (0-6)"""
        data = bytearray([0x02, level, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        msg = can.Message(
            arbitration_id=CANMessageID.HVAC_FAN_SPEED.value,
            data=data,
            is_extended_id=False
        )
        
        self.bus.send(msg)
        return {"success": True, "fan_level": level}
    
    def control_media(self, action):
        """Control media playback"""
        actions = {
            "play": 0x01,
            "pause": 0x02,
            "next": 0x03,
            "previous": 0x04,
            "volume_up": 0x05,
            "volume_down": 0x06
        }
        
        if action not in actions:
            return {"success": False, "error": "Unknown action"}
        
        data = bytearray([actions[action], 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        msg = can.Message(
            arbitration_id=CANMessageID.MEDIA_CONTROL.value,
            data=data,
            is_extended_id=False
        )
        
        self.bus.send(msg)
        return {"success": True, "action": action}
    
    def read_vehicle_data(self):
        """Read current vehicle status"""
        # Listen for status messages
        data = {}
        
        try:
            msg = self.bus.recv(timeout=0.5)
            if msg:
                # Parse based on message ID
                if msg.arbitration_id == 0x330:  # Example: Temperature status
                    data["current_temp"] = msg.data[0] / 2 + 16
                elif msg.arbitration_id == 0x331:  # Example: Fan speed status
                    data["fan_speed"] = msg.data[0]
        except can.CanError:
            pass
        
        return data

# Command-line interface
if __name__ == "__main__":
    service = VehicleControlService()
    
    for line in sys.stdin:
        try:
            cmd = json.loads(line)
            
            if cmd["command"] == "set_temperature":
                result = service.set_climate_temperature(cmd["value"])
            elif cmd["command"] == "set_fan_speed":
                result = service.set_fan_speed(cmd["value"])
            elif cmd["command"] == "media_control":
                result = service.control_media(cmd["action"])
            elif cmd["command"] == "read_status":
                result = service.read_vehicle_data()
            else:
                result = {"success": False, "error": "Unknown command"}
            
            print(json.dumps(result))
            sys.stdout.flush()
            
        except Exception as e:
            print(json.dumps({"success": False, "error": str(e)}))
            sys.stdout.flush()
```

### Qt Integration

**C++ Wrapper** (`src/vehiclecontroller.h`):

```cpp
#ifndef VEHICLECONTROLLER_H
#define VEHICLECONTROLLER_H

#include <QObject>
#include <QProcess>
#include <QJsonDocument>
#include <QJsonObject>

class VehicleController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentTemperature READ currentTemperature NOTIFY currentTemperatureChanged)
    Q_PROPERTY(int fanSpeed READ fanSpeed NOTIFY fanSpeedChanged)

public:
    explicit VehicleController(QObject *parent = nullptr);
    
    Q_INVOKABLE void setTemperature(int temp);
    Q_INVOKABLE void setFanSpeed(int level);
    Q_INVOKABLE void controlMedia(const QString &action);
    Q_INVOKABLE void readVehicleStatus();
    
    int currentTemperature() const { return m_currentTemperature; }
    int fanSpeed() const { return m_fanSpeed; }

signals:
    void currentTemperatureChanged();
    void fanSpeedChanged();
    void commandExecuted(bool success, const QString &message);
    void error(const QString &message);

private slots:
    void handleProcessReadyRead();
    void handleProcessError(QProcess::ProcessError error);

private:
    void sendCommand(const QJsonObject &cmd);
    
    QProcess *m_vehicleProcess;
    int m_currentTemperature;
    int m_fanSpeed;
};

#endif // VEHICLECONTROLLER_H
```

**QML Usage**:

```qml
import QtQuick

Item {
    VehicleController {
        id: vehicleCtrl
        
        onCommandExecuted: {
            if (success) {
                console.log("Success:", message)
            } else {
                console.error("Error:", message)
            }
        }
    }
    
    Button {
        text: "Set Temp to 22°C"
        onClicked: {
            vehicleCtrl.setTemperature(22)
        }
    }
}
```

### CAN Message Database (DBC File)

**Create DBC file** to document CAN messages:

`vehicle_can_db.dbc`:
```
VERSION ""

NS_ : 
	NS_DESC_
	CM_
	BA_DEF_
	BA_
	VAL_
	CAT_DEF_
	CAT_
	FILTER
	BA_DEF_DEF_
	EV_DATA_
	ENVVAR_DATA_
	SGTYPE_
	SGTYPE_VAL_
	BA_DEF_SGTYPE_
	BA_SGTYPE_
	SIG_TYPE_REF_
	VAL_TABLE_
	SIG_GROUP_
	SIG_VALTYPE_
	SIGTYPE_VALTYPE_
	BO_TX_BU_
	BA_DEF_REL_
	BA_REL_
	BA_SGTYPE_REL_
	SG_MUL_VAL_

BS_:

BU_: HVAC_ECU BODY_ECU MEDIA_ECU GATEWAY

BO_ 800 HVAC_Temperature: 8 HVAC_ECU
 SG_ TargetTemp : 8|8@1+ (0.5,16) [16|30] "degC" GATEWAY
 SG_ CurrentTemp : 16|8@1+ (0.5,16) [16|30] "degC" GATEWAY
 SG_ FanSpeed : 24|8@1+ (1,0) [0|6] "" GATEWAY

BO_ 801 HVAC_Mode: 8 HVAC_ECU
 SG_ ACEnabled : 0|1@1+ (1,0) [0|1] "" GATEWAY
 SG_ HeatEnabled : 1|1@1+ (1,0) [0|1] "" GATEWAY
 SG_ AutoMode : 2|1@1+ (1,0) [0|1] "" GATEWAY
 SG_ Recirculation : 3|1@1+ (1,0) [0|1] "" GATEWAY

BO_ 1024 Media_Control: 8 MEDIA_ECU
 SG_ PlayPause : 0|2@1+ (1,0) [0|2] "" GATEWAY
 SG_ NextPrev : 2|2@1+ (1,0) [0|2] "" GATEWAY
 SG_ Volume : 8|8@1+ (1,0) [0|100] "%" GATEWAY

CM_ SG_ 800 TargetTemp "Desired cabin temperature";
CM_ SG_ 800 CurrentTemp "Current cabin temperature";
CM_ SG_ 800 FanSpeed "HVAC fan speed level (0=off, 6=max)";

VAL_ 1024 PlayPause 0 "Stop" 1 "Play" 2 "Pause";
VAL_ 1024 NextPrev 0 "None" 1 "Next" 2 "Previous";
```

**Use with python-can**:

```python
import cantools

# Load DBC database
db = cantools.database.load_file('vehicle_can_db.dbc')

# Encode message
message = db.get_message_by_name('HVAC_Temperature')
data = message.encode({
    'TargetTemp': 22,
    'CurrentTemp': 20,
    'FanSpeed': 3
})

# Send via CAN
can_msg = can.Message(arbitration_id=message.frame_id, data=data)
bus.send(can_msg)

# Decode received message
received_msg = bus.recv()
decoded = db.decode_message(received_msg.arbitration_id, received_msg.data)
print(f"Target Temp: {decoded['TargetTemp']}°C")
```

---

## 🗺️ Navigation System

### Components

**Status**: ✅ Qt GUI Complete, ⏳ Backend Pending

#### 1. GPS Module

**Hardware Options**:

| Module | Interface | Accuracy | Price |
|--------|-----------|----------|-------|
| **NEO-6M** | UART | 2.5m | $10 |
| **NEO-7M** | UART | 2.5m | $15 |
| **NEO-M8N** | UART | 2.5m | $20 |
| **BN-880** | UART + Compass | 2.5m | $25 |

**Connection** (UART):

```
GPS Module → Raspberry Pi 4
    VCC → 5V (Pin 2 or 4)
    GND → GND (Pin 6)
    TX → GPIO 15 (RXD, Pin 10)
    RX → GPIO 14 (TXD, Pin 8)
```

**Enable UART**:

Edit `/boot/config.txt`:
```ini
enable_uart=1
dtoverlay=disable-bt  # Disable Bluetooth to free up UART
```

**Test GPS**:

```bash
# Install gpsd
sudo apt-get install gpsd gpsd-clients

# Configure gpsd
sudo nano /etc/default/gpsd
# Set: DEVICES="/dev/ttyAMA0"

# Restart gpsd
sudo systemctl restart gpsd

# Test
gpsmon /dev/ttyAMA0
cgps -s
```

**Python GPS Client**:

```python
import gpsd

# Connect to gpsd
gpsd.connect()

def get_current_location():
    """Get current GPS coordinates"""
    packet = gpsd.get_current()
    
    if packet.mode >= 2:  # 2D fix or better
        return {
            "latitude": packet.lat,
            "longitude": packet.lon,
            "altitude": packet.alt,
            "speed": packet.hspeed,  # m/s
            "heading": packet.track,  # degrees
            "satellites": packet.sats,
            "fix_quality": packet.mode
        }
    return None
```

#### 2. Mapping Service Integration

**Options**:

| Service | API | Free Tier | Commercial |
|---------|-----|-----------|------------|
| **OpenStreetMap** | Nominatim | Yes | Free |
| **Mapbox** | REST API | 50k requests/month | Paid |
| **HERE Maps** | REST API | 250k requests/month | Paid |
| **Google Maps** | JavaScript API | $200 credit/month | Paid |

**Recommended**: OpenStreetMap + Mapbox for production

**OpenStreetMap Nominatim** (Geocoding):

```python
import requests

class GeocodingService:
    def __init__(self):
        self.base_url = "https://nominatim.openstreetmap.org"
        self.headers = {
            "User-Agent": "VoiceAssistant/2.0"
        }
    
    def geocode(self, address):
        """Convert address to coordinates"""
        params = {
            "q": address,
            "format": "json",
            "limit": 1
        }
        
        response = requests.get(
            f"{self.base_url}/search",
            params=params,
            headers=self.headers
        )
        
        if response.status_code == 200:
            results = response.json()
            if results:
                return {
                    "lat": float(results[0]["lat"]),
                    "lon": float(results[0]["lon"]),
                    "display_name": results[0]["display_name"]
                }
        return None
    
    def reverse_geocode(self, lat, lon):
        """Convert coordinates to address"""
        params = {
            "lat": lat,
            "lon": lon,
            "format": "json"
        }
        
        response = requests.get(
            f"{self.base_url}/reverse",
            params=params,
            headers=self.headers
        )
        
        if response.status_code == 200:
            result = response.json()
            return result.get("display_name")
        return None
```

**Mapbox Directions API** (Routing):

```python
import requests

class RoutingService:
    def __init__(self, api_key):
        self.api_key = api_key
        self.base_url = "https://api.mapbox.com/directions/v5/mapbox"
    
    def get_route(self, start_coords, end_coords, profile="driving"):
        """Calculate route between two points"""
        # Format: longitude,latitude;longitude,latitude
        coordinates = f"{start_coords[1]},{start_coords[0]};{end_coords[1]},{end_coords[0]}"
        
        params = {
            "access_token": self.api_key,
            "geometries": "geojson",
            "steps": "true",
            "voice_instructions": "true",
            "banner_instructions": "true"
        }
        
        response = requests.get(
            f"{self.base_url}/{profile}/{coordinates}",
            params=params
        )
        
        if response.status_code == 200:
            data = response.json()
            if data["routes"]:
                route = data["routes"][0]
                return {
                    "distance": route["distance"],  # meters
                    "duration": route["duration"],  # seconds
                    "geometry": route["geometry"],  # GeoJSON
                    "steps": [
                        {
                            "instruction": step["maneuver"]["instruction"],
                            "distance": step["distance"],
                            "duration": step["duration"],
                            "location": step["maneuver"]["location"]
                        }
                        for step in route["legs"][0]["steps"]
                    ]
                }
        return None
```

#### 3. Turn-by-Turn Navigation

**Navigation Engine** (`backend/navigation_engine.py`):

```python
class NavigationEngine:
    def __init__(self, geocoding_service, routing_service, gps_client):
        self.geocoding = geocoding_service
        self.routing = routing_service
        self.gps = gps_client
        self.current_route = None
        self.current_step_index = 0
    
    def start_navigation(self, destination_address):
        """Start navigation to destination"""
        # Get current location
        current_location = self.gps.get_current_location()
        if not current_location:
            return {"success": False, "error": "No GPS fix"}
        
        # Geocode destination
        dest_coords = self.geocoding.geocode(destination_address)
        if not dest_coords:
            return {"success": False, "error": "Destination not found"}
        
        # Calculate route
        route = self.routing.get_route(
            (current_location["latitude"], current_location["longitude"]),
            (dest_coords["lat"], dest_coords["lon"])
        )
        
        if not route:
            return {"success": False, "error": "Route calculation failed"}
        
        self.current_route = route
        self.current_step_index = 0
        
        return {
            "success": True,
            "route": route,
            "first_instruction": route["steps"][0]["instruction"]
        }
    
    def get_next_instruction(self):
        """Get next navigation instruction"""
        if not self.current_route:
            return None
        
        current_location = self.gps.get_current_location()
        if not current_location:
            return None
        
        # Check if we've reached current step
        current_step = self.current_route["steps"][self.current_step_index]
        step_location = current_step["location"]
        
        # Calculate distance to step
        distance = self._calculate_distance(
            current_location["latitude"],
            current_location["longitude"],
            step_location[1],
            step_location[0]
        )
        
        # If within 50m, move to next step
        if distance < 50:
            self.current_step_index += 1
            if self.current_step_index < len(self.current_route["steps"]):
                next_step = self.current_route["steps"][self.current_step_index]
                return {
                    "instruction": next_step["instruction"],
                    "distance": next_step["distance"],
                    "step_number": self.current_step_index + 1,
                    "total_steps": len(self.current_route["steps"])
                }
            else:
                return {"instruction": "You have arrived at your destination", "arrived": True}
        
        return {
            "instruction": current_step["instruction"],
            "distance_to_step": distance
        }
    
    def _calculate_distance(self, lat1, lon1, lat2, lon2):
        """Calculate distance between two coordinates (Haversine formula)"""
        from math import radians, sin, cos, sqrt, atan2
        
        R = 6371000  # Earth radius in meters
        
        lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return R * c
```

#### 4. Qt GUI Integration

**Navigation Panel** (✅ Complete):

```qml
// qml/NavigationPanel.qml
import QtQuick
import QtQuick.Controls
import QtLocation
import QtPositioning

Item {
    id: root
    
    // Map display
    Map {
        id: map
        anchors.fill: parent
        plugin: Plugin {
            name: "osm"  // OpenStreetMap
        }
        center: QtPositioning.coordinate(30.0444, 31.2357)  // Cairo
        zoomLevel: 14
        
        // Current location marker
        MapQuickItem {
            coordinate: currentLocation
            sourceItem: Image {
                source: "qrc:/icons/location-marker.svg"
                width: 32
                height: 32
            }
        }
        
        // Route polyline
        MapPolyline {
            line.color: "#3498db"
            line.width: 5
            path: routePath
        }
    }
    
    // Route info overlay
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 120
        color: "#2c3e50"
        opacity: 0.9
        
        Column {
            anchors.centerIn: parent
            spacing: 10
            
            Text {
                text: currentInstruction
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }
            
            Row {
                spacing: 20
                Text {
                    text: "Distance: " + totalDistance
                    color: "#ecf0f1"
                    font.pixelSize: 14
                }
                Text {
                    text: "ETA: " + estimatedArrival
                    color: "#ecf0f1"
                    font.pixelSize: 14
                }
            }
        }
    }
    
    // Voice command button
    Button {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        text: "🎤 Voice Command"
        onClicked: {
            // Activate voice input for navigation
            voiceInput.start()
        }
    }
}
```

---

## ❄️ Climate Control

### Status

✅ **Qt GUI Complete** (ClimateControlPanel.qml)  
⏳ **Backend Pending** (CAN bus integration required)

### Features

**Implemented GUI Controls**:
- Temperature slider (16-30°C)
- Fan speed selector (0-6 levels)
- Mode buttons (Auto, AC, Heat, Recirculation)
- Defrost controls (Front & Rear)
- Power on/off toggle

### Backend Implementation

**Climate Control Handler** (`backend/climate_handler.py`):

```python
class ClimateControlHandler:
    def __init__(self, vehicle_service):
        self.vehicle = vehicle_service
        self.current_state = {
            "temperature": 22,
            "fan_speed": 3,
            "ac_enabled": False,
            "heat_enabled": False,
            "auto_mode": True,
            "recirculation": False,
            "defrost_front": False,
            "defrost_rear": False,
            "power_on": True
        }
    
    def set_temperature(self, temp):
        """Set desired temperature"""
        if 16 <= temp <= 30:
            self.current_state["temperature"] = temp
            self.vehicle.set_climate_temperature(temp)
            return {"success": True, "temperature": temp}
        return {"success": False, "error": "Temperature out of range"}
    
    def set_fan_speed(self, level):
        """Set fan speed (0-6)"""
        if 0 <= level <= 6:
            self.current_state["fan_speed"] = level
            self.vehicle.set_fan_speed(level)
            return {"success": True, "fan_speed": level}
        return {"success": False, "error": "Fan speed out of range"}
    
    def set_mode(self, mode):
        """Set HVAC mode"""
        modes = {
            "auto": {"auto_mode": True, "ac_enabled": False, "heat_enabled": False},
            "ac": {"auto_mode": False, "ac_enabled": True, "heat_enabled": False},
            "heat": {"auto_mode": False, "ac_enabled": False, "heat_enabled": True},
            "off": {"auto_mode": False, "ac_enabled": False, "heat_enabled": False}
        }
        
        if mode in modes:
            self.current_state.update(modes[mode])
            # Send CAN message for mode change
            return {"success": True, "mode": mode}
        return {"success": False, "error": "Unknown mode"}
    
    def toggle_recirculation(self):
        """Toggle air recirculation"""
        self.current_state["recirculation"] = not self.current_state["recirculation"]
        # Send CAN message
        return {"success": True, "recirculation": self.current_state["recirculation"]}
    
    def set_defrost(self, position, enabled):
        """Control defrost (front/rear)"""
        if position == "front":
            self.current_state["defrost_front"] = enabled
        elif position == "rear":
            self.current_state["defrost_rear"] = enabled
        else:
            return {"success": False, "error": "Invalid position"}
        
        # Send CAN message
        return {"success": True, position: enabled}
    
    def get_status(self):
        """Get current climate control status"""
        return self.current_state
```

### Voice Commands

**Supported Commands**:
- "Set temperature to [value]"
- "Make it warmer/cooler"
- "Turn on/off AC"
- "Increase/decrease fan speed"
- "Set fan to level [1-6]"
- "Enable/disable recirculation"
- "Turn on/off defrost"
- "Set climate to auto mode"

**NLU Intent Mapping**:

```json
{
  "intent": "climate_control",
  "entities": [
    {"type": "temperature", "value": 22},
    {"type": "unit", "value": "celsius"},
    {"type": "action", "value": "set"}
  ]
}
```

---

## 🎵 Entertainment System

### Status

✅ **Qt GUI Complete** (EntertainmentPanel.qml)  
⏳ **Backend Pending** (Streaming APIs integration required)

### Features

**Implemented GUI Controls**:
- Play/Pause/Skip buttons
- Volume slider
- Source selector (Spotify, Radio, Local Files, Podcasts)
- Album art display
- Track information (title, artist, album)
- Playback progress bar

### Streaming Service Integration

#### Spotify API

**Setup**:

1. Register app at https://developer.spotify.com/dashboard
2. Get Client ID and Secret
3. Install Spotipy library:

```bash
pip install spotipy
```

**Implementation** (`backend/spotify_handler.py`):

```python
import spotipy
from spotipy.oauth2 import SpotifyOAuth

class SpotifyHandler:
    def __init__(self, client_id, client_secret, redirect_uri):
        self.sp = spotipy.Spotify(auth_manager=SpotifyOAuth(
            client_id=client_id,
            client_secret=client_secret,
            redirect_uri=redirect_uri,
            scope="user-read-playback-state,user-modify-playback-state,user-read-currently-playing"
        ))
    
    def play(self):
        """Resume playback"""
        self.sp.start_playback()
        return {"success": True}
    
    def pause(self):
        """Pause playback"""
        self.sp.pause_playback()
        return {"success": True}
    
    def next_track(self):
        """Skip to next track"""
        self.sp.next_track()
        return {"success": True}
    
    def previous_track(self):
        """Go to previous track"""
        self.sp.previous_track()
        return {"success": True}
    
    def set_volume(self, volume_percent):
        """Set volume (0-100)"""
        self.sp.volume(volume_percent)
        return {"success": True, "volume": volume_percent}
    
    def get_current_track(self):
        """Get currently playing track info"""
        current = self.sp.current_user_playing_track()
        
        if current and current["is_playing"]:
            track = current["item"]
            return {
                "is_playing": True,
                "track_name": track["name"],
                "artist": track["artists"][0]["name"],
                "album": track["album"]["name"],
                "album_art": track["album"]["images"][0]["url"],
                "duration_ms": track["duration_ms"],
                "progress_ms": current["progress_ms"]
            }
        return {"is_playing": False}
    
    def search_and_play(self, query):
        """Search for track and play"""
        results = self.sp.search(q=query, limit=1, type="track")
        
        if results["tracks"]["items"]:
            track_uri = results["tracks"]["items"][0]["uri"]
            self.sp.start_playback(uris=[track_uri])
            return {"success": True, "track": results["tracks"]["items"][0]["name"]}
        return {"success": False, "error": "Track not found"}
```

#### FM Radio (Hardware)

**Requirements**:
- TEA5767 FM radio module (~$5)
- I2C connection

**Setup**:

```python
import smbus2

class FMRadioHandler:
    def __init__(self, i2c_bus=1, i2c_address=0x60):
        self.bus = smbus2.SMBus(i2c_bus)
        self.address = i2c_address
        self.current_frequency = 95.0  # MHz
    
    def set_frequency(self, freq_mhz):
        """Tune to frequency"""
        # TEA5767 frequency calculation
        pll = int(4 * (freq_mhz * 1000000 + 225000) / 32768)
        
        # Write to TEA5767
        data = [
            (pll >> 8) & 0x3F,
            pll & 0xFF,
            0x90,  # Search direction, stereo
            0x1E,  # Search level
            0x00
        ]
        
        self.bus.write_i2c_block_data(self.address, 0, data)
        self.current_frequency = freq_mhz
        
        return {"success": True, "frequency": freq_mhz}
    
    def scan_stations(self):
        """Scan for available radio stations"""
        stations = []
        for freq in range(8800, 10800, 10):  # 88.0 - 108.0 MHz
            freq_mhz = freq / 100.0
            self.set_frequency(freq_mhz)
            
            # Read signal level
            time.sleep(0.1)
            data = self.bus.read_i2c_block_data(self.address, 0, 5)
            signal_level = data[3] >> 4
            
            if signal_level > 7:  # Strong signal
                stations.append(freq_mhz)
        
        return {"success": True, "stations": stations}
```

### Media Control Integration

**Unified Media Controller**:

```python
class MediaController:
    def __init__(self):
        self.sources = {
            "spotify": SpotifyHandler(...),
            "radio": FMRadioHandler(),
            "bluetooth": BluetoothAudioHandler(),
            "local": LocalMediaPlayer()
        }
        self.current_source = "spotify"
    
    def switch_source(self, source):
        """Switch media source"""
        if source in self.sources:
            # Pause current source
            if hasattr(self.sources[self.current_source], 'pause'):
                self.sources[self.current_source].pause()
            
            self.current_source = source
            return {"success": True, "source": source}
        return {"success": False, "error": "Unknown source"}
    
    def play(self):
        """Play current source"""
        return self.sources[self.current_source].play()
    
    def pause(self):
        """Pause current source"""
        return self.sources[self.current_source].pause()
    
    # ... other unified controls
```

---

## 🚨 Safety Features

### Overview

**Status**: ⏳ **NOT STARTED**

**Planned Features**:
1. Emergency Call (eCall)
2. Driver Attention Monitoring
3. Weather Alerts
4. Traffic Update Announcements

### Emergency Call (eCall)

**Implementation**:

```python
import requests
import gpsd

class EmergencyCallService:
    def __init__(self, emergency_number="112"):
        self.emergency_number = emergency_number
        self.gps = gpsd
    
    def trigger_ecall(self, auto_triggered=False):
        """Trigger emergency call"""
        # Get current location
        location = self.gps.get_current_location()
        
        # Prepare emergency data
        emergency_data = {
            "timestamp": datetime.now().isoformat(),
            "location": {
                "latitude": location["latitude"],
                "longitude": location["longitude"]
            },
            "auto_triggered": auto_triggered,
            "vehicle_info": {
                "speed": location["speed"],
                "heading": location["heading"]
            }
        }
        
        # Send to emergency services (implementation depends on region)
        # This is a placeholder - actual implementation requires carrier integration
        
        # Log emergency
        with open("/var/log/emergency_calls.log", "a") as f:
            f.write(json.dumps(emergency_data) + "\n")
        
        return {"success": True, "emergency_data": emergency_data}
```

### Driver Attention Monitoring

**Using Computer Vision** (See Phase 3: AI/ML Enhancements for details)

---

## 🔧 Setup & Configuration

### Complete Setup Guide

**1. Hardware Setup**:

```bash
# Enable required interfaces
sudo raspi-config
# Enable: SPI, I2C, UART

# Install CAN HAT
# Connect as per wiring diagram
```

**2. Software Installation**:

```bash
# Install dependencies
sudo apt-get install can-utils gpsd gpsd-clients

pip install python-can cantools gpsd-py3 spotipy requests
```

**3. Configure Services**:

```bash
# CAN interface
sudo systemctl enable can-setup

# GPS daemon
sudo systemctl enable gpsd

# Vehicle control service
sudo systemctl enable vehicle-control.service
```

**4. Test Components**:

```bash
# Test CAN bus
cansend can0 123#1122334455667788
candump can0

# Test GPS
cgps -s

# Test vehicle control
echo '{"command":"set_temperature","value":22}' | python backend/vehicle_control_service.py
```

---

## 🧪 Testing Strategy

### Hardware-in-Loop Testing

**CAN Bus Simulator**:

```python
# Simulate vehicle ECU responses
class CANSimulator:
    def __init__(self, channel='vcan0'):
        # Use virtual CAN interface
        os.system("sudo modprobe vcan")
        os.system("sudo ip link add dev vcan0 type vcan")
        os.system("sudo ip link set up vcan0")
        
        self.bus = can.interface.Bus(channel=channel, bustype='socketcan')
    
    def simulate_hvac_response(self):
        """Simulate HVAC ECU responses"""
        while True:
            # Simulate temperature status
            msg = can.Message(
                arbitration_id=0x330,
                data=[44, 46, 3, 0, 0, 0, 0, 0],  # 22°C, 23°C, fan level 3
                is_extended_id=False
            )
            self.bus.send(msg)
            time.sleep(1)
```

### Integration Tests

```python
# tests/test_vehicle_integration.py
def test_climate_control():
    vehicle = VehicleControlService('vcan0')
    result = vehicle.set_climate_temperature(22)
    assert result["success"] == True
    assert result["temperature"] == 22

def test_navigation():
    nav = NavigationEngine(...)
    result = nav.start_navigation("123 Main St")
    assert result["success"] == True
    assert "route" in result
```

---

## 🔧 Troubleshooting

### CAN Bus Issues

```bash
# Check interface status
ip -details link show can0

# Check for errors
ip -statistics link show can0

# Monitor raw messages
candump can0

# Check kernel logs
dmesg | grep -i can
```

### GPS Not Working

```bash
# Check UART
cat /dev/ttyAMA0

# Check gpsd
sudo systemctl status gpsd
gpsmon /dev/ttyAMA0
```

---

**Phase 3 (Vehicle Integration) Status**: 🚧 **IN PROGRESS** (Qt GUI: ✅ 100%, Backend: 10%)  
**Next Phase**: [Phase 3: AI/ML Enhancements](PHASE_3_AI_ML_ENHANCEMENTS.md)

---

*Last Updated: October 2024*  
*Document Version: 1.0*

