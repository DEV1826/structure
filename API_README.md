# API Documentation - Structure Backend

## Table of Contents
1. [Authentication](#authentication)
   - [Login](#login)
   - [Register](#register)
2. [Structures](#structures)
   - [Get All Structures](#get-all-structures)
   - [Get Structure by ID](#get-structure-by-id)
   - [Create Structure](#create-structure)
   - [Update Structure](#update-structure)
   - [Delete Structure](#delete-structure)
3. [Statistics](#statistics)
   - [Global Stats](#global-stats)
   - [Revenue Trend](#revenue-trend)
   - [Compare Periods](#compare-periods)
   - [Top Performing Structures](#top-performing-structures)
   - [Revenue by Category](#revenue-by-category)
4. [Error Handling](#error-handling)
5. [Authentication & Authorization](#authentication--authorization)

---

## Authentication

### Login

Authenticate a user and receive a JWT token.

**Endpoint**: `POST /api/auth/login`

**Request Body**:
```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "admin@example.com",
  "role": "ADMIN"
}
```

### Register

Register a new user (default role: USER).

**Endpoint**: `POST /api/auth/register`

**Request Body**:
```json
{
  "firstname": "John",
  "lastname": "Doe",
  "email": "john.doe@example.com",
  "password": "password123"
}
```

**Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "john.doe@example.com",
  "role": "USER"
}
```

---

## Structures

### Get All Structures

Retrieve a list of all structures.

**Endpoint**: `GET /api/structures`

**Response**:
```json
[
  {
    "id": 1,
    "name": "Structure 1",
    "address": "123 Main St",
    "isActive": true
  },
  {
    "id": 2,
    "name": "Structure 2",
    "address": "456 Oak Ave",
    "isActive": true
  }
]
```

### Get Structure by ID

Retrieve a specific structure by its ID.

**Endpoint**: `GET /api/structures/{id}`

**Response**:
```json
{
  "id": 1,
  "name": "Structure 1",
  "address": "123 Main St",
  "isActive": true
}
```

### Create Structure

Create a new structure (requires ADMIN role).

**Endpoint**: `POST /api/structures`

**Request Body**:
```json
{
  "name": "New Structure",
  "address": "789 Pine St",
  "isActive": true
}
```

**Response**:
```json
{
  "id": 3,
  "name": "New Structure",
  "address": "789 Pine St",
  "isActive": true
}
```

### Update Structure

Update an existing structure (requires ADMIN role).

**Endpoint**: `PUT /api/structures/{id}`

**Request Body**:
```json
{
  "name": "Updated Structure",
  "address": "Updated Address",
  "isActive": false
}
```

**Response**:
```json
{
  "id": 1,
  "name": "Updated Structure",
  "address": "Updated Address",
  "isActive": false
}
```

### Delete Structure

Delete a structure (requires ADMIN role).

**Endpoint**: `DELETE /api/structures/{id}`

**Response**: `204 No Content`

---

## Statistics

### Global Stats

Get global statistics (total transactions, revenue, etc.).

**Endpoint**: `GET /api/stats/global`

**Response**:
```json
{
  "totalTransactions": 150,
  "totalRevenue": 25000.0,
  "averageTransactionAmount": 166.67,
  "totalStructures": 5,
  "activeStructures": 4
}
```

### Revenue Trend

Get revenue trend data for a specific period.

**Endpoint**: `GET /api/stats/revenue-trend?startDate=2023-01-01&endDate=2023-12-31&groupBy=MONTH`

**Query Parameters**:
- `startDate`: Start date (yyyy-MM-dd)
- `endDate`: End date (yyyy-MM-dd)
- `groupBy`: Grouping period (DAY, WEEK, MONTH, YEAR)

**Response**:
```json
{
  "periods": ["Jan 2023", "Feb 2023", "Mar 2023"],
  "revenues": [1500.0, 2300.0, 3200.0]
}
```

### Compare Periods

Compare statistics between two periods.

**Endpoint**: `GET /api/stats/compare?period1Start=2023-01-01&period1End=2023-03-31&period2Start=2023-04-01&period2End=2023-06-30`

**Response**:
```json
{
  "period1": {
    "startDate": "2023-01-01",
    "endDate": "2023-03-31",
    "totalRevenue": 7000.0,
    "transactionCount": 42
  },
  "period2": {
    "startDate": "2023-04-01",
    "endDate": "2023-06-30",
    "totalRevenue": 8500.0,
    "transactionCount": 51
  },
  "revenueChange": 21.43,
  "transactionChange": 21.43
}
```

### Top Performing Structures

Get top performing structures by revenue.

**Endpoint**: `GET /api/stats/top-structures?limit=5&startDate=2023-01-01&endDate=2023-12-31`

**Response**:
```json
[
  {
    "structureId": 1,
    "structureName": "Structure A",
    "revenue": 12000.0,
    "transactionCount": 80
  },
  {
    "structureId": 3,
    "structureName": "Structure C",
    "revenue": 9800.0,
    "transactionCount": 65
  }
]
```

### Revenue by Category

Get revenue breakdown by service category.

**Endpoint**: `GET /api/stats/revenue-by-category?startDate=2023-01-01&endDate=2023-12-31`

**Response**:
```json
[
  {
    "category": "Food & Beverage",
    "revenue": 15000.0,
    "percentage": 60.0
  },
  {
    "category": "Accommodation",
    "revenue": 8000.0,
    "percentage": 32.0
  },
  {
    "category": "Activities",
    "revenue": 2000.0,
    "percentage": 8.0
  }
]
```

---

## Error Handling

The API returns standardized error responses in the following format:

```json
{
  "timestamp": "2023-08-13T21:30:00Z",
  "status": 404,
  "error": "Not Found",
  "message": "Structure not found with id: 999",
  "path": "/api/structures/999"
}
```

Common HTTP status codes:
- `200 OK`: Request successful
- `201 Created`: Resource created successfully
- `204 No Content`: Resource deleted successfully
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

---

## Authentication & Authorization

### JWT Authentication
All protected endpoints require a valid JWT token in the `Authorization` header:
```
Authorization: Bearer <token>
```

### Roles
- `ROLE_USER`: Basic user access (read-only)
- `ROLE_ADMIN`: Full access to all operations for assigned structure
- `ROLE_SUPER_ADMIN`: Full access to all operations across all structures

### Protected Endpoints
- All `POST`, `PUT`, `DELETE` operations require `ROLE_ADMIN` or higher
- User management endpoints require `ROLE_SUPER_ADMIN`

### Token Expiration
- Access tokens expire after 24 hours
- Refresh tokens (if implemented) expire after 7 days

---

## Rate Limiting
- 100 requests per minute per IP address
- 1000 requests per hour per authenticated user

## Caching
- GET responses are cached for 5 minutes
- Cache is automatically invalidated on data modification

## Versioning
- API versioning is handled through the URL path: `/api/v1/...`
- Current version: v1

## Testing
Run the test suite with:
```bash
./mvnw test
```

## Deployment
Deploy using Docker:
```bash
docker build -t structure-backend .
docker run -p 8080:8080 structure-backend
```

## Environment Variables
- `DATABASE_URL`: JDBC connection URL
- `DATABASE_USERNAME`: Database username
- `DATABASE_PASSWORD`: Database password
- `JWT_SECRET`: Secret key for JWT signing
- `JWT_EXPIRATION`: JWT expiration time in milliseconds
- `CACHE_ENABLED`: Enable/disable caching (true/false)

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
