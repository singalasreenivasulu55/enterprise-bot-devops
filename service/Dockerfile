FROM python:3.12.10-slim-bookworm AS builder

WORKDIR /build

COPY app.py .
COPY requirements.txt .

RUN mkdir -p /install \
    && python -m pip install --no-cache-dir --target=/install -r requirements.txt

FROM python:3.12.10-slim-bookworm AS runtime

ENV PYTHONUNBUFFERED=1
ENV APP_NAME=demo
ENV VERSION=1.0.0
ENV PYTHONPATH=/install

WORKDIR /app

COPY --from=builder /build/app.py ./app.py
COPY --from=builder /install /install

RUN useradd --system --uid 10001 appuser \
    && chown -R appuser:appuser /app /install

USER 10001:10001

EXPOSE 8080

CMD ["python", "app.py"]
