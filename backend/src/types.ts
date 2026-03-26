import { DecodedIdToken } from 'firebase-admin/auth'; 

declare global {
  namespace Express {
    interface Request {
      user?: DecodedIdToken; 
    }
  }
}

export enum Status{
  pending,
  confirmed,
  cancelled
}

export interface Product {
  productName: string;
  minThreshold: number;
  maxCapacity: number;
  category: string;
  origin: string;
  image?: string;
  pricePerKg: number;
  season?: string;
  sellerId: string;
  createdAt: Date;
  status: Status;
}

export interface Order{
  quantityKg: number;
}