package main

import (
	"net/http"
	"rahadiangg/demo-ha-gcp/config"
	"rahadiangg/demo-ha-gcp/controller"
	"rahadiangg/demo-ha-gcp/helper"
	"rahadiangg/demo-ha-gcp/repository"
	"rahadiangg/demo-ha-gcp/service"

	"github.com/julienschmidt/httprouter"
)

func main() {

	db := config.NewDB()

	userRepository := repository.NewUserRepository(db)
	userService := service.NewUserService(userRepository)
	userController := controller.NewUserController(userService)

	paymentRepository := repository.NewPaymentRepository(db)
	paymentService := service.NewPaymentService(paymentRepository)
	paymentController := controller.NewPaymentController(paymentService)

	router := httprouter.New()
	router.GET("/users", userController.GetAll)
	router.POST("/users", userController.Save)
	router.GET("/payments", paymentController.GetAll)
	router.POST("/payments", paymentController.Save)

	server := &http.Server{
		Addr:    "localhost:9000",
		Handler: router,
	}

	err := server.ListenAndServe()
	helper.PanicIfError(err)
}
