import Router from "express";
import {register, getProfile, changeRole} from "../controllers/authController";
import {verifyToken} from "../middleware/middleware";

const router = Router();

router.post("/sign_up", register);
router.get("/profile", verifyToken, getProfile);
router.get("/change_role", verifyToken, changeRole);

export default router;