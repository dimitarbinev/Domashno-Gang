import { Request, Response } from "express"
import {db, FieldValue} from "../config/firbase"
import { catch_async } from "../middleware/middleware"




interface ChildProfile{
    name: string,
    age: number,
    readingLevel: number,
    tone: number,
    prefersEmoji: boolean,
    avoidBrightColors: boolean,
    guardianId: string,
    childUid: string
}

export const createProfile = catch_async(async (req: Request, res: Response) => {
    const {guardianId, childUid, name, age, readingLevel, tone, prefersEmoji, avoidBrightColors} = req.body;

    if (!guardianId || !name || age === undefined || readingLevel === undefined) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    if (!childUid) {
      return res.status(400).json({ message: 'childUid is required' });
    }

    const profile = {
        guardianId,
        childUid, 
        name, 
        age, 
        readingLevel, 
        tone: tone || 'calm', 
        prefersEmoji: !!prefersEmoji, 
        avoidBrightColors: !!avoidBrightColors
    }

    const docRef = db.collection('child_profiles').doc(childUid);
    await docRef.set(profile, { merge: true });

    // Add the child UID to guardian profile
    const guardianRef = db.collection('profiles').doc(guardianId);
    await guardianRef.update({
      children: FieldValue.arrayUnion(childUid)
    });

    return res.status(200).json({ childUid, profile });
    

}) 