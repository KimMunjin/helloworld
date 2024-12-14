# Build stage
FROM gradle:8.5-jdk17 AS build
WORKDIR /build

# Gradle 래퍼와 빌드 스크립트 복사
COPY gradlew /build/
COPY gradle /build/gradle
COPY build.gradle.kts settings.gradle.kts /build/

# Gradle 래퍼에 실행 권한 부여
RUN chmod +x ./gradlew

# 의존성 다운로드
RUN ./gradlew dependencies --no-daemon

# 소스 복사
COPY src /build/src

# 빌드
RUN ./gradlew build --no-daemon

# Runtime stage
FROM eclipse-temurin:17-jre
WORKDIR /app

# 빌드 결과물 복사
COPY --from=builder /build/build/libs/*.jar app.jar

# 컨테이너 실행 시 실행할 명령
ENTRYPOINT ["java","-jar","/app/app.jar"]