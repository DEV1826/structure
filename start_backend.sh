#!/bin/bash
cd "$(dirname "$0")/structure_backend"
echo "🚀 Starting backend server..."
./mvnw spring-boot:run
