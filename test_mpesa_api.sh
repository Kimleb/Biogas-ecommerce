#!/bin/bash

# Test M-Pesa Payment Initiation API
# Backend URL: https://eminently-rare-pegasus.ngrok-free.app/api

echo "Testing M-Pesa Payment Initiation API..."
echo "========================================"

# Base URL
BASE_URL="https://eminently-rare-pegasus.ngrok-free.app/api"

# Test payment data
PAYLOAD='{
    "booking_id": "test_booking_123",
    "customer_id": "customer_456",
    "customer_name": "John Doe",
    "customer_email": "john.doe@example.com",
    "customer_phone": "+254712345678",
    "service_name": "Biogas Installation",
    "amount": 2500.0,
    "service_fee": 2000.0,
    "platform_fee": 500.0
}'

echo "Endpoint: $BASE_URL/mpesa/initiate/"
echo "Method: POST"
echo "Payload:"
echo "$PAYLOAD"
echo ""
echo "Curl Command:"
echo "curl -X POST \"$BASE_URL/mpesa/initiate/\" \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '$PAYLOAD'"
echo ""

# Execute the curl command
curl -X POST "$BASE_URL/mpesa/initiate/" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"

echo ""
echo "========================================"
echo "Test completed!"
