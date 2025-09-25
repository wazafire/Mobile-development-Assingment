from fastapi import APIRouter

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/login")
def login(username: str, password: str):
    # Here you’d normally verify against DB
    if username == "admin" and password == "1234":
        return {"token": "fake-jwt-token"}
    return {"error": "Invalid credentials"}
