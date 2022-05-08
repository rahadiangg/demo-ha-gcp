package web

type PaymentCreateRequest struct {
	UserId int64   `json:"user_id"`
	Amount float32 `json:"amount"`
}
