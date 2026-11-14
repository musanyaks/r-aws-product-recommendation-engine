FROM rocker/r-ver:4.4.1

RUN apt-get update && apt-get install -y --no-install-recommends \
      libpq-dev libcurl4-openssl-dev libssl-dev libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY renv.lock .Rprofile ./
COPY renv/ renv/
RUN R -e "renv::restore()"

COPY R/ R/
COPY api/ api/
COPY run_api.R .

EXPOSE 8000
CMD ["Rscript", "run_api.R"]