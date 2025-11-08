import os
import json
import boto3
from typing import List
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()
s3_client = boto3.client("s3")
BUCKET_NAME = "taller-ec2-stm-scm"  


class Item(BaseModel):
    name: str
    edad: int
    fecha_nacimiento: str


@app.post("/insert")
def insert_item(item: Item):
    try:
        filename = f"{item.name}.json"

        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=filename,
            Body=item.json(),
            ContentType="application/json"
        )
        response = s3_client.list_objects_v2(Bucket=BUCKET_NAME)
        count = response.get("KeyCount", 0)

        return {"filename": filename, "total_archivos": count}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
