# SmartLoad Optimization API

A high-performance REST API service for optimizing truck load planning. Given a truck's weight and volume capacity, the service determines the optimal combination of orders that maximizes revenue while respecting constraints (weight, volume, hazmat, route compatibility, and time windows).

## Technical Stack

- **Framework**: NestJS with Fastify adapter (for high performance)
- **Algorithm**: Dynamic Programming with bitmask enumeration (O(2^n) for n ≤ 22 orders)
- **Language**: TypeScript
- **Runtime**: Node.js 20 Alpine
- **Containerization**: Docker (multi-stage build)

## Algorithm Details

### Dynamic Programming Optimization

The service uses a **bitmask-based dynamic programming approach** to solve the multi-constraint knapsack problem:

- **State Space**: 2^n possible combinations (where n ≤ 22 orders)
- **Complexity**: O(2^n × constraint_checks) ≈ 4-10M operations for n=22
- **Performance Target**: < 800ms response time on 22 orders
- **Optimality**: Guarantees optimal solution (maximum revenue)

### Constraint Validation

Orders are filtered before optimization to ensure feasibility:

1. **Route Compatibility**: All orders must have the same origin → destination
2. **Hazmat Isolation**: Cannot mix hazmat and non-hazmat orders
3. **Time Windows**: Pickup date ≤ delivery date for all orders
4. **Weight/Volume Capacity**: Total must not exceed truck limits

### Financial Accuracy

- All monetary amounts handled as **integer cents** (BigInt)
- No floating-point arithmetic to avoid precision loss
- Supports up to $92 quadrillion in revenue

## How to Run

### Prerequisites

- Docker and Docker Compose installed
- Git

### Quick Start

```bash
# Clone the repository
git clone <your-repo-url>
cd smartload-optimizer

# Start the service
docker compose up --build

# Service will be available at http://localhost:8080
```

### Local Development (without Docker)

```bash
# Install dependencies
npm install

# Build
npm run build

# Run
npm start

# Development mode with auto-reload
npm run start:dev

# Run tests
npm test

# Run e2e tests
npm run test:e2e
```

## API Endpoints

### Health Check

```bash
# Multiple health check endpoints (choose any)
curl http://localhost:8080/actuator/health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2026-02-11T23:30:00.000Z"
}
```

### Load Optimization

**Endpoint**: `POST /api/v1/load-optimizer/optimize`

#### Request Example

```bash
curl -X POST http://localhost:8080/api/v1/load-optimizer/optimize \
  -H "Content-Type: application/json" \
  -d @sample-request.json
```

#### Request Schema

```json
{
  "truck": {
    "id": "string",
    "max_weight_lbs": number,
    "max_volume_cuft": number
  },
  "orders": [
    {
      "id": "string",
      "payout_cents": number,
      "weight_lbs": number,
      "volume_cuft": number,
      "origin": "string (city, state)",
      "destination": "string (city, state)",
      "pickup_date": "string (YYYY-MM-DD)",
      "delivery_date": "string (YYYY-MM-DD)",
      "is_hazmat": boolean
    }
  ]
}
```

#### Response Schema (200 OK)

```json
{
  "truck_id": "string",
  "selected_order_ids": ["string"],
  "total_payout_cents": number,
  "total_weight_lbs": number,
  "total_volume_cuft": number,
  "utilization_weight_percent": number,
  "utilization_volume_percent": number
}
```

#### Example Request

See [sample-request.json](./sample-request.json)

#### Example Response

```json
{
  "truck_id": "truck-123",
  "selected_order_ids": ["ord-001", "ord-002"],
  "total_payout_cents": 430000,
  "total_weight_lbs": 30000,
  "total_volume_cuft": 2100,
  "utilization_weight_percent": 68.18,
  "utilization_volume_percent": 70.0
}
```

## Error Handling

### HTTP Status Codes

- **200 OK**: Successful optimization
- **400 Bad Request**: Invalid input (validation errors)
  - Missing required fields
  - Invalid data types
  - Negative or zero capacities
  - Invalid date formats
- **413 Payload Too Large**: Request body exceeds size limit
- **500 Internal Server Error**: Unexpected server error

### Error Response Format

```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "timestamp": "2026-02-11T23:30:00.000Z",
  "path": "/api/v1/load-optimizer/optimize",
  "errors": [
    {
      "field": "truck.max_weight_lbs",
      "message": "max_weight_lbs must be a positive number"
    }
  ]
}
```

## Performance Characteristics

### Benchmarks

- **n=10 orders**: ~5-10ms
- **n=15 orders**: ~50-100ms
- **n=20 orders**: ~300-500ms
- **n=22 orders**: ~600-800ms

### Optimization Techniques

1. **Early Feasibility Filtering**: Remove individually infeasible orders before DP
2. **Constraint Matrix Pre-computation**: Pre-build route and hazmat compatibility lookups
3. **Bitmask Operations**: Fast bit manipulation for state transitions
4. **Memoization**: Cache subproblem results (optional for repeated queries)
5. **Platform Optimization**: Fastify instead of Express for 2x better throughput

## Project Structure

```
smartload-optimizer/
├── src/
│   ├── common/
│   │   └── filters/
│   │       └── all-exceptions.filter.ts
│   ├── modules/
│   │   ├── load-optimizer/
│   │   │   ├── dto/
│   │   │   │   ├── load-optimizer.dto.ts
│   │   │   │   └── load-optimizer-response.dto.ts
│   │   │   ├── services/
│   │   │   │   ├── load-optimizer.service.ts
│   │   │   │   └── constraint-validation.service.ts
│   │   │   ├── load-optimizer.controller.ts
│   │   │   └── load-optimizer.module.ts
│   │   └── health/
│   │       ├── health.controller.ts
│   │       └── health.module.ts
│   ├── app.controller.ts
│   ├── app.module.ts
│   ├── app.service.ts
│   └── main.ts
├── test/
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── package.json
├── tsconfig.json
└── README.md
```

## Configuration

### Environment Variables

- `PORT`: Server port (default: 8080)
- `NODE_ENV`: Environment mode (production/development, default: production)
- `LOG_LEVEL`: Logging level (debug/info/warn/error, default: debug)
- `NODE_OPTIONS`: Node.js options (default: --max-old-space-size=256)

### Docker Compose Configuration

- **Memory Limit**: 2GB
- **CPU Limit**: 1.0 core
- **Read-only Filesystem**: Yes (for security)
- **Temporary Storage**: /tmp and /app/.nest tmpfs mounts
- **Health Check**: Every 30 seconds with 3-second timeout

## Testing

### Unit Tests

```bash
npm test
```

### E2E Tests

```bash
npm run test:e2e
```

### Manual Testing

```bash
# Run the service
docker compose up

# In another terminal, test the API
curl -X POST http://localhost:8080/api/v1/load-optimizer/optimize \
  -H "Content-Type: application/json" \
  -d @sample-request.json

# Check health
curl http://localhost:8080/health
```

## Design Decisions

### Why Dynamic Programming with Bitmask?

For n ≤ 22 orders, bitmask DP is the optimal choice:
- Guarantees optimal solution in bounded time
- 2^22 = ~4.2M operations fits comfortably in <800ms
- Simpler implementation than branch-and-bound
- Better performance than recursive backtracking without memoization

### Why Fastify over Express?

- 2-3x faster throughput per NestJS benchmarks
- Lower memory footprint
- Better streaming and compression support
- Fits 800ms response time target

### Why BigInt for Money?

- JavaScript number type loses precision for large integers (2^53 limit)
- BigInt provides arbitrary precision
- Eliminates floating-point rounding errors
- Integer arithmetic is deterministic

### Why Stateless (In-Memory Only)?

- REST API best practice for horizontal scaling
- No database overhead (faster response times)
- Optional Redis caching for repeated queries (future enhancement)
- Simpler deployment and testing

## Future Enhancements

1. **Pareto Optimization**: Return multiple trade-offs (max revenue vs max utilization)
2. **Redis Caching**: Cache results for identical truck+order combinations
3. **Advanced Pruning**: Meet-in-the-middle DP for n > 25
4. **Multi-objective Optimization**: Configurable weights for different objective functions
5. **Time-window Conflict Detection**: More sophisticated scheduling analysis
6. **Metrics/Observability**: Prometheus metrics, distributed tracing

## Troubleshooting

### Service Won't Start

```bash
# Check logs
docker compose logs -f smartload-optimizer

# Verify port 8080 is available
lsof -i :8080
```

### High Memory Usage

- Increase memory limit in docker-compose.yml
- Reduce `NODE_OPTIONS` max-old-space-size
- Consider splitting large optimization batches

### Slow Response Time

- Check CPU utilization
- Verify order count (should be ≤ 22)
- Ensure no other processes competing for resources

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure tests pass: `npm test`
5. Submit a pull request

## License

MIT
