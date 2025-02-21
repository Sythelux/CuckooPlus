FROM node:20-slim AS base
COPY . /app
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@9

FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

FROM python:3
COPY --from=build /app/dist /app
WORKDIR /app
EXPOSE 80
ENTRYPOINT ["python3", "-m", "http.server", "80"]
