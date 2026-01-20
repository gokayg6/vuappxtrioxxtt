import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  statusCode: number;
  code: string;
  
  constructor(message: string, statusCode: number, code: string) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
  }
}

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Error:', err);
  
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      message: err.message,
      code: err.code,
    });
  }
  
  // Prisma errors
  if (err.name === 'PrismaClientKnownRequestError') {
    return res.status(400).json({
      message: 'Database error',
      code: 'DATABASE_ERROR',
    });
  }
  
  // Default error
  res.status(500).json({
    message: 'Internal server error',
    code: 'INTERNAL_ERROR',
  });
};
