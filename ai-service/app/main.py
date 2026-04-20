from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Health Mate AI Service",
    description="MVP stub — Phase 2에서 ML 추천 로직 구현 예정",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "ai-service"}


# TODO Phase 2: 운동 추천 라우터
# from .routers import recommend
# app.include_router(recommend.router, prefix="/recommend", tags=["recommend"])


# TODO Phase 2: 식단 추천 라우터
# from .routers import nutrition
# app.include_router(nutrition.router, prefix="/nutrition", tags=["nutrition"])
