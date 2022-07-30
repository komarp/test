import os

from fastapi import FastAPI


app = FastAPI()


@app.get("/")
async def healthcheck():
    print(os.F_OK)
    return {"healthy": "YES"}
