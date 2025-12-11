# TogetherLog API Documentation

REST API endpoints for TogetherLog backend, implemented as Supabase Edge Functions.

## Base URL

```
https://your-project.supabase.co/functions/v1
```

## Authentication

All API endpoints (except OPTIONS for CORS) require authentication via Supabase Auth.

**Required Header:**
```
Authorization: Bearer <your-access-token>
```

Get the access token from Supabase Auth after login.

---

## Logs API

### List All Logs

Get all logs for the authenticated user.

```http
GET /logs
```

**Response (200):**
```json
{
  "logs": [
    {
      "id": "uuid",
      "name": "Our Adventure",
      "type": "Couple",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z",
      "entry_count": 42
    }
  ]
}
```

---

### Get Single Log

Get a specific log by ID.

```http
GET /logs/:id
```

**Parameters:**
- `id` (path) - UUID of the log

**Response (200):**
```json
{
  "log": {
    "id": "uuid",
    "name": "Our Adventure",
    "type": "Couple",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z",
    "entry_count": 42
  }
}
```

**Errors:**
- `404` - Log not found
- `400` - Invalid log ID format

---

### Create Log

Create a new log.

```http
POST /logs
```

**Request Body:**
```json
{
  "name": "Our Adventure",
  "type": "Couple"
}
```

**Fields:**
- `name` (required) - Log name (1-100 characters)
- `type` (optional) - Log type: `Couple`, `Friends`, `Family`, `Solo`, `Other` (default: `Couple`)

**Response (201):**
```json
{
  "log": {
    "id": "uuid",
    "name": "Our Adventure",
    "type": "Couple",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

**Errors:**
- `400` - Validation error (invalid name or type)

---

### Update Log

Update an existing log.

```http
PATCH /logs/:id
```

**Parameters:**
- `id` (path) - UUID of the log

**Request Body:**
```json
{
  "name": "Updated Name",
  "type": "Friends"
}
```

**Fields (all optional):**
- `name` - Log name (1-100 characters)
- `type` - Log type: `Couple`, `Friends`, `Family`, `Solo`, `Other`

**Response (200):**
```json
{
  "log": {
    "id": "uuid",
    "name": "Updated Name",
    "type": "Friends",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-02T00:00:00Z"
  }
}
```

**Errors:**
- `404` - Log not found
- `400` - Validation error or no fields to update
- `400` - Invalid log ID format

---

### Delete Log

Delete a log and all its entries (cascade).

```http
DELETE /logs/:id
```

**Parameters:**
- `id` (path) - UUID of the log

**Response (200):**
```json
{
  "message": "Log deleted successfully"
}
```

**Errors:**
- `400` - Invalid log ID format

**Note:** Deleting a log will also delete all associated entries and photos (CASCADE).

---

## Error Responses

All errors follow this format:

```json
{
  "error": "Error message description"
}
```

**Common HTTP Status Codes:**
- `200` - Success
- `201` - Created
- `400` - Bad Request (validation error, invalid input)
- `401` - Unauthorized (missing or invalid auth token)
- `404` - Not Found
- `405` - Method Not Allowed
- `500` - Internal Server Error

---

## CORS

All endpoints support CORS with the following headers:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Headers: authorization, x-client-info, apikey, content-type
Access-Control-Allow-Methods: GET, POST, PATCH, DELETE, OPTIONS
```

OPTIONS requests are handled automatically for preflight checks.

---

## Rate Limiting

Rate limiting is handled by Supabase. Check Supabase documentation for current limits.

---

## Examples

### Create a Log

```bash
curl -X POST https://your-project.supabase.co/functions/v1/logs \
  -H "Authorization: Bearer your-token" \
  -H "Content-Type: application/json" \
  -d '{"name":"Summer Vacation 2024","type":"Friends"}'
```

### List Logs

```bash
curl -X GET https://your-project.supabase.co/functions/v1/logs \
  -H "Authorization: Bearer your-token"
```

### Update a Log

```bash
curl -X PATCH https://your-project.supabase.co/functions/v1/logs/uuid-here \
  -H "Authorization: Bearer your-token" \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Name"}'
```

### Delete a Log

```bash
curl -X DELETE https://your-project.supabase.co/functions/v1/logs/uuid-here \
  -H "Authorization: Bearer your-token"
```

---

## Next Steps

- **Entries API** - MILESTONE 5
- **Worker Functions** - MILESTONE 6
- **Smart Pages Engine** - MILESTONE 7

---

## Security

- All endpoints use Row Level Security (RLS) - users can only access their own data
- Authentication required for all operations
- Input validation on all fields
- UUID validation for IDs
- Type validation for log types

---

## Development

### Local Testing

```bash
# Start Supabase locally
supabase start

# Serve the logs function
supabase functions serve logs

# Test with curl
curl -X GET http://localhost:54321/functions/v1/logs \
  -H "Authorization: Bearer your-local-token"
```

### Deployment

```bash
# Deploy logs function
supabase functions deploy logs

# Deploy all functions
supabase functions deploy
```

---

For more information, see the [backend README](../../README.md).
