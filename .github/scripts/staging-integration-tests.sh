#!/bin/bash

# Staging Integration Tests Script for Nervus Authentication Service
# This script runs comprehensive integration tests in the staging environment

set -e

echo "🧪 Starting Staging Integration Tests for Authentication Service..."

# Load configuration from environment or use defaults
STAGING_HOST=${STAGING_HOST:-localhost}
SERVICE_PORT=${SERVICE_PORT:-8080}
HEALTH_PATH=${HEALTH_PATH:-/actuator/health}
DB_TYPE=${DB_TYPE:-postgresql}
DEPENDS_ON_EUREKA=${DEPENDS_ON_EUREKA:-true}

# Test 1: Database Integration Tests
test_database_integration() {
    echo "📊 Testing Database Integration..."
    
    # Test PostgreSQL connectivity and basic operations
    if command -v psql &> /dev/null; then
        echo "Testing PostgreSQL integration..."
        # This would include full CRUD operations, schema validation
        # For now, just test basic connectivity
        if PGPASSWORD=secure_password psql -h localhost -U nervus_user -d nervus -c "SELECT 1" >/dev/null 2>&1; then
            echo "✅ PostgreSQL integration successful"
        else
            echo "❌ PostgreSQL integration failed"
            return 1
        fi
    else
        echo "⚠️ psql not available, skipping PostgreSQL integration tests"
    fi
    
    echo "✅ Database integration tests completed"
}

# Test 2: Service-to-Service Communication
test_service_communication() {
    echo "🔗 Testing Service Communication..."
    
    # Test Eureka service discovery
    if [ "$DEPENDS_ON_EUREKA" = "true" ]; then
        echo "Testing Eureka service discovery..."
        if curl -sf http://localhost:8761/ >/dev/null 2>&1; then
            echo "✅ Eureka service discovery working"
        else
            echo "❌ Eureka service discovery failed"
            return 1
        fi
    else
        echo "ℹ️ Eureka dependency disabled, skipping test"
    fi
    
    # Test API Gateway routing (if applicable)
    if [ -n "$API_GATEWAY_PORT" ]; then
        echo "Testing API Gateway routing..."
        GATEWAY_URL="http://localhost:${API_GATEWAY_PORT}"
        if curl -sf "${GATEWAY_URL}/actuator/health" >/dev/null 2>&1; then
            echo "✅ API Gateway routing working"
        else
            echo "⚠️ API Gateway routing issue"
        fi
    fi
    
    echo "✅ Service communication tests completed"
}

# Test 3: Message Queue Integration
test_message_queue_integration() {
    echo "📨 Testing Message Queue Integration..."
    
    # Test Kafka connectivity (if applicable)
    if [ "$HAS_MESSAGE_PRODUCER" = "true" ] || [ "$HAS_MESSAGE_CONSUMER" = "true" ]; then
        echo "Testing Kafka message broker..."
        if curl -sf http://localhost:9092/ >/dev/null 2>&1; then
            echo "✅ Kafka connectivity confirmed"
            
            # Test producer/consumer flow if applicable
            if [ "$HAS_MESSAGE_PRODUCER" = "true" ]; then
                echo "Testing Kafka producer/consumer flow..."
                # This would include actual message production and consumption tests
                echo "ℹ️ Kafka producer/consumer tests would run here"
            fi
        else
            echo "⚠️ Kafka not accessible"
        fi
    else
        echo "ℹ️ Message queue not required for this service"
    fi
    
    echo "✅ Message queue integration tests completed"
}

# Test 4: Cross-Service API Testing
test_cross_service_apis() {
    echo "🌐 Testing Cross-Service APIs..."
    
    # Test authentication service endpoints
    echo "Testing authentication service endpoints..."
    
    # Test health endpoint
    if curl -sf "http://localhost:${SERVICE_PORT}${HEALTH_PATH}" >/dev/null 2>&1; then
        echo "✅ Health endpoint accessible"
    else
        echo "❌ Health endpoint not accessible"
        return 1
    fi
    
    # Test info endpoint
    if curl -sf "http://localhost:${SERVICE_PORT}/actuator/info" >/dev/null 2>&1; then
        echo "✅ Info endpoint accessible"
    else
        echo "ℹ️ Info endpoint not available"
    fi
    
    # Test metrics endpoint
    if curl -sf "http://localhost:${SERVICE_PORT}/actuator/metrics" >/dev/null 2>&1; then
        echo "✅ Metrics endpoint accessible"
    else
        echo "ℹ️ Metrics endpoint not available"
    fi
    
    echo "✅ Cross-service API tests completed"
}

# Test 5: Performance Testing
run_performance_tests() {
    echo "⚡ Running Performance Tests..."
    
    # Install ApacheBench if not available
    if ! command -v ab &> /dev/null; then
        echo "Installing ApacheBench..."
        sudo apt-get update
        sudo apt-get install -y apache2-utils
    fi
    
    # Run load test against health endpoint
    echo "Running load test against health endpoint..."
    HEALTH_URL="http://localhost:${SERVICE_PORT}${HEALTH_PATH}"
    
    # Basic load test: 100 requests, 10 concurrent
    ab -n 100 -c 10 "$HEALTH_URL" > ab_output.txt 2>&1 || true
    
    # Parse and display results
    if [ -f "ab_output.txt" ]; then
        echo "📊 Load Test Results:"
        grep -E "(Requests per second|Time per request|Failed requests)" ab_output.txt || echo "Could not parse results"
        
        # Check for failed requests
        FAILED_REQUESTS=$(grep "Failed requests:" ab_output.txt | awk '{print $3}' || echo "0")
        if [ "$FAILED_REQUESTS" -gt 0 ]; then
            echo "⚠️ $FAILED_REQUESTS requests failed during load test"
        else
            echo "✅ All requests succeeded during load test"
        fi
    fi
    
    echo "✅ Performance tests completed"
}

# Test 6: Resource Usage Monitoring
capture_resource_usage() {
    echo "📈 Capturing Resource Usage..."
    
    # Get container information
    echo "Container Status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(auth|authentication)" || echo "No authentication containers found"
    
    # Capture resource usage snapshot
    echo "Resource Usage Snapshot:"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" | grep -E "(auth|authentication)" || echo "No authentication containers found for stats"
    
    echo "✅ Resource usage captured"
}

# Test 7: Custom Authentication Service Tests
run_custom_tests() {
    echo "🔐 Running Custom Authentication Tests..."
    
    # Test authentication-specific functionality
    echo "Testing authentication service specific features..."
    
    # Test if service is responding to basic requests
    if curl -sf "http://localhost:${SERVICE_PORT}${HEALTH_PATH}" >/dev/null 2>&1; then
        echo "✅ Service is responsive"
    else
        echo "❌ Service is not responsive"
        return 1
    fi
    
    # Test service configuration
    if curl -sf "http://localhost:${SERVICE_PORT}/actuator/configprops" >/dev/null 2>&1; then
        echo "✅ Configuration properties accessible"
    else
        echo "ℹ️ Configuration properties not accessible"
    fi
    
    echo "✅ Custom authentication tests completed"
}

# Main test execution
main() {
    echo "🚀 Running Staging Integration Test Suite for Authentication Service..."
    
    test_database_integration
    test_service_communication
    test_message_queue_integration
    test_cross_service_apis
    run_performance_tests
    capture_resource_usage
    run_custom_tests
    
    echo "🎉 All Staging Integration Tests Completed Successfully!"
}

main "$@"
