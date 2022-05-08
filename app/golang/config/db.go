package config

import (
	"rahadiangg/demo-ha-gcp/helper"
	"rahadiangg/demo-ha-gcp/model/domain"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func NewDB() *gorm.DB {
	dsn := "root:mysql-local@tcp(127.0.0.1:3306)/demo_hc_gcp?charset=utf8&parseTime=True&loc=Local"
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	helper.PanicIfError(err)

	db.AutoMigrate(&domain.User{})
	db.AutoMigrate(&domain.Payment{})

	return db
}
