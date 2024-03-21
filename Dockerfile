FROM rocker/verse:4.3.1 AS base
WORKDIR /usr/src/void
COPY . .
FROM base as setup
RUN apt update && apt upgrade -y
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
FROM setup AS renv
ENV RENV_PATHS_LIBRARY renv/library
RUN R -e "renv::restore()"
FROM setup as build
RUN make