import {Router} from 'express'
import { createProfile } from '../controllers/userController'
import {verifyToken} from '../middleware/middleware'

const router = Router()

router.post('/', verifyToken, createProfile)

export default router
