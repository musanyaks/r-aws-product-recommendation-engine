FROM rocker/r-ver:4.4.1

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl libcurl4-openssl-dev libssl-dev libsodium-dev libpq-dev \
      libicu-dev libxml2-dev zlib1g-dev pkg-config libuv1-dev cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# renv config (copied first so this layer is cached until the lockfile changes)
COPY renv.lock .Rprofile ./
COPY renv/ renv/

# Sequential installs; copy packages into the project library instead of
# symlinking to a global cache (the cache would not exist in the final image)
ENV RENV_CONFIG_INSTALL_PARALLEL=FALSE \
    RENV_CONFIG_CACHE_ENABLED=FALSE \
    RENV_CONFIG_REPOS_OVERRIDE=https://packagemanager.posit.co/cran/__linux__/jammy/latest

# Restore all packages (retry once to absorb the ggplot2/tibble ordering glitch)
RUN R -e "options(Ncpus = 1); renv::restore(exclude = 'ggplot2')"
RUN R -e "renv::restore(packages = 'ggplot2')"

# Application code (after the dependency layer so code edits don't rebuild it)
COPY R/ R/
COPY api/ api/
COPY run_api.R .

EXPOSE 8000
CMD ["Rscript", "run_api.R"]