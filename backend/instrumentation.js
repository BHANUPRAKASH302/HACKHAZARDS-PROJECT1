const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');
const { HttpInstrumentation } = require('@opentelemetry/instrumentation-http');
const { ExpressInstrumentation } = require('@opentelemetry/instrumentation-express');
const { MongoDBInstrumentation } = require('@opentelemetry/instrumentation-mongodb');
const { RedisInstrumentation } = require('@opentelemetry/instrumentation-redis-4');
const { SequelizeInstrumentation } = require('@opentelemetry/instrumentation-sequelize');
const dotenv = require('dotenv');

dotenv.config();

// Create trace exporter pointing to Jaeger OTLP receiver
const traceExporter = new OTLPTraceExporter({
  url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4317',
});

// Configure Node SDK with all instrumentations
const sdk = new NodeSDK({
  serviceName: process.env.OTEL_SERVICE_NAME || 'vynedam-backend',
  traceExporter: traceExporter,
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
    new MongoDBInstrumentation(),
    new RedisInstrumentation(),
    new SequelizeInstrumentation()
  ],
});

// Start tracing SDK
sdk.start();

console.log('OpenTelemetry SDK initialized successfully.');

process.on('SIGTERM', () => {
  sdk.shutdown()
    .then(() => console.log('Tracing SDK terminated'))
    .catch((error) => console.error('Error terminating tracing SDK', error))
    .finally(() => process.exit(0));
});

module.exports = sdk;
