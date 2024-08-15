# CloudMart API Documentation

## 🚀 **API Overview**

CloudMart provides a RESTful API for e-commerce operations with AI-powered customer support. The API is built with Node.js/Express and follows OpenAPI 3.0 specifications.

**Base URL**: `https://api.cloudmart.example.com/api`  
**Version**: v1.0.0  
**Authentication**: JWT Bearer Token  

## 📋 **API Endpoints**

### **Products API**

#### Get All Products
```http
GET /api/products
```

**Response:**
```json
{
  "success": true,
  "products": [
    {
      "id": "prod_123",
      "name": "Laptop Pro",
      "price": 999.99,
      "category": "Electronics",
      "description": "High-performance laptop",
      "stock": 50,
      "created_at": "2025-01-01T00:00:00Z"
    }
  ],
  "count": 1
}
```

#### Get Product by ID
```http
GET /api/products/{id}
```

### **Orders API**

#### Create Order
```http
POST /api/orders
```

**Request Body:**
```json
{
  "user_id": "user_123",
  "items": [
    {
      "product_id": "prod_123",
      "quantity": 2,
      "price": 999.99
    }
  ],
  "total_amount": 1999.98
}
```

#### Get User Orders
```http
GET /api/orders/user/{user_id}
```

### **AI Support API**

#### Submit Support Request
```http
POST /api/ai/support
```

**Request Body:**
```json
{
  "message": "I need help with my order",
  "user_id": "user_123",
  "ticket_id": "ticket_456"
}
```

**Response:**
```json
{
  "success": true,
  "response": "I'd be happy to help you with your order. Could you please provide your order number?",
  "ticket_id": "ticket_456",
  "confidence": 0.95,
  "response_time_ms": 1250
}
```

### **Support Tickets API**

#### Get All Tickets
```http
GET /api/tickets
```

#### Get Ticket by ID
```http
GET /api/tickets/{id}
```

## 🔒 **Authentication**

All API endpoints require authentication using JWT Bearer tokens.

**Header:**
```http
Authorization: Bearer <your_jwt_token>
```

## 📊 **Rate Limiting**

- **Development**: 100 requests per minute
- **Production**: 1000 requests per minute

## 🚨 **Error Handling**

**Error Response Format:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": {
      "field": "user_id",
      "issue": "Required field missing"
    }
  },
  "timestamp": "2025-01-01T00:00:00Z"
}
```

## 📈 **Monitoring & Health**

#### Health Check
```http
GET /health
```

#### Metrics Endpoint
```http
GET /metrics
```
