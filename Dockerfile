FROM node:14-alpine

# sqlite3 原生模块需要编译工具
RUN apk add --no-cache python3 make g++

WORKDIR /app

# 先复制依赖文件，利用 Docker 层缓存
COPY package.json yarn.lock ./
RUN corepack enable && yarn install --frozen-lockfile

# 复制源码
COPY tsconfig.json ./
COPY src ./src

# 创建持久化目录和日志目录
RUN mkdir -p db garmin_fit_files logs

# 写入 crontab：每分钟执行一次 sync_cn，日志输出到 /app/logs/sync.log
RUN echo '* * * * * cd /app && yarn sync_cn >> /app/logs/sync.log 2>&1' > /etc/crontabs/root

CMD ["crond", "-f", "-l", "2"]
