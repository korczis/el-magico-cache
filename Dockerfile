# Use the official Elixir Alpine image as the base image
FROM elixir:alpine

# Set the working directory
WORKDIR /app

ENV MIX_ENV=prod

RUN mix local.hex --force
RUN mix local.rebar --force

# Copy the mix.exs and mix.lock files to the container
COPY mix.* ./

# Install dependencies
RUN mix do deps.get, deps.compile, docs

# Copy the rest of the application code to the container
COPY . .

# Build the release
RUN mix release --overwrite

# Use a minimal Alpine image as the final image
FROM alpine:latest

ENV MIX_ENV=prod

# Set the working directory
WORKDIR /app

# Copy the built release from the previous stage
COPY --from=0 /app/_build/${MIX_ENV}/rel/el_magico_cache .

# Expose the necessary ports
EXPOSE 4000

# Run the application
CMD ["./bin/my_app", "start"]
