FROM node:20-bookworm AS node-base
WORKDIR /app
RUN npm install -g @anthropic-ai/claude-code
