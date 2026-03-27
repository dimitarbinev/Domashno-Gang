import Router from "express";
import { verifyToken, sellerLimiter } from "../middleware/middleware";
import { classifyProduct } from "../controllers/aiController";

const router = Router();

router.post("/classify", verifyToken, sellerLimiter, classifyProduct);

export default router;
