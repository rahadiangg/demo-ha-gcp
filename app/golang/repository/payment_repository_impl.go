package repository

import (
	"rahadiangg/demo-ha-gcp/helper"
	"rahadiangg/demo-ha-gcp/model/domain"

	"gorm.io/gorm"
)

type PaymentRepositoryImpl struct {
	DB *gorm.DB
}

func NewPaymentRepository(db *gorm.DB) PaymentRepository {
	return &PaymentRepositoryImpl{
		DB: db,
	}
}

func (repository *PaymentRepositoryImpl) Save(payment domain.Payment) domain.Payment {
	err := repository.DB.Create(&payment).Error
	helper.PanicIfError(err)

	return payment
}

func (repository *PaymentRepositoryImpl) FindAll() []domain.Payment {
	var payments []domain.Payment
	err := repository.DB.Find(&payments).Limit(20).Error
	helper.PanicIfError(err)

	return payments
}
