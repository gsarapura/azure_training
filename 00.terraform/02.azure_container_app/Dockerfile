FROM python:3.12-alpine3.20

# Set environment variables
ENV NON_ROOT_USER=dbtuser
ENV DBT_DIR=/home/$NON_ROOT_USER
ENV PATH="${DBT_DIR}/.local/bin:${PATH}"

# Update and install system packages
RUN apk update && apk upgrade
#    apk add  --no-cache gcc

# Create a new user and switch to it
RUN adduser -D $NON_ROOT_USER
USER $NON_ROOT_USER

# Set working directory
WORKDIR $DBT_DIR

# Install DBT
RUN pip install dbt-core==1.8.2

# Run dbt
CMD ["dbt", "--version"]
