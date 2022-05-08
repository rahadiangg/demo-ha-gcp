package controller

import (
	"net/http"
	"rahadiangg/demo-ha-gcp/helper"
	"rahadiangg/demo-ha-gcp/model/web"
	"rahadiangg/demo-ha-gcp/service"

	"github.com/julienschmidt/httprouter"
)

type PaymentController interface {
	Save(w http.ResponseWriter, r *http.Request, params httprouter.Params)
	GetAll(w http.ResponseWriter, r *http.Request, params httprouter.Params)
}

type PaymentControllerImpl struct {
	PaymentService service.PaymentService
}

func NewPaymentController(paymentService service.PaymentService) PaymentController {
	return &PaymentControllerImpl{
		PaymentService: paymentService,
	}
}

func (controller *PaymentControllerImpl) Save(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	paymentRequest := web.PaymentCreateRequest{}
	helper.Decode(r, &paymentRequest)
	paymentResponse := controller.PaymentService.Save(&paymentRequest)
	helper.Encode(w, &paymentResponse)
}

func (controller *PaymentControllerImpl) GetAll(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	userResponse := controller.PaymentService.FindAll()
	helper.Encode(w, &userResponse)
}
