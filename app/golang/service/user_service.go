package service

import (
	"rahadiangg/demo-ha-gcp/model/web"
)

type UserService interface {
	Save(request *web.UserCreateRequest) web.UserResponse
	FindAll() []web.UserResponse
}
