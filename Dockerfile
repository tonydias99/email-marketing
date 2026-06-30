# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder
WORKDIR /app

# Install git (needed to fetch submodule)
RUN apk add --no-cache git

# Copy package files (from the repo root)
COPY package*.json ./

# Clone the email-builder-js submodule (archive doesn't include submodule content)
RUN git clone --depth 1 https://github.com/usewaypoint/email-builder-js.git email-builder

# Install dependencies (including workspaces)
RUN npm install

# Copy the rest of the application source
COPY . .

# Build the example app (Vite + MUI)
RUN npm run build --workspace=examples/vite-emailbuilder-mui

# ---- Runtime stage ----
FROM node:20-alpine
WORKDIR /app
RUN npm install -g serve
COPY --from=builder /app/examples/vite-emailbuilder-mui/dist ./dist
EXPOSE 3000
CMD ["serve", "-s", "dist", "-l", "3000"]