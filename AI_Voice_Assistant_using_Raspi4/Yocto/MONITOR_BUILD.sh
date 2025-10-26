#!/bin/bash
# Monitor Yocto Build Progress
# Date: October 26, 2025

BUILD_DIR="/media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects/AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky/building"
LOG_DIR="$BUILD_DIR/tmp/log/cooker"

echo "==========================================================="
echo "  Yocto SDK Build Monitor"
echo "==========================================================="
echo ""

# Check if build is running
BUILD_RUNNING=$(ps aux | grep -E "[b]itbake" | wc -l)
if [ "$BUILD_RUNNING" -gt 0 ]; then
    echo "✓ Build Status: RUNNING"
    echo ""
    ps aux | grep -E "[b]itbake" | grep -v grep | awk '{print "  PID:", $2, "| CPU:", $3"%", "| MEM:", $4"%"}'
else
    echo "⚠ Build Status: NOT RUNNING"
fi

echo ""
echo "==========================================================="
echo "  Build Progress"
echo "==========================================================="
echo ""

# Find latest console log
LATEST_LOG=$(find "$LOG_DIR" -name "console-latest.log" 2>/dev/null | head -1)

if [ -f "$LATEST_LOG" ]; then
    echo "📊 Latest Build Activity:"
    echo ""
    tail -30 "$LATEST_LOG" | grep -E "Currently.*running tasks|NOTE:.*Preparing|NOTE:.*Running|ERROR:|WARNING:" | tail -10
    echo ""
    
    # Check for errors
    ERROR_COUNT=$(grep -c "^ERROR:" "$LATEST_LOG" 2>/dev/null || echo "0")
    WARNING_COUNT=$(grep -c "^WARNING:" "$LATEST_LOG" 2>/dev/null || echo "0")
    
    echo "-----------------------------------------------------------"
    echo "Errors:   $ERROR_COUNT"
    echo "Warnings: $WARNING_COUNT"
    echo ""
else
    echo "⚠ No build log found yet. Build may be initializing..."
    echo ""
    
    # Check recent SDK build logs in current directory
    RECENT_LOGS=$(ls -t "$BUILD_DIR"/sdk_build_*.log 2>/dev/null | head -1)
    if [ -n "$RECENT_LOGS" ]; then
        echo "📝 Checking recent build log: $(basename $RECENT_LOGS)"
        echo ""
        tail -20 "$RECENT_LOGS" | grep -E "Currently.*running|NOTE:|ERROR:|WARNING:" | tail -10
    fi
fi

echo "==========================================================="
echo "  Disk Space"
echo "==========================================================="
echo ""
df -h "$BUILD_DIR" | tail -1 | awk '{print "Available:", $4, "| Used:", $3, "| Total:", $2, "| Usage:", $5}'

echo ""
echo "==========================================================="
echo "  Build Files"
echo "==========================================================="
echo ""

if [ -d "$BUILD_DIR/tmp" ]; then
    TMP_SIZE=$(du -sh "$BUILD_DIR/tmp" 2>/dev/null | awk '{print $1}')
    echo "tmp/ directory:      $TMP_SIZE"
fi

if [ -d "$BUILD_DIR/sstate-cache" ]; then
    SSTATE_SIZE=$(du -sh "$BUILD_DIR/sstate-cache" 2>/dev/null | awk '{print $1}')
    echo "sstate-cache/:       $SSTATE_SIZE"
fi

if [ -d "$BUILD_DIR/downloads" ]; then
    DOWNLOADS_SIZE=$(du -sh "$BUILD_DIR/downloads" 2>/dev/null | awk '{print $1}')
    echo "downloads/:          $DOWNLOADS_SIZE"
fi

echo ""
echo "==========================================================="
echo "  Quick Actions"
echo "==========================================================="
echo ""
echo "To view live build log:"
echo "  tail -f $LOG_DIR/*/console-latest.log"
echo ""
echo "To check for errors:"
echo "  grep ERROR: $LOG_DIR/*/console-latest.log"
echo ""
echo "To stop the build:"
echo "  killall bitbake"
echo ""
echo "To restart monitoring:"
echo "  watch -n 30 $0"
echo ""
echo "==========================================================="

