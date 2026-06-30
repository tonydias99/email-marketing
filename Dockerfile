# ---- Build stage ----
FROM node:20-alpine AS builder
WORKDIR /app
# copy only package files to leverage cache
COPY package*.json ./
# initialize submodule and install
RUN apk add --no-cache git && \
    git submodule update --init --recursive && \
    npm ci
# copy source
COPY . .
# build the example app
RUN npm run build --workspace=examples/vite-emailbuilder-mui

# ---- Runtime stage ----
FROM node:20-alpine
WORKDIR /app
# install serve globally
RUN npm install -g serve
# copy built assets
COPY --from=builder /app/examples/vite-emailbuilder-mui/dist ./dist
EXPOSE 3000
CMD ["serve", "-s", "dist", "-l", "3000"]
