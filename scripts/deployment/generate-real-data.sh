#!/bin/bash

echo "🚀 CloudMart Real Application Data Generator"
echo "Generating realistic e-commerce and AI activity..."

# Function to simulate customer interactions
simulate_customer_journey() {
    local customer_id=$1
    echo "👤 Customer $customer_id journey:"
    
    # Browse products
    curl -s "https://app.cloudmartsaid.shop/api/products" > /dev/null
    echo "  - Browsed products"
    sleep 1
    
    # Get AI product recommendation
    curl -s -X POST "https://app.cloudmartsaid.shop/api/ai/start" \
        -H "Content-Type: application/json" \
        -d "{\"message\":\"Recommend products for customer interested in electronics\"}" > /dev/null
    echo "  - Got AI recommendation"
    sleep 2
    
    # Check order status
    curl -s "https://app.cloudmartsaid.shop/api/orders" > /dev/null
    echo "  - Checked orders"
    sleep 1
    
    # AI sentiment analysis of customer feedback
    feedbacks=("Great product quality!" "Fast shipping, very satisfied" "Excellent customer service" "Love the AI recommendations" "Amazing shopping experience")
    feedback=${feedbacks[$((RANDOM % ${#feedbacks[@]}))]}
    
    curl -s -X POST "https://app.cloudmartsaid.shop/api/ai/analyze-sentiment" \
        -H "Content-Type: application/json" \
        -d "{\"thread\":{\"messages\":[{\"text\":\"$feedback\",\"sender\":\"user\"}]}}" > /dev/null
    echo "  - Provided feedback: '$feedback'"
    sleep 1
}

# Function to simulate business operations
simulate_business_operations() {
    echo "🏢 Business operations:"
    
    # Admin checking system health
    curl -s "https://app.cloudmartsaid.shop/health" > /dev/null
    curl -s "https://app.cloudmartsaid.shop/ready" > /dev/null
    echo "  - Health checks performed"
    
    # Business intelligence queries
    curl -s -X POST "https://app.cloudmartsaid.shop/api/ai/bedrock/start" \
        -H "Content-Type: application/json" \
        -d '{"message":"Analyze sales trends and customer behavior patterns"}' > /dev/null
    echo "  - Business intelligence analysis"
    sleep 2
    
    # Inventory management
    curl -s "https://app.cloudmartsaid.shop/api/products" > /dev/null
    echo "  - Inventory check"
    sleep 1
}

# Function to simulate some errors (realistic scenario)
simulate_realistic_errors() {
    echo "⚠️  Simulating realistic error scenarios:"
    
    # Some 404 errors (users typing wrong URLs)
    curl -s "https://app.cloudmartsaid.shop/api/product/nonexistent" > /dev/null
    curl -s "https://app.cloudmartsaid.shop/wrong-page" > /dev/null
    echo "  - User navigation errors (404s)"
    
    # Rate limiting scenarios
    for i in {1..3}; do
        curl -s "https://app.cloudmartsaid.shop/api/products" > /dev/null &
    done
    wait
    echo "  - High traffic simulation"
}

# Main simulation loop
echo "🎯 Starting realistic application simulation..."
echo "Press Ctrl+C to stop"

iteration=1
while true; do
    echo -e "\n🔄 Simulation cycle $iteration ($(date))"
    
    # Simulate 3-5 concurrent customers
    num_customers=$((3 + RANDOM % 3))
    echo "Simulating $num_customers concurrent customers..."
    
    for i in $(seq 1 $num_customers); do
        simulate_customer_journey $i &
    done
    
    # Business operations
    simulate_business_operations &
    
    # Occasional errors (10% chance)
    if [ $((RANDOM % 10)) -eq 0 ]; then
        simulate_realistic_errors &
    fi
    
    # Wait for all background processes
    wait
    
    echo "✅ Cycle $iteration completed"
    
    # Wait before next cycle (30-60 seconds)
    sleep_time=$((30 + RANDOM % 30))
    echo "⏳ Waiting ${sleep_time}s before next cycle..."
    sleep $sleep_time
    
    ((iteration++))
done
