import Router from "express";
import { verifyToken, sellerLimiter } from "../middleware/middleware";
import { classifyProduct, priceSuggestion } from "../controllers/aiController";

const router = Router();

router.post("/classify", verifyToken, sellerLimiter, classifyProduct);
router.post("/price-suggestion", verifyToken, sellerLimiter, priceSuggestion);

export default router;
