import promClient from 'prom-client';

// Create a Registry
const register = new promClient.Registry();

// Add default metrics
promClient.collectDefaultMetrics({ register });

// Custom AI Service Metrics
const aiRequestDuration = new promClient.Histogram({
  name: 'ai_request_duration_seconds',
  help: 'Duration of AI service requests in seconds',
  labelNames: ['service', 'model', 'endpoint'],
  buckets: [0.1, 0.5, 1, 2, 5, 10]
});

const aiRequestsTotal = new promClient.Counter({
  name: 'ai_requests_total',
  help: 'Total number of AI service requests',
  labelNames: ['service', 'model', 'status']
});

const aiTokensUsed = new promClient.Counter({
  name: 'ai_tokens_used_total',
  help: 'Total AI tokens consumed',
  labelNames: ['service', 'model', 'type']
});

const aiCostTotal = new promClient.Counter({
  name: 'ai_cost_total',
  help: 'Total AI service costs in USD',
  labelNames: ['service', 'model']
});

// Application Metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 5]
});

const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

// Business Metrics
const ordersTotal = new promClient.Counter({
  name: 'orders_total',
  help: 'Total number of orders',
  labelNames: ['status', 'payment_method']
});

const customerSatisfaction = new promClient.Gauge({
  name: 'customer_satisfaction_score',
  help: 'Customer satisfaction score from AI sentiment analysis',
  labelNames: ['category']
});

// Database Metrics
const databaseOperations = new promClient.Histogram({
  name: 'database_operation_duration_seconds',
  help: 'Duration of database operations',
  labelNames: ['operation', 'table', 'status'],
  buckets: [0.01, 0.05, 0.1, 0.2, 0.5, 1, 2]
});

const databaseErrors = new promClient.Counter({
  name: 'database_errors_total',
  help: 'Total database errors',
  labelNames: ['operation', 'table', 'error_type']
});

const databaseConnections = new promClient.Gauge({
  name: 'database_connections_active',
  help: 'Active database connections',
  labelNames: ['table']
});

// Register database metrics
register.registerMetric(databaseOperations);
register.registerMetric(databaseErrors);
register.registerMetric(databaseConnections);
register.registerMetric(aiRequestsTotal);
register.registerMetric(aiTokensUsed);
register.registerMetric(aiCostTotal);
register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestsTotal);
register.registerMetric(ordersTotal);
register.registerMetric(customerSatisfaction);

// Middleware to track HTTP requests
const trackHttpRequests = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);
    
    httpRequestsTotal
      .labels(req.method, route, res.statusCode >= 400 ? 'error' : 'success')
      .inc();
  });
  
  next();
};

// AI Service Tracking Functions
const trackAIRequest = async (service, model, endpoint, requestFn) => {
  const start = Date.now();
  let status = 'success';
  let tokens = 0;
  let cost = 0;
  
  try {
    const result = await requestFn();
    
    if (result.usage) {
      tokens = result.usage.total_tokens || 0;
      cost = calculateCost(service, model, tokens);
    }
    
    return result;
  } catch (error) {
    status = 'error';
    throw error;
  } finally {
    const duration = (Date.now() - start) / 1000;
    
    aiRequestDuration
      .labels(service, model, endpoint)
      .observe(duration);
    
    aiRequestsTotal
      .labels(service, model, status)
      .inc();
    
    if (tokens > 0) {
      aiTokensUsed
        .labels(service, model, 'total')
        .inc(tokens);
    }
    
    if (cost > 0) {
      aiCostTotal
        .labels(service, model)
        .inc(cost);
    }
  }
};

// Business Metrics Tracking
const trackOrder = (orderData) => {
  ordersTotal
    .labels(orderData.status || 'pending', orderData.paymentMethod || 'unknown')
    .inc();
};

const updateCustomerSatisfaction = (score, category = 'general') => {
  customerSatisfaction
    .labels(category)
    .set(score);
};

// Cost calculation helper
const calculateCost = (service, model, tokens) => {
  const pricing = {
    'openai': {
      'gpt-4': { input: 0.03, output: 0.06 },
      'gpt-3.5-turbo': { input: 0.001, output: 0.002 }
    },
    'bedrock': {
      'claude-3': { input: 0.015, output: 0.075 }
    },
    'azure': {
      'text-analytics': 0.001
    }
  };
  
  if (service === 'azure') {
    return pricing[service][model] || 0.001;
  }
  
  const modelPricing = pricing[service]?.[model];
  if (!modelPricing) return 0;
  
  return (tokens / 1000) * ((modelPricing.input + modelPricing.output) / 2);
};

// Database Operation Tracking
const trackDatabaseOperation = async (operation, table, operationFn) => {
  const start = Date.now();
  let status = 'success';
  
  try {
    const result = await operationFn();
    return result;
  } catch (error) {
    status = 'error';
    
    // Track specific error types
    const errorType = error.name || 'UnknownError';
    databaseErrors
      .labels(operation, table, errorType)
      .inc();
    
    throw error;
  } finally {
    const duration = (Date.now() - start) / 1000;
    
    databaseOperations
      .labels(operation, table, status)
      .observe(duration);
  }
};

export {
  register,
  trackHttpRequests,
  trackAIRequest,
  trackDatabaseOperation,
  trackOrder,
  updateCustomerSatisfaction
};
