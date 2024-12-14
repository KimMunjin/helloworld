# 빌드 스테이지: Gradle과 JDK 17을 포함한 베이스 이미지 사용
FROM gradle:8.5-jdk17 AS build

# 작업 디렉토리 설정
WORKDIR /app

# Gradle 빌드 설정 파일들만 먼저 복사
# 이렇게 하면 소스코드가 변경되어도 의존성 캐시를 재사용할 수 있음
COPY build.gradle.kts settings.gradle.kts ./

# Gradle 래퍼 설정 파일 복사
# gradle 디렉토리에는 wrapper 설정과 관련된 파일들이 포함되어 있음
COPY gradle gradle

# 애플리케이션의 의존성만 먼저 다운로드
# --no-daemon 옵션으로 Gradle 데몬을 사용하지 않아 메모리 사용량 최적화
# 이 단계는 의존성이 변경되지 않는 한 캐시됨
RUN gradle dependencies --no-daemon

# 프로젝트의 소스 코드를 복사
# 의존성 다운로드 후에 소스를 복사하여 코드 변경 시 의존성 레이어 재사용
COPY src src

# 애플리케이션 빌드 실행
# --no-daemon: Gradle 데몬을 사용하지 않아 컨테이너 환경에 최적화
# clean: 이전 빌드 결과물을 제거하여 깨끗한 상태에서 빌드
# build: 프로젝트를 컴파일하고 테스트를 실행하여 JAR 파일 생성
RUN gradle clean build --no-daemon

# 실행 스테이지: JRE만 포함된 가벼운 베이스 이미지 사용
# jammy는 Ubuntu 22.04 LTS 버전을 의미
FROM eclipse-temurin:17-jre-jammy

# 실행 환경의 작업 디렉토리 설정
WORKDIR /app

# 빌드 스테이지에서 생성된 JAR 파일만 복사
# 빌드 시 생성된 JAR 파일을 app.jar로 이름 변경하여 복사
COPY --from=build /app/build/libs/*.jar app.jar

# 컨테이너에서 사용할 포트 명시
# 문서화 목적이며, 실제 포트 노출은 docker run의 -p 옵션으로 설정
EXPOSE 8080

# 컨테이너 실행 시 자동으로 실행할 명령 설정
# java -jar 명령으로 Spring Boot 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "app.jar"]