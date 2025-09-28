pipeline{
    agent any // 어떤 에이전트(실행서버)에서든 실행가능

    tools{
        maven 'maven 3.9.11' //jenkins에 등록된 maven 3.9.11을 사용 
    }
    environment{
        // 배포에 필요한 변수 설정   (어떤 배포냐? jenkins에서 만든 docker file을 spring으로 배포하기 위한 변수)
        DOCKER_IMAGE = "demo-app" // 도커 이미지 이름
        CONTAINER_NAME = "springboot-container"  //도커 컨테이너 이름
        JAR_FILE_NAME = "app.jar"   //복사할 JAR 파일 이름
        PORT = "8081"   //컨테이너와 연결할 포트 
        REMOTE_USER = "ec2-user"  //원격 (spring) 서버 사용자
        REMOTE_HOST = "43.201.18.147"  // 원격 (spring) 서버 IP
        REMOTE_DIR = "/home/ec2-user/deploy"  //원격 서버에 파일 복사할 내용
        SSH_CREDENTIALS_ID = "0228fe82-77c6-40b4-a9f5-27e73bffe2a0"  //jenkins credentials ID (SSH 자격증명 ID)
    }

    // 본격적인 git push로 하는 스크립트 내용

    stages{
        stage('Git Check out'){
            steps{  // step: stage 안에서 실행할 실제 명령어
                //commit된 것 중 가장 최신버전말 실행되게 해야함 
                //jenkins 가 연결된 git 저장소에서 최신 코드 체크 아웃
                checkout scm 
            }
        }

        stage('maven Build'){
            steps{
                //테스트는 건너 뛰고 maven 빌드
                sh "mvn clean packages -DskipTests"
                // sh 'echo hello' : 리눅스 실행 명령어
            }
        }
        stage('prepare Jar'){
            steps{
                // 빌드 결과물인 jar 파일을 지정한 이름 (app.jar)으로 복사
                sh 'cp target/demo-0.0.1-SNAPSHOT.jar $(JAR_FILE_NAME)'
            }
        }
        stage('Copy to remote Server Docker file'){
            steps{
                //jenkins가 원격서버에 SSH 접속할 수 있도록 sshagent사용
                sshagent(credentials:[environment.SSH_CREDENTIALS_ID]){
                    sh "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${REMOTE_HOST} \"mkdir -p ${REMOTE_DIR}\""
                    // JAR 파일과 Dockerfile을 원격 서버에 복사
                    sh "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${JAR_FILE_NAME} Dockerfile ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"
                }
            }
        }

        stage('Remote docker Build & Copy'){
            steps{
                sshagent(credentials:[environment.SSH_CREDENTIALS_ID]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${REMOTE_HOST} << ENDSSH
                        cd ${REMOTE_DIR} || exit 1 
                        docker rm -f ${CONTAINER_NAME} || true    
                        docker build -t ${DOCKER_IMAGE} .              
                        docker run -d --name ${CONTAINER_NAME} -p ${PORT}:${PORT} ${DOCKER_IMAGE} 
                    ENDSSH
                    """
                }
            }
        }
        
    }
}
