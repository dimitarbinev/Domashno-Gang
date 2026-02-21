import { Request, Response, NextFunction } from "express";
import admin from 'firebase-admin'

export const checkToken = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const tokenHeader = req.headers.authorization;
        if(!tokenHeader){
            return res.status(401).json({message: "No token provided"})
        }

        const token = tokenHeader.split(' ')[1]

        const decodeValue = await admin.auth().verifyIdToken(token)

        if(decodeValue){
            req.user = decodeValue;
            return next()
        }
    } catch (error) {
        console.error(error)
        return res.status(401).json({Message: "Invalid Token"})
    }
}

export const error_lister = (err: Error, req: Request, res: Response, next: NextFunction) => {
    console.error(err)
    res.status(500).json({message: err.message})
}

export const catch_async = (fn: Function) => (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next)
}