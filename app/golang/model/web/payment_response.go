package web

import "time"

type PaymentResponse struct {
	Id        int64     `json:"id"`
	UserId    int64     `json:"user_id"`
	Amount    float32   `json:"amount"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
