FROM openjdk:17-jdk

# JAR파일이 저장될 디렉터리
WORKDIR /app

# Maven 또는 Gradle 빌드 후 생성된 JAR파일 컨테이너 내부 /app 디렉터리에 app.jar이름으로 복사 
# Host Jenkins에 생성된 app.jar 파일을 컨테이너 내부이네 /app/app.jar 로 복사 
COPY app.jar app.jar

EXPOSE 8081

# 컨테이너가 시작될 때 자동으로 java -jar app.jar 명령을 실행하도록 설정 
ENTRYPOINT [ "java" , "-jar", "app.jar" ]