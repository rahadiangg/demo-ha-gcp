import Users from "../model/users.model.js";

export const getUsers = async (req, res) => {
    try {
        const users = await Users.findAll({
            limit: 20
        });
        res.json(users);
    } catch (error) {
        res.json({
            "message": error.message
        });
    }
}

export const storeUser = async (req, res) => {
    try {
        await Users.create(req.body);
        res.json({
            "message":"Success add new users"
        });
    } catch (error) {
        res.json({
            "message": error.message
        });
    }
}