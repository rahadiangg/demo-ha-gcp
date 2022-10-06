import * as dotenv from 'dotenv';
dotenv.config();

import express from "express";
import { getUsers, storeUser} from "../controller/users.js";
import { getPayments, storePayment } from "../controller/payments.js";

const router = express.Router();
const COUNTRY_CODE = process.env.COUNTRY_CODE;

// Users
router.get('/users', getUsers);
router.post('/users', storeUser);

// Payments
router.get('/payments/'+COUNTRY_CODE, getPayments);
router.post('/payments/'+COUNTRY_CODE, storePayment);

// Health Check
router.get('/', (req, res) => {
    res.json({
        "status": "sehat walafiat...."
    });
});

export default router;