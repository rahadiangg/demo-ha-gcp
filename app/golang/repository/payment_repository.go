package repository

import "rahadiangg/demo-ha-gcp/model/domain"

type PaymentRepository interface {
	Save(payment domain.Payment) domain.Payment
	FindAll() []domain.Payment
}
