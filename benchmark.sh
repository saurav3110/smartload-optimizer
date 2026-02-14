#!/bin/bash

# Simple performance benchmark test for SmartLoad Optimization API
BASE_URL="http://localhost:8080"

echo "⏱️  Performance Benchmark - SmartLoad Optimization API"
echo "========================================================"

# Test with 10 orders
echo -e "\n🔍 Benchmark with 10 orders:"
time curl -s -X POST "$BASE_URL/api/v1/load-optimizer/optimize" \
  -H "Content-Type: application/json" \
  -d '{
    "truck": {
      "id": "truck-bench",
      "max_weight_lbs": 44000,
      "max_volume_cuft": 3000
    },
    "orders": [
      {"id":"ord-1","payout_cents":250000,"weight_lbs":8000,"volume_cuft":600,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-2","payout_cents":180000,"weight_lbs":6000,"volume_cuft":500,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-3","payout_cents":320000,"weight_lbs":10000,"volume_cuft":800,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-4","payout_cents":150000,"weight_lbs":5000,"volume_cuft":400,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-5","payout_cents":200000,"weight_lbs":7000,"volume_cuft":550,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-6","payout_cents":190000,"weight_lbs":6500,"volume_cuft":480,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-7","payout_cents":220000,"weight_lbs":7500,"volume_cuft":600,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-8","payout_cents":170000,"weight_lbs":5500,"volume_cuft":450,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-9","payout_cents":210000,"weight_lbs":7200,"volume_cuft":580,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-10","payout_cents":160000,"weight_lbs":5300,"volume_cuft":420,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false}
    ]
  }' > /dev/null && echo "✅ Success"

# Test with 15 orders
echo -e "\n🔍 Benchmark with 15 orders:"
time curl -s -X POST "$BASE_URL/api/v1/load-optimizer/optimize" \
  -H "Content-Type: application/json" \
  -d '{
    "truck": {"id":"truck-bench","max_weight_lbs":44000,"max_volume_cuft":3000},
    "orders": [
      {"id":"ord-1","payout_cents":250000,"weight_lbs":8000,"volume_cuft":600,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-2","payout_cents":180000,"weight_lbs":6000,"volume_cuft":500,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-3","payout_cents":320000,"weight_lbs":10000,"volume_cuft":800,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-4","payout_cents":150000,"weight_lbs":5000,"volume_cuft":400,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-5","payout_cents":200000,"weight_lbs":7000,"volume_cuft":550,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-6","payout_cents":190000,"weight_lbs":6500,"volume_cuft":480,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-7","payout_cents":220000,"weight_lbs":7500,"volume_cuft":600,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-8","payout_cents":170000,"weight_lbs":5500,"volume_cuft":450,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-9","payout_cents":210000,"weight_lbs":7200,"volume_cuft":580,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-10","payout_cents":160000,"weight_lbs":5300,"volume_cuft":420,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-11","payout_cents":185000,"weight_lbs":6200,"volume_cuft":510,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-12","payout_cents":215000,"weight_lbs":7300,"volume_cuft":590,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-13","payout_cents":195000,"weight_lbs":6700,"volume_cuft":530,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-14","payout_cents":165000,"weight_lbs":5700,"volume_cuft":440,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false},
      {"id":"ord-15","payout_cents":240000,"weight_lbs":8200,"volume_cuft":640,"origin":"LA, CA","destination":"DFW, TX","pickup_date":"2025-12-05","delivery_date":"2025-12-09","is_hazmat":false}
    ]
  }' > /dev/null && echo "✅ Success"

echo -e "\n=========================================================="
echo "✨ Benchmark tests completed!"
