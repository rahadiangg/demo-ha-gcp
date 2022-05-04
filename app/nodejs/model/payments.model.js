import { Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

const Payments = db.define('payments', {
    user_id: {
        type: DataTypes.BIGINT.UNSIGNED
    },
    amount: {
        type: DataTypes.FLOAT
    }
}, {
    freezeTableName: true
});

export default Payments;