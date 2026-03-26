import { Request, Response } from "express";
import admin, { messaging } from "firebase-admin"
import {db} from '../config/firebase'
import {catch_async} from "../middleware/middleware"

export const makeOreder = catch_async(async (req: Request, res: Response) => {
      
})