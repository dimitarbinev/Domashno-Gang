import { Request, Response } from "express";
import admin, { messaging } from "firebase-admin"
import {db} from '../config/firbase'
import {catch_async} from "../middleware/middleware"

export const sign_up = catch_async(async (req: Request, res: Response) => {
        const {displayName, password, email, role, guardianId} = req.body

        if(!email || !password || !role){
            return res.status(400).json({message: "You should enter your email, password and role"})
        }

       if(role !== "guardian" && role !== "child"){
            return res.status(400).json({message: "You should enter a suitable role"})
       }

       const userRecord = await admin.auth().createUser({
        email,
        password,
        displayName
       })

       const uid = userRecord.uid

       if(role === "guardian"){
        await db.collection('users').doc(uid).set({
            uid,
            email,
            displayName,
            role: "guardian",
            linkedChildre: [],
            createdAt: new Date()
        })

        return res.status(201).json({message: "Guardian profile created", uid})
       }

       if(role === "child"){
        if(!guardianId){
            return res.status(400).json({message: "Guardian id not provided"})
        }

        const guardian = await db.collection('users').doc(guardianId).get()
        if(!guardian.exists){
            return res.status(404).json({message: "Guardian not found"})
        }

        await db.collection('users').doc(uid).set({
            uid,
            email,
            displayName,
            role: "child",
            guardianId,
            createdAt: new Date()
        })

        await db.collection('users').doc(guardianId).update({
            linkedChildren: admin.firestore.FieldValue.arrayUnion(uid)
        })

        return res.status(201).json({message: "Child profile created and linked"})
       }
})

export const getProfile = catch_async(async (req: Request, res: Response) => {
    const uid = req.user?.uid as string;

    const doc = await db.collection('users').doc(uid).get()

    if (!doc.exists) {
      return res.status(404).json({ message: "Profile not found" });
    }

    res.json({
      uid,
      ...doc.data(),
    });

})