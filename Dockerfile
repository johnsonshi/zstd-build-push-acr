FROM alpine:latest

# Build-time input (pass value at build time)
ARG BUILD_TS

# Create a file so this additional layer changes every build
RUN printf "built_at=%s\nrandom=%s\n" "${BUILD_TS:-unset}" > /etc/build-stamp
