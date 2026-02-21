import { Request, Response } from "express";
import { catch_async, error_lister } from "../middleware/middleware";
import admin from "firebase-admin"
import {db} from "../config/firbase"

export const createTask = catch_async(async(req: Request, res:Response) => {
    const { title, userId } = req.body;
    const guardianId = req.user?.uid;

    const taskRef = await db.collection("tasks").add({
        title,
        userId,
        guardianId,
        active: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    res.json({ taskId: taskRef.id });
})