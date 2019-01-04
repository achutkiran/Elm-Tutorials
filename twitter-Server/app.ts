require('dotenv').config()
import axios from 'axios';
import * as cors from 'cors';
import * as bodyparser from 'body-parser';
// let app = require('express')()
import * as express from 'express';
let app = express();
app.use(bodyparser.json())
app.use(bodyparser.urlencoded({extended:false}))
let token: string=  ""

/**
 * CORS Options 
 */
let whitelist:string[] = ['http://localhost:3000']
let corsOptions = {
    origin : function (origin,callback){
        if(whitelist.indexOf(origin) !== -1){
            callback(null,true)
        }
        else{
            callback(null,false)
        }
    }
}

app.use(cors(corsOptions))

app.listen(4000,()=>{
    console.log("Server started")
})


axios({
    method: "post",
    url: "https://api.twitter.com/oauth2/token",
    headers: {
        "Authorization" : `Basic ${process.env.CREDENTIALS}`,
        "Content-Type" : "application/x-www-form-urlencoded;charset=UTF-8"
    },
    params : {
        "grant_type" : "client_credentials"
    }
}).then((response) =>{
    token = response.data.access_token
},(error) =>{
    console.log(error.response.data)
})


app.get(
    '/fetchTweets',(req,res) =>{
        axios({
            method:"get",
            url: "https://api.twitter.com/1.1/search/tweets.json",
            headers: {
                "Authorization" : `Bearer ${token}`
            },
            params : req.query
        }).then(out =>{
            res.status(200).send({"data":out.data.statuses.map(x =>x.full_text)})
        }, (error) =>{
            console.log(error)
        })
    }
)

app.get(
    '/getUsers', (req,res) => {
        axios({
            method: "get",
            url: "https://api.twitter.com/1.1/users/lookup.json",
            headers : {
                "Authorization": `Bearer ${token}`
            },
            params : {
                "screen_name" : req.query.name
            }
        }).then(out =>{
            let data = out.data[0]
            console.log(data)
            let userOut = {
                name : data.name,
                screenName : data.screen_name,
                description : data.description,
                verified : data.verified,
                nFollowers : data.followers_count,
                nFriends : data.friends_count,
                nLists : data.listed_count,
                nFav : data.favourites_count,
                nStatus : data.statuses_count,
                createdOn : data.created_at,
                lan : data.lang,
                bgColor : data.profile_background_color,
                bgUrl : data.profile_background_image_url,
                profileUrl : data.profile_image_url,
                textCol : data.profile_text_color
            }
            // console.log(userOut)
            res.status(200).send(userOut)
        }, (error) =>{
            let eData = error.response.data.errors[0]
            res.status(400).send(eData.message)
            
        })
    }
)