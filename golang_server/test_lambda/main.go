package main

import (
	"./db"
	"./routes"
)

// @title TestLambdaAPI2
// @version 2019-07-27T07:37:05Z
// @host  [YOUR HOST]
// @BasePath /dev
// @Schemes https
// @securityDefinitions.apikey sigv4
// @in header
// @name Authorization

// Need to add manually
// x-amazon-apigateway-authtype awsSigv4

func init() {
	db.CreateTableUser()
}

func main() {
	routes.RunServer()
}
