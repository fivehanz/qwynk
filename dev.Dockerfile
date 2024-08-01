ARG ELIXIR_VERSION=1.17.2
ARG OTP_VERSION=27.0.1
ARG DEBIAN_VERSION=bookworm-20240722-slim
ARG BUN_VERSION=1.1.21

ARG ASSETS_BUILDER_IMAGE="oven/bun:${BUN_VERSION}-slim"
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"

################################################################################

FROM ${ASSETS_BUILDER_IMAGE} as assets_builder

WORKDIR /app

COPY assets assets
RUN cd assets && bun --bun install

################################################################################

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl unzip inotify-tools \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="dev"

#! https://elixirforum.com/t/arm64-dockerfile-failing/57317/12
ENV ERL_FLAGS="+JPperf true"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get

COPY --from=assets_builder /app/assets assets

CMD ["mix", "phx.server"]

