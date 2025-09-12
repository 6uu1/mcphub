import { Request, Response } from 'express';
import config from '../config/index.js';
import { getPackageVersion } from '../utils/version.js';
import fs from 'fs';
import { getAppDataSource } from '../db/connection.js';

interface HealthCheck {
  status: 'healthy' | 'degraded' | 'unhealthy';
  timestamp: string;
  version: string;
  environment: string;
  uptime: number;
  checks: {
    server: boolean;
    database?: boolean;
    filesystem: boolean;
    memory: boolean;
  };
  details?: {
    error?: string;
    warnings?: string[];
  };
}

export const healthCheck = async (req: Request, res: Response): Promise<void> => {
  const startTime = Date.now();
  const health: HealthCheck = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: getPackageVersion(),
    environment: process.env.NODE_ENV || 'development',
    uptime: process.uptime(),
    checks: {
      server: true,
      filesystem: false,
      memory: false,
    },
    details: {
      warnings: [],
    },
  };

  try {
    // Check filesystem access
    try {
      fs.accessSync('./', fs.constants.R_OK | fs.constants.W_OK);
      health.checks.filesystem = true;
    } catch (error) {
      health.checks.filesystem = false;
      health.details!.warnings!.push('Filesystem access limited');
    }

    // Check memory usage
    const memUsage = process.memoryUsage();
    const memUsageMB = {
      rss: Math.round(memUsage.rss / 1024 / 1024),
      heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024),
      heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024),
      external: Math.round(memUsage.external / 1024 / 1024),
    };

    // Consider memory healthy if heap used is less than 80% of heap total
    health.checks.memory = memUsageMB.heapUsed < memUsageMB.heapTotal * 0.8;
    
    if (!health.checks.memory) {
      health.details!.warnings!.push(`High memory usage: ${memUsageMB.heapUsed}/${memUsageMB.heapTotal}MB`);
    }

    // Check database connection (optional)
    if (process.env.DATABASE_URL) {
      try {
        const dataSource = getAppDataSource();
        if (dataSource && dataSource.isInitialized) {
          await dataSource.query('SELECT 1');
          health.checks.database = true;
        } else {
          health.checks.database = false;
          health.details!.warnings!.push('Database not initialized');
        }
      } catch (error) {
        health.checks.database = false;
        health.details!.warnings!.push('Database connection failed');
      }
    }

    // Determine overall status
    const allChecks = Object.values(health.checks);
    const criticalChecks = [health.checks.server, health.checks.filesystem];
    
    if (criticalChecks.every(check => check)) {
      if (allChecks.every(check => check !== false)) {
        health.status = 'healthy';
      } else {
        health.status = 'degraded';
      }
    } else {
      health.status = 'unhealthy';
    }

    // Add response time
    const responseTime = Date.now() - startTime;
    (health as any).responseTime = `${responseTime}ms`;

    // Set HTTP status based on health status
    const statusCode = health.status === 'healthy' ? 200 
                     : health.status === 'degraded' ? 200 
                     : 503;

    res.status(statusCode).json(health);

  } catch (error) {
    health.status = 'unhealthy';
    health.details!.error = error instanceof Error ? error.message : 'Unknown error';
    res.status(503).json(health);
  }
};

export const liveCheck = (req: Request, res: Response): void => {
  res.status(200).json({ 
    status: 'alive',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
};

export const readyCheck = async (req: Request, res: Response): Promise<void> => {
  try {
    // Check if essential services are ready
    const ready = {
      status: 'ready',
      timestamp: new Date().toISOString(),
      checks: {
        server: true,
        config: !!config,
      }
    };

    res.status(200).json(ready);
  } catch (error) {
    res.status(503).json({
      status: 'not ready',
      timestamp: new Date().toISOString(),
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
};