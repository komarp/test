FROM python:3.8-buster as base
ARG PIP_EXTRA_INDEX_URL


RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
ENV PYTHONPATH=$PYTHONPATH:/usr/src/app/

COPY requirements/requirements.txt /requirements.txt

RUN pip3 install --no-cache-dir -r /requirements.txt


FROM base as dev
ARG PIP_EXTRA_INDEX_URL

#Azure related libs
COPY requirements/requirements.azure.txt /requirements.azure.txt
RUN pip3 install --no-cache-dir -r /requirements.azure.txt

COPY requirements/requirements.dev.txt /requirements.dev.txt
RUN pip3 install --no-cache-dir -r /requirements.dev.txt

CMD bash

FROM base as base_azure_service
ARG PIP_EXTRA_INDEX_URL

#Azure related libs
COPY requirements/requirements.azure.txt /requirements.azure.txt
RUN pip3 install --no-cache-dir -r /requirements.azure.txt


FROM base_azure_service as mediator_azure_service
COPY src/mediator /usr/src/app
WORKDIR /usr/src/app


FROM base_azure_service as fetcher_azure_service
COPY src/mock-fetcher /usr/src/app
WORKDIR /usr/src/app


FROM base as db_migration

COPY src/mediator /usr/src/app

WORKDIR /usr/src/app/solution/sp/mysql

CMD ["alembic", "upgrade", "head"]