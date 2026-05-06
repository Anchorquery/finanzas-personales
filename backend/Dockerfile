FROM directus/directus:11.0.0

USER root

# Copy extensions and migrations into the image
# This ensures that they are part of the deployment package
COPY ./extensions /directus/extensions
COPY ./migrations /directus/migrations

# Ensure the directus user has permissions to these folders
RUN chown -R directus:directus /directus/extensions /directus/migrations

USER directus
