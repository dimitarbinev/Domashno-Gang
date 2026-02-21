import { Request, Response } from "express";
import admin, { messaging } from "firebase-admin"
import {db, webApiKey} from '../config/firbase'
import {catch_async} from "../middleware/middleware"

export const sign_up = catch_async(async (req: Request, res: Response) => {
        const {displayName, password, email} = req.body

        if(!email || !password){
            return res.status(400).json({message: "You should enter your email and password"})

        }

        const userRecord = await admin.auth().createUser({
            email,
            password,
            displayName
        });

        await db.collection('users').doc(userRecord.uid).set({
            email: userRecord.email,
            uid: userRecord.uid,
            displayName: userRecord.displayName,
            createdAt: new Date()
        });

        return res.status(201).json({message: "Succesfully signed up", uid: userRecord.uid, email: userRecord.email})
})

export const login = catch_async(async (req: Request, res: Response) => {
        const {email, password} = req.body;

        if(!email || !password){
            return res.status(400).json({message: "Credentials not provided"})
        }

        const response = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${webApiKey}`, {
            method: 'POST',
            body: JSON.stringify({
                email,
                password,
                returnSecureToken: true
            })
        });

        if(!response.ok){
            return res.status(401).json({message: "Invalid email or password"})
        }

        const data = await response.json();
        const uid = data.localId;

        const customToken = await admin.auth().createCustomToken(uid)

        return res.status(200).json({message: "Token generated succesfully", token: customToken })


})