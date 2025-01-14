// app-repo/source/backend/src/config.js
module.exports = {
    db: {
      host: process.env.DB_HOST || 'postgresql.default.svc.cluster.local', // Kubernetes service name
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'habittracker',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD,
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
    },
    server: {
      port: process.env.PORT || 5000
    }
  };