package controller

import (
	"net/http"
	"rahadiangg/demo-ha-gcp/helper"
	"rahadiangg/demo-ha-gcp/model/web"
	"rahadiangg/demo-ha-gcp/service"

	"github.com/julienschmidt/httprouter"
)

type UserController interface {
	Save(w http.ResponseWriter, r *http.Request, params httprouter.Params)
	GetAll(w http.ResponseWriter, r *http.Request, params httprouter.Params)
}

type UserControllerImpl struct {
	UserService service.UserService
}

func NewUserController(userService service.UserService) UserController {
	return &UserControllerImpl{
		UserService: userService,
	}
}

func (controller *UserControllerImpl) Save(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	userRequest := web.UserCreateRequest{}
	helper.Decode(r, &userRequest)
	userResponse := controller.UserService.Save(&userRequest)
	helper.Encode(w, &userResponse)
}

func (controller *UserControllerImpl) GetAll(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	userResponse := controller.UserService.FindAll()
	helper.Encode(w, userResponse)
}
