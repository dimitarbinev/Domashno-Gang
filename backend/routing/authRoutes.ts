import Router from "express";
import {register, getProfile, changeRole, getProfileName} from "../controllers/authController";
import {verifyToken, authLimiter} from "../middleware/middleware";

const router = Router();

router.post("/sign_up", authLimiter, register);
router.get("/profile", verifyToken, getProfile);
router.post("/change_role", verifyToken, changeRole);
router.get("/profile_name", verifyToken, getProfileName);

export default router;