package main

import (
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	hostname, _ := os.Hostname()

	r.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, hostname)
	})

	r.Run("0.0.0.0:8080")
}
