#!/bin/bash

# CloudMart Data Generator Management Script

case "$1" in
    start)
        if [ -f generator.pid ] && kill -0 $(cat generator.pid) 2>/dev/null; then
            echo "❌ Generator is already running (PID: $(cat generator.pid))"
        else
            echo "🚀 Starting data generator..."
            nohup ./continuous-data-generator.sh > data-generator.log 2>&1 &
            echo $! > generator.pid
            echo "✅ Generator started (PID: $!)"
        fi
        ;;
    stop)
        if [ -f generator.pid ]; then
            PID=$(cat generator.pid)
            if kill -0 $PID 2>/dev/null; then
                kill $PID
                rm generator.pid
                echo "✅ Generator stopped (PID: $PID)"
            else
                echo "❌ Generator not running"
                rm generator.pid
            fi
        else
            echo "❌ No generator PID file found"
        fi
        ;;
    status)
        if [ -f generator.pid ] && kill -0 $(cat generator.pid) 2>/dev/null; then
            echo "✅ Generator is running (PID: $(cat generator.pid))"
            echo "📊 Recent activity:"
            tail -5 data-generator.log
        else
            echo "❌ Generator is not running"
        fi
        ;;
    logs)
        if [ -f data-generator.log ]; then
            tail -f data-generator.log
        else
            echo "❌ No log file found"
        fi
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    *)
        echo "CloudMart Data Generator Management"
        echo "Usage: $0 {start|stop|status|logs|restart}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the data generator"
        echo "  stop    - Stop the data generator"
        echo "  status  - Check generator status"
        echo "  logs    - View live logs"
        echo "  restart - Restart the generator"
        ;;
esac
