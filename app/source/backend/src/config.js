// app-repo/source/backend/src/config.js
export const config = {
    db: {
      host: process.env.DB_HOST || 'postgresql',
      port: parseInt(process.env.DB_PORT) || 5432,
      database: process.env.DB_NAME || 'habits',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      ssl: false
    },
    server: {
      port: parseInt(process.env.SERVER_PORT) || 5000
    }
};
  