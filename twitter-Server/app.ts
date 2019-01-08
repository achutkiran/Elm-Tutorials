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
            let data =out.data.statuses.map(x => {
                return {
                    "text" : x.full_text,
                    "createdAt" : x.created_at,
                    "userName" : x.user.name,
                    "screenName" : x.user.screen_name,
                    "profileImage" : x.user.profile_image_url,
                    "retweet" : x.retweet_count,
                    "fav" : x.favorite_count
                }
            })
            // res.status(200).send({"data":out.data.statuses.map(x =>x.full_text)})
            res.status(200).send(data)
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
            res.status(200).send([userOut])
        }, (error) =>{
            let eData = error.response.data.errors[0]
            res.status(400).send(eData.message)
            
        })
    }
)


app.get(
    '/getFollowers', (req,res) =>{
        console.log(req.query)
        axios({
            method: 'get',
            url:"https://api.twitter.com/1.1/followers/list.json",
            headers : {
                "Authorization":`Bearer ${token}`
            },
            params:{
                "screen_name" : req.query.name,
                "cursor" : req.query.cursor,
            }
        }).then(out =>{
            console.log(out.data.users[0])
            let data = out.data.users.map(x => {
                return { 
                    name : x.name,
                    screenName : x.screen_name,
                    description : x.description,
                    verified : x.verified,
                    nFollowers : x.followers_count,
                    nFriends : x.friends_count,
                    nLists : x.listed_count,
                    nFav : x.favourites_count,
                    nStatus : x.statuses_count,
                    createdOn : x.created_at,
                    lan : x.lang,
                    bgColor : x.profile_background_color,
                    bgUrl : x.profile_background_image_url,
                    profileUrl : x.profile_image_url,
                    textCol : x.profile_text_color
                }
            })
            res.status(200).send(data)
        },err => {
            res.status(400).send(err.response.data.errors[0])
        })
    }
)

app.get(
    '/getFriends', (req,res) =>{
        console.log(req.query)
        axios({
            method: 'get',
            url:"https://api.twitter.com/1.1/friends/list.json",
            headers : {
                "Authorization":`Bearer ${token}`
            },
            params:{
                "screen_name" : req.query.name,
                "cursor" : req.query.cursor,
            }
        }).then(out =>{
            let data = out.data.users.map(x => {
                return { 
                    name : x.name,
                    screenName : x.screen_name,
                    description : x.description,
                    verified : x.verified,
                    nFollowers : x.followers_count,
                    nFriends : x.friends_count,
                    nLists : x.listed_count,
                    nFav : x.favourites_count,
                    nStatus : x.statuses_count,
                    createdOn : x.created_at,
                    lan : x.lang,
                    bgColor : x.profile_background_color,
                    bgUrl : x.profile_background_image_url,
                    profileUrl : x.profile_image_url,
                    textCol : x.profile_text_color
                }
            })
            res.status(200).send(data)
        },err => {
            res.status(400).send(err.response.data.errors[0])
        })
    }
)

app.get(
    "/getFav", (req,res) =>{
        axios({
            method:"get",
            url:'https://api.twitter.com/1.1/favorites/list.json',
            headers:{
                Authorization : `Bearer ${token}`
            },
            params:{
                "screen_name" : req.query.name
            }
        }).then(out =>{
            console.log(out.data)
            res.sendStatus(200)
        },err =>{
            res.sendStatus(400)
        })
    }
)

