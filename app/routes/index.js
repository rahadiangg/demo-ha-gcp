import express from "express";
import { getUsers, storeUser} from "../controller/users.js";
import { getPayments, storePayment } from "../controller/payments.js";

const router = express.Router();
const country_code = process.env.country_code;

// Users
router.get('/users', getUsers);
router.post('/users', storeUser);

// Payments
router.get('/payments/'+country_code, getPayments);
router.post('/payments/'+country_code, storePayment);

// Health Check
router.get('/', (req, res) => {
    res.json({
        "status": "sehat walafiat...."
    });
});

export default router;