import cors from "cors"
import path from "path"
import http from "http"
import "dotenv/config"
//import morgan from 'morgan';
import express from "express"
// import cookieParser from 'cookie-parser';
import indexRouter from "./routes/index"

const app = express()

app.use(cors())
//app.use(morgan('dev'));
app.use(express.json())
app.use(express.raw({ type: "application/jwt" }))
app.use(express.urlencoded({ extended: false }))
//app.use(cookieParser());

app.use("/", indexRouter)
app.use("/index.html", (req, res) => res.redirect("./"))

app.use(express.static(path.join(__dirname, "public")))
app.use("*", indexRouter)

export default http.createServer(app)
