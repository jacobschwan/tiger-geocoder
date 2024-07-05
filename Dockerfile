FROM ghcr.io/degauss-org/geocoder:3.3.0

# ADD https://geomarker.s3.amazonaws.com/geocoder_2021.db /opt/geocoder.db
COPY geocoder_2023.db /opt/geocoder.db

WORKDIR /app

# COPY renv.lock .
# RUN R --quiet -e "renv::restore()"

# COPY geocode.rb .
COPY entrypoint.R .

WORKDIR /tmp

ENTRYPOINT ["/app/entrypoint.R"]
