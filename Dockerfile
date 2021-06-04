FROM gradle:7.0.2-jdk8-hotspot AS cache
RUN mkdir -p /home/gradle/cache_home
ENV GRADLE_USER_HOME /home/gradle/cache_home
COPY settings.gradle /home/gradle/java-code/
COPY build.gradle /home/gradle/java-code/
COPY app/build.gradle /home/gradle/java-code/app/
WORKDIR /home/gradle/java-code
RUN gradle downloadDependencies -i --stacktrace

FROM gradle:7.0.2-jdk8-hotspot AS builder
COPY --from=cache /home/gradle/cache_home /home/gradle/.gradle
COPY . /app
WORKDIR /app
RUN gradle bootJar -i --stacktrace

FROM adoptopenjdk:8-jdk-hotspot
EXPOSE 8081
EXPOSE 5005
WORKDIR /app
COPY --from=builder /app/app/build/libs/*.jar ./app.jar

#处理时区，占用1.78m，还是在docker run指定比较好
ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive
RUN apt update \
    && apt install -y tzdata \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["java", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005", "-jar", "app.jar"]