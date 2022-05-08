package service

import (
	"rahadiangg/demo-ha-gcp/model/domain"
	"rahadiangg/demo-ha-gcp/model/web"
	"rahadiangg/demo-ha-gcp/repository"
)

type PaymentServiceImpl struct {
	Repository repository.PaymentRepository
}

func NewPaymentService(repository repository.PaymentRepository) PaymentService {
	return &PaymentServiceImpl{
		Repository: repository,
	}
}

func (service *PaymentServiceImpl) Save(request *web.PaymentCreateRequest) web.PaymentResponse {
	payment := domain.Payment{
		UserId: request.UserId,
		Amount: request.Amount,
	}

	result := service.Repository.Save(payment)
	return convertToPaymentResponse(&result)
}

func (service *PaymentServiceImpl) FindAll() []web.PaymentResponse {
	datas := service.Repository.FindAll()

	var response []web.PaymentResponse
	for _, data := range datas {
		response = append(response, convertToPaymentResponse(&data))
	}
	return response
}

func convertToPaymentResponse(p *domain.Payment) web.PaymentResponse {
	return web.PaymentResponse{
		Id:        p.Id,
		UserId:    p.UserId,
		Amount:    p.Amount,
		CreatedAt: p.CreatedAt,
		UpdatedAt: p.UpdatedAt,
	}
}
