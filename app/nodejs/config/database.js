import { Sequelize } from "sequelize";

import * as dotenv from 'dotenv';
dotenv.config();

const DB_NAME = process.env.DB_NAME;
const DB_DIALECT = process.env.DB_DIALECT.toString();

console.log(DB_DIALECT);

const DB_USER = process.env.DB_USER;
const DB_PASS = process.env.DB_PASS;

// write
const DB_WRITE_HOST =  process.env.DB_WRITE_HOST;

//read
const DB_READ_HOST = process.env.DB_READ_HOST.split(";");
var DB_READ_HOST_ARRAY = [];

for (let index = 0; index < DB_READ_HOST.length; index++) {
    var temp = {"host": DB_READ_HOST[index]}
    DB_READ_HOST_ARRAY.push(temp);
}

const db = new Sequelize(DB_NAME, DB_USER, DB_PASS, {
    dialect: DB_DIALECT,
    replication: {
        read: DB_READ_HOST_ARRAY,
        write: {
            host: DB_WRITE_HOST
        }
    }
});

export default db;