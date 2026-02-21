import {Router} from 'express'
import { sign_up, login } from '../controllers/authControllers'
import { verifyToken } from '../middleware/middleware'

const router = Router()

router.post('/sign_up', sign_up)

router.get('/login', verifyToken, login)

export default router;