import admin from "firebase-admin"
import serviceAccount from "../serviceAccountKey.json"

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount as any)
})

const db = admin.firestore()
const auth = admin.auth()
const webApiKey = process.env.FIREBASE_WEB_API_KEY

export { db, auth, webApiKey }
export default db