package controllers

import (
	"github.com/gin-gonic/gin"
	"github.com/pborman/uuid"
	"log"
	"net/http"

	"../db"
)

//
// @Description login to sync current aws id
// @Produce  json
// @Success 200 {object} db.U "200 response"
// @Router /login [get]
// @Security sigv4
func Login(c *gin.Context) {
	c.Writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	c.JSON(http.StatusOK, gin.H{"message": "Login in success", "status": http.StatusOK})
}

//
// @Description query user data by aws_id
// @Produce  json
// @Success 200 {object} db.U "200 response"
// @Router /user [get]
// @Security sigv4
func QueryUserByQueryString(c *gin.Context) {
	var u db.U
	c.Writer.Header().Set("Content-Type", "application/json; charset=utf-8")

	if err := c.ShouldBindQuery(&u); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err, "status": http.StatusBadRequest})
		return
	}
	log.Print("Query aws id: ", u.AWS_ID)
	user, err := db.RetrieveUser(u.AWS_ID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err, "status": http.StatusBadRequest})
		return
	}
	if user == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": http.StatusInternalServerError})
	} else {
		c.JSON(http.StatusOK, gin.H{"user": user, "status": http.StatusOK})
	}
}

//
// @Description update user data
// @Produce  json
// @Success 200 {object} db.U "200 response"
// @Router /user [patch]
// @Security sigv4
func UpdateUserName(c *gin.Context) {
	var u db.U
	c.Writer.Header().Set("Content-Type", "application/json; charset=utf-8")

	if err := c.ShouldBindJSON(&u); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err, "status": http.StatusBadRequest})
		return
	}
	err := db.UpdateUser(&u)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err, "status": http.StatusInternalServerError})
	} else {
		c.JSON(http.StatusOK, gin.H{"user": u, "status": http.StatusOK})
	}
}

//
// @Description delete user by aws_id
// @Produce  json
// @Success 200 {object} db.U "200 response"
// @Router /user [delete]
// @Security sigv4
func DeleteUser(c *gin.Context) {
	var u db.U
	c.Writer.Header().Set("Content-Type", "application/json; charset=utf-8")

	if err := c.ShouldBindQuery(&u); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err, "status": http.StatusBadRequest})
		return
	}
	log.Print("Delete aws id: ", u.AWS_ID)
	err := db.DeleteUser(u.AWS_ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "status": http.StatusInternalServerError})
	} else {
		c.JSON(http.StatusOK, gin.H{"aws_id": u.AWS_ID, "status": http.StatusOK})
	}
}

//
// @Description create new user data
// @Produce  json
// @Success 200 {object} db.U "200 response"
// @Router /user [post]
// @Security sigv4
func CreateUser(c *gin.Context) {
	var u db.U
	c.Writer.Header().Set("Content-Type", "application/json; charset=utf-8")

	if err := c.ShouldBindJSON(&u); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err, "status": http.StatusBadRequest})
		return
	}
	user := &db.User{
		ID: uuid.New(),
		U:  u,
	}
	err := db.CreateUser(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err, "status": http.StatusInternalServerError})
	} else {
		c.JSON(http.StatusOK, gin.H{"user": u, "status": http.StatusOK})
	}
}
