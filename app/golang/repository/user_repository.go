package repository

import "rahadiangg/demo-ha-gcp/model/domain"

type UserRepository interface {
	Save(user domain.User) domain.User
	FindAll() []domain.User
}
