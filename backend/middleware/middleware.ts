import { Request, Response, NextFunction } from "express";
import admin from 'firebase-admin'

export const verifyToken = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const header = req.headers.authorization;

    if (!header || !header.startsWith("Bearer ")) {
      return res.status(401).json({ message: "No token provided" });
    }

    const token = header.split(" ")[1];

    const decoded = await admin.auth().verifyIdToken(token);

    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ message: "Invalid token" });
  }
};

export const error_lister = (err: Error, req: Request, res: Response, next: NextFunction) => {
    console.error(err)
    res.status(500).json({message: err.message})
}

export const catch_async = (fn: Function) => (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next)
}