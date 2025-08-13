#!/bin/bash

# Integration Tests Script for Nervus Authentication Service
# This script runs integration tests in the CI environment

set -e

echo "🧪 Starting Integration Tests for Authentication Service..."

# Load configuration from environment or use defaults
SERVICE_PORT=${SERVICE_PORT:-8080}
HEALTH_PATH=${HEALTH_PATH:-/actuator/health}
DB_TYPE=${DB_TYPE:-postgresql}
DEPENDS_ON_EUREKA=${DEPENDS_ON_EUREKA:-true}

# Test 1: Database Connectivity
test_database_connectivity() {
    echo "📊 Testing Database Connectivity..."
    
    if [ "$DB_TYPE" = "postgresql" ]; then
        echo "Testing PostgreSQL connectivity..."
        if PGPASSWORD=secure_password psql -h localhost -U nervus_user -d nervus -c "SELECT 1" >/dev/null 2>&1; then
            echo "✅ PostgreSQL connectivity successful"
            
            # Test schema creation
            if PGPASSWORD=secure_password psql -h localhost -U nervus_user -d nervus -c "CREATE SCHEMA IF NOT EXISTS local_auth;" >/dev/null 2>&1; then
                echo "✅ Schema creation successful"
            else
                echo "❌ Schema creation failed"
                return 1
            fi
        else
            echo "❌ PostgreSQL connectivity failed"
            return 1
        fi
    else
        echo "⚠️ Database type $DB_TYPE not supported for integration tests"
    fi
    
    echo "✅ Database connectivity tests completed"
}

# Test 2: Infrastructure Services
test_infrastructure_services() {
    echo "🔧 Testing Infrastructure Services..."
    
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
    
    echo "✅ Infrastructure services tests completed"
}

# Test 3: Service Health and Endpoints
test_service_endpoints() {
    echo "🏥 Testing Service Health and Endpoints..."
    
    # Test main health endpoint
    if curl -sf "http://localhost:${SERVICE_PORT}${HEALTH_PATH}" >/dev/null 2>&1; then
        echo "✅ Main health endpoint working"
    else
        echo "❌ Main health endpoint failed"
        return 1
    fi
    
    # Test fallback health endpoint
    if curl -sf "http://localhost:${SERVICE_PORT}/health" >/dev/null 2>&1; then
        echo "✅ Fallback health endpoint working"
    else
        echo "ℹ️ Fallback health endpoint not available"
    fi
    
    echo "✅ Service endpoints tests completed"
}

# Test 4: Custom Authentication Service Tests
run_custom_tests() {
    echo "🔐 Running Custom Authentication Tests..."
    
    # Test if service is responding to basic requests
    echo "Testing basic service responsiveness..."
    if curl -sf "http://localhost:${SERVICE_PORT}${HEALTH_PATH}" >/dev/null 2>&1; then
        echo "✅ Service is responsive"
    else
        echo "❌ Service is not responsive"
        return 1
    fi
    
    # Test service info endpoint (if available)
    if curl -sf "http://localhost:${SERVICE_PORT}/actuator/info" >/dev/null 2>&1; then
        echo "✅ Service info endpoint accessible"
    else
        echo "ℹ️ Service info endpoint not available"
    fi
    
    echo "✅ Custom authentication tests completed"
}

# Main test execution
main() {
    echo "🚀 Running Integration Test Suite for Authentication Service..."
    
    test_database_connectivity
    test_infrastructure_services
    test_service_endpoints
    run_custom_tests
    
    echo "🎉 All Integration Tests Completed Successfully!"
}

main "$@"
