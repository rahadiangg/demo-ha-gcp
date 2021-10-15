import { Sequelize } from "sequelize";

const db_name = process.env.db_name;
const db_dialect = process.env.db_dialect || "mysql";

const db_user = process.env.db_user;
const db_pass = process.env.db_pass;

// write
const db_write_host = process.env.db_write_host;

//read
const db_read_host = process.env.db_read_host;

const db = new Sequelize(db_name, null, null, {
    dialect: db_dialect,
    replication: {
        read:{
            host: db_read_host,
            username: db_user,
            password: db_pass
        },
        write: {
            host: db_write_host,
            username: db_user,
            password: db_pass
        }
    }
});

export default db;