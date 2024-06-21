from django.db import models
from core.models import BaseModel

class Student(BaseModel):
    name = models.CharField(max_length=255)
    enrollment_number = models.CharField(max_length=100)
    date_of_birth = models.DateField()

    def __str__(self):
        return self.name

class Course(BaseModel):
    name = models.CharField(max_length=255)
    description = models.TextField()

    def __str__(self):
        return self.name
