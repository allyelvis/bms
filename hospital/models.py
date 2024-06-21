from django.db import models
from core.models import BaseModel

class Patient(BaseModel):
    name = models.CharField(max_length=255)
    date_of_birth = models.DateField()
    medical_record_number = models.CharField(max_length=100)

    def __str__(self):
        return self.name

class Appointment(BaseModel):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    date = models.DateTimeField()
    reason = models.TextField()

    def __str__(self):
        return f"{self.patient.name} - {self.date}"
