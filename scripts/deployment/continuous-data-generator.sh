#!/bin/bash

echo "🚀 CloudMart Continuous Data Generator Started"
echo "This will generate realistic application activity every 30 seconds"
echo "Press Ctrl+C to stop"

# Counter for tracking cycles
cycle=1

# Function to generate one cycle of activity
generate_activity_cycle() {
    local cycle_num=$1
    echo "🔄 Cycle $cycle_num ($(date '+%H:%M:%S'))"
    
    # Simulate 2-4 concurrent users
    num_users=$((2 + RANDOM % 3))
    
    for user in $(seq 1 $num_users); do
        (
            # Random user journey
            case $((RANDOM % 4)) in
                0) # Product browsing + AI recommendation
                    curl -s "https://app.cloudmartsaid.shop/api/products" > /dev/null
                    curl -s -X POST "https://app.cloudmartsaid.shop/api/ai/start" \
                        -H "Content-Type: application/json" \
                        -d "{\"message\":\"Show me trending products for user $user\"}" > /dev/null
                    ;;
                1) # Business analytics
                    curl -s -X POST "https://app.cloudmartsaid.shop/api/ai/bedrock/start" \
                        -H "Content-Type: application/json" \
                        -d "{\"message\":\"Analyze customer behavior patterns cycle $cycle_num\"}" > /dev/null
                    ;;
                2) # Customer feedback
                    sentiments=("Excellent service!" "Great AI recommendations!" "Fast delivery!" "Amazing platform!" "Love the features!")
                    sentiment=${sentiments[$((RANDOM % 5))]}
                    curl -s -X POST "https://app.cloudmartsaid.shop/api/ai/analyze-sentiment" \
                        -H "Content-Type: application/json" \
                        -d "{\"thread\":{\"messages\":[{\"text\":\"$sentiment\",\"sender\":\"user\"}]}}" > /dev/null
                    ;;
                3) # Mixed activity
                    curl -s "https://app.cloudmartsaid.shop/health" > /dev/null
                    curl -s "https://app.cloudmartsaid.shop/api/orders" > /dev/null
                    ;;
            esac
        ) &
    done
    
    # Occasional errors (5% chance)
    if [ $((RANDOM % 20)) -eq 0 ]; then
        curl -s "https://app.cloudmartsaid.shop/api/error-endpoint-$cycle_num" > /dev/null &
    fi
    
    wait
    echo "  ✅ $num_users users simulated"
}

# Main loop
while true; do
    generate_activity_cycle $cycle
    
    # Wait 30-45 seconds between cycles
    sleep_time=$((30 + RANDOM % 15))
    echo "  ⏳ Next cycle in ${sleep_time}s..."
    sleep $sleep_time
    
    ((cycle++))
done
