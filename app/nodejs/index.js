import express from "express";
import db from "./config/database.js";
import router from "./routes/index.js";

const app = express(); 
const PORT = process.env.PORT || 8080;
try {
    await db.authenticate();
    console.log('Database OK');
} catch(error) {
    console.log('Database error: ', error);
}

app.use(express.json());
app.use(router);

app.listen(PORT, () => {
    console.log('Server is running on port '+PORT);
});