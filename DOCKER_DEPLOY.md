# Docker部署指南

本文档提供了如何使用Docker部署"郭子骁时光"图片画廊应用的详细步骤。

## 准备工作

1. 确保服务器上已安装Docker和Docker Compose
   ```bash
   # 检查Docker版本
   docker --version
   
   # 检查Docker Compose版本
   docker-compose --version
   ```

2. 准备Cloudinary凭证
   - 创建Cloudinary账户并获取必要的API密钥
   - 创建用于存储图片的文件夹

## 环境变量配置

部署前，需要设置以下环境变量：

```
NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_FOLDER=your_folder_path
```

有两种方式设置这些变量：

### 方法1：创建.env文件

在项目根目录创建一个.env文件，内容如下：

```
NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_FOLDER=your_folder_path
```

### 方法2：直接在docker-compose命令中传递

```bash
NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=your_cloud_name \
CLOUDINARY_API_KEY=your_api_key \
CLOUDINARY_API_SECRET=your_api_secret \
CLOUDINARY_FOLDER=your_folder_path \
docker-compose up -d
```

## 构建和启动应用

1. 克隆项目
   ```bash
   git clone https://github.com/hang1233/with-cloudinary-app.git
   cd with-cloudinary-app
   ```

2. 构建并启动Docker容器
   ```bash
   docker-compose up -d --build
   ```

   这个命令会：
   - 构建Docker镜像
   - 在后台启动容器
   - 将应用映射到主机的3000端口

3. 验证应用是否正常运行
   ```bash
   docker-compose logs -f
   ```

   访问 http://your-server-ip:3000 查看应用是否正常运行。

## 生产环境配置

对于生产环境，建议：

1. 使用Nginx作为反向代理服务器
   ```
   server {
       listen 80;
       server_name your-domain.com;
       
       location / {
           proxy_pass http://localhost:3000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

2. 配置SSL证书以启用HTTPS
   - 可以使用Let's Encrypt获取免费的SSL证书

3. 设置自动重启
   ```bash
   # 在docker-compose.yml中已配置
   restart: always
   ```

## 更新应用

当有新版本时，按照以下步骤更新：

```bash
# 拉取最新代码
git pull

# 重新构建并启动容器
docker-compose up -d --build
```

## 常见问题排查

1. 如果应用无法访问Cloudinary：
   - 检查环境变量是否正确设置
   - 验证Cloudinary API密钥是否有效

2. 如果镜像构建失败：
   - 检查日志：`docker-compose logs -f`
   - 确保服务器有足够的磁盘空间和内存

3. 如果容器启动后立即退出：
   - 检查日志：`docker-compose logs -f`
   - 验证环境变量和配置是否正确

## 性能优化建议

1. 配置Nginx缓存以提升静态资源加载速度
2. 考虑使用CDN分发图片
3. 对于高流量站点，考虑水平扩展（部署多个容器实例） 