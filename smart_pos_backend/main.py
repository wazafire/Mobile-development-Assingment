from fastapi import FastAPI
from database import engine, Base
from routes import reports, auth

# Create DB tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Smart POS Backend")

# Register routes
app.include_router(auth.router)
app.include_router(reports.router)
