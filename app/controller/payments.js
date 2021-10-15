import Payments from "../model/payments.model.js";

export const getPayments = async (req, res) => {
    try {
        const users = await Payments.findAll({
            limit: 20
        });
        res.json(users);
    } catch (error) {
        res.json({
            "message": error.message
        });
    }
}

export const storePayment = async (req, res) => {
    try {
        await Payments.create(req.body);
        res.json({
            "message":"Success add new payment"
        });
    } catch (error) {
        res.json({
            "message": error.message
        });
    }
}