package routes

import (
	"github.com/apex/gateway"
	"github.com/gin-gonic/gin"
	"github.com/swaggo/gin-swagger"
	"github.com/swaggo/gin-swagger/swaggerFiles"
	"log"
	"os"

	"../controllers"
)

func routerEngine() *gin.Engine {
	gin.SetMode(gin.DebugMode)
	route := gin.Default()
	route.GET("/login", controllers.Login)
	route.GET("/user", controllers.QueryUserByQueryString)
	route.PATCH("/user", controllers.UpdateUserName)
	route.DELETE("/user", controllers.DeleteUser)
	route.POST("/user", controllers.CreateUser)

	// For local testing
	// Run swagger UI
	url := ginSwagger.URL("http://localhost:8888/swagger/doc.json") // The url pointing to API definition
	route.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler, url))

	return route
}

func RunServer() {
	// AWS server
	addr := ":" + os.Getenv("PORT")
	log.Fatal(gateway.ListenAndServe(addr, routerEngine()))

	// For local testing
	// routerEngine().Run(":8888")
}
