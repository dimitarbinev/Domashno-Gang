import {Router} from 'express'
import { sign_up, getProfile } from '../controllers/authControllers'
import { verifyToken } from '../middleware/middleware'

const router = Router()

router.post('/sign_up', sign_up)

router.get('/me', verifyToken, getProfile)

export default router;