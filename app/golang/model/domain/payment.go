package domain

import (
	"time"
)

type Payment struct {
	Id        int64 `gorm:"primaryKey"`
	UserId    int64
	Amount    float32
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTIme:nano"`
}
