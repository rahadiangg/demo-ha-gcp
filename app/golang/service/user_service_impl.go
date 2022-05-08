package service

import (
	"rahadiangg/demo-ha-gcp/model/domain"
	"rahadiangg/demo-ha-gcp/model/web"
	"rahadiangg/demo-ha-gcp/repository"
)

type UserServiceImpl struct {
	Repository repository.UserRepository
}

func NewUserService(repository repository.UserRepository) UserService {
	return &UserServiceImpl{
		Repository: repository,
	}
}

func (service *UserServiceImpl) Save(request *web.UserCreateRequest) web.UserResponse {
	user := domain.User{
		Name: request.Name,
	}

	user = service.Repository.Save(user)
	return converToResponse(&user)
}

func (service *UserServiceImpl) FindAll() []web.UserResponse {
	datas := service.Repository.FindAll()

	var response []web.UserResponse

	for _, data := range datas {
		response = append(response, converToResponse(&data))
	}

	return response
}

func converToResponse(user *domain.User) web.UserResponse {
	return web.UserResponse{
		Id:        user.Id,
		Name:      user.Name,
		CreatedAt: user.CreatedAt,
		UpdatedAt: user.UpdatedAt,
	}
}
