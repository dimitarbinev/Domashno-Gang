import Router from "express";
import {register, getProfile} from "../controllers/authController";
import {verifyToken} from "../middleware/middleware";
import {productListing} from "../controllers/sellerControllers";

const router = Router();

router.post("/product", verifyToken, productListing);

export default router;