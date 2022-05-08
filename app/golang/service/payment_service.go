package service

import "rahadiangg/demo-ha-gcp/model/web"

type PaymentService interface {
	Save(request *web.PaymentCreateRequest) web.PaymentResponse
	FindAll() []web.PaymentResponse
}
