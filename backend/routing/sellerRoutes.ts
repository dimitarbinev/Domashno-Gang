import Router from "express";
import {register, getProfile} from "../controllers/authController";
import {verifyToken} from "../middleware/middleware";
import {productListing, listingConfirmation, getProducts} from "../controllers/sellerControllers";

const router = Router();

router.post("/product",verifyToken, productListing);
router.post("/confirmation",verifyToken, listingConfirmation);
router.get("/getProducts", verifyToken, getProducts)

export default router;