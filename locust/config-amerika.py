import time
import os
from locust import HttpUser, task, between

# country_code = os.getenv('locust_country_code')
country_code = "us"

class QuickstartUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def users(self):
        self.client.get("/users")
        self.client.post("/users", json={"name": "HahaHihi"})
        self.client.get("/payments/" + country_code)
        self.client.post("/payments/" + country_code, json={"user_id": 1, "amount": 10000})

    # @task
    # def payments(self):