package repository

import (
	"rahadiangg/demo-ha-gcp/helper"
	"rahadiangg/demo-ha-gcp/model/domain"

	"gorm.io/gorm"
)

type UserRepositoryImpl struct {
	DB *gorm.DB
}

func NewUserRepository(db *gorm.DB) UserRepository {
	return &UserRepositoryImpl{
		DB: db,
	}
}

func (repository *UserRepositoryImpl) Save(user domain.User) domain.User {
	err := repository.DB.Create(&user).Error
	helper.PanicIfError(err)
	return user
}

func (repository *UserRepositoryImpl) FindAll() []domain.User {
	var users []domain.User
	err := repository.DB.Find(&users).Limit(20).Error
	helper.PanicIfError(err)

	return users
}
