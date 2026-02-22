import dotenv from 'dotenv'
dotenv.config()

import express from 'express'
import cors from 'cors'
import { error_lister } from './middleware/middleware'
import authRoutes from './routes/authRoutes'
import taskRoutes from './routes/taskRoutes'
import profileRoutes from './routes/profileRoutes'

const app = express();
const PORT = process.env.PORT || 3000

app.use(express.json());
app.use(cors())
app.use('/auth', authRoutes)
app.use('/tasks', taskRoutes)
app.use('/profile', profileRoutes)
app.use(error_lister)
        
app.listen(PORT, () => {
    console.log(`App is listening on ${PORT}`);
})


