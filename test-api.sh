#!/bin/bash

# Test script for SmartLoad Optimization API

BASE_URL="http://localhost:8080"

echo "🧪 Testing SmartLoad Optimization API"
echo "======================================"

# Test 1: Health Check
echo -e "\n✅ Test 1: Health Check"
curl -s "$BASE_URL/health" | jq .
echo ""

# Test 2: Basic Optimization
echo "✅ Test 2: Basic Optimization (sample-request.json)"
curl -s -X POST "$BASE_URL/api/v1/load-optimizer/optimize" \
  -H "Content-Type: application/json" \
  -d '{
    "truck": {
      "id": "truck-123",
      "max_weight_lbs": 44000,
      "max_volume_cuft": 3000
    },
    "orders": [
      {
        "id": "ord-001",
        "payout_cents": 250000,
        "weight_lbs": 18000,
        "volume_cuft": 1200,
        "origin": "Los Angeles, CA",
        "destination": "Dallas, TX",
        "pickup_date": "2025-12-05",
        "delivery_date": "2025-12-09",
        "is_hazmat": false
      },
      {
        "id": "ord-002",
        "payout_cents": 180000,
        "weight_lbs": 12000,
        "volume_cuft": 900,
        "origin": "Los Angeles, CA",
        "destination": "Dallas, TX",
        "pickup_date": "2025-12-04",
        "delivery_date": "2025-12-10",
        "is_hazmat": false
      },
      {
        "id": "ord-003",
        "payout_cents": 320000,
        "weight_lbs": 30000,
        "volume_cuft": 1800,
        "origin": "Los Angeles, CA",
        "destination": "Dallas, TX",
        "pickup_date": "2025-12-06",
        "delivery_date": "2025-12-08",
        "is_hazmat": true
      }
    ]
  }' | jq .
echo ""

# Test 3: Empty Orders
echo "✅ Test 3: Empty Orders List"
curl -s -X POST "$BASE_URL/api/v1/load-optimizer/optimize" \
  -H "Content-Type: application/json" \
  -d '{
    "truck": {
      "id": "truck-456",
      "max_weight_lbs": 44000,
      "max_volume_cuft": 3000
    },
    "orders": []
  }' | jq .
echo ""

# Test 4: Hazmat Isolation Test
echo "✅ Test 4: Hazmat Isolation (cannot mix hazmat with non-hazmat)"
curl -s -X POST "$BASE_URL/api/v1/load-optimizer/optimize" \
  -H "Content-Type: application/json" \
  -d '{
    "truck": {
      "id": "truck-789",
      "max_weight_lbs": 50000,
      "max_volume_cuft": 4000
    },
    "orders": [
      {
        "id": "hazmat-001",
        "payout_cents": 500000,
        "weight_lbs": 15000,
        "volume_cuft": 800,
        "origin": "NYC, NY",
        "destination": "Boston, MA",
        "pickup_date": "2025-12-01",
        "delivery_date": "2025-12-02",
        "is_hazmat": true
      },
      {
        "id": "normal-001",
        "payout_cents": 300000,
        "weight_lbs": 10000,
        "volume_cuft": 600,
        "origin": "NYC, NY",
        "destination": "Boston, MA",
        "pickup_date": "2025-12-01",
        "delivery_date": "2025-12-02",
        "is_hazmat": false
      }
    ]
  }' | jq .
echo ""

# Test 5: Route Incompatibility
echo "✅ Test 5: Route Incompatibility (different destinations)"
curl -s -X POST "$BASE_URL/api/v1/load-optimizer/optimize" \
  -H "Content-Type: application/json" \
  -d '{
    "truck": {
      "id": "truck-999",
      "max_weight_lbs": 44000,
      "max_volume_cuft": 3000
    },
    "orders": [
      {
        "id": "route1-001",
        "payout_cents": 200000,
        "weight_lbs": 10000,
        "volume_cuft": 500,
        "origin": "Chicago, IL",
        "destination": "Denver, CO",
        "pickup_date": "2025-12-01",
        "delivery_date": "2025-12-05",
        "is_hazmat": false
      },
      {
        "id": "route2-001",
        "payout_cents": 250000,
        "weight_lbs": 12000,
        "volume_cuft": 700,
        "origin": "Chicago, IL",
        "destination": "Houston, TX",
        "pickup_date": "2025-12-01",
        "delivery_date": "2025-12-05",
        "is_hazmat": false
      }
    ]
  }' | jq .
echo ""

# Test 6: Weight Limit Exceeded
echo "✅ Test 6: Weight Limit Exceeded"
curl -s -X POST "$BASE_URL/api/v1/load-optimizer/optimize" \
  -H "Content-Type: application/json" \
  -d '{
    "truck": {
      "id": "truck-small",
      "max_weight_lbs": 10000,
      "max_volume_cuft": 3000
    },
    "orders": [
      {
        "id": "heavy-001",
        "payout_cents": 500000,
        "weight_lbs": 15000,
        "volume_cuft": 800,
        "origin": "SF, CA",
        "destination": "LA, CA",
        "pickup_date": "2025-12-01",
        "delivery_date": "2025-12-02",
        "is_hazmat": false
      }
    ]
  }' | jq .
echo ""

# Test 7: Invalid Request (validation error)
echo "✅ Test 7: Invalid Request (negative weight)"
curl -s -X POST "$BASE_URL/api/v1/load-optimizer/optimize" \
  -H "Content-Type: application/json" \
  -d '{
    "truck": {
      "id": "truck-invalid",
      "max_weight_lbs": 44000,
      "max_volume_cuft": 3000
    },
    "orders": [
      {
        "id": "invalid-001",
        "payout_cents": 100000,
        "weight_lbs": -5000,
        "volume_cuft": 500,
        "origin": "SF, CA",
        "destination": "LA, CA",
        "pickup_date": "2025-12-01",
        "delivery_date": "2025-12-02",
        "is_hazmat": false
      }
    ]
  }' | jq .
echo ""

echo "======================================"
echo "✨ All tests completed!"
