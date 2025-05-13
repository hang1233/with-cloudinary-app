# 图片画廊应用

基于 Next.js 和 Cloudinary 构建的现代化图片画廊应用程序。本应用展示如何利用 Next.js 的图片组件和 Cloudinary 的云存储服务创建高性能的图片浏览体验。

## 功能特点

- 响应式图片画廊布局
- 图片模态框查看和轮播功能
- 图片懒加载和模糊占位符
- 键盘导航支持
- 优化的移动端体验

## 技术栈

- **前端框架**: Next.js
- **语言**: TypeScript
- **样式**: Tailwind CSS
- **图片存储**: Cloudinary
- **动画**: Framer Motion

## 快速开始

### 前提条件

- Node.js 14.6.0 或更高版本
- npm 或 yarn
- Cloudinary 账户

### 安装

1. 克隆仓库
   ```bash
   git clone <仓库URL>
   cd with-cloudinary-app
   ```

2. 安装依赖
   ```bash
   npm install
   ```

3. 配置环境变量
   
   创建 `.env.local` 文件并添加以下内容：
   ```
   NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=您的云名称
   CLOUDINARY_API_KEY=您的API密钥
   CLOUDINARY_API_SECRET=您的API密钥
   CLOUDINARY_FOLDER=您的文件夹路径
   ```

### 使用Docker启动项目

项目支持使用Docker进行部署，这是在生产环境中推荐的方式。

#### 前提条件

- Docker
- Docker Compose

#### 快速启动步骤

1. 克隆仓库
   ```bash
   git clone https://github.com/hang1233/with-cloudinary-app.git
   cd with-cloudinary-app
   ```

2. 创建环境变量文件
   ```bash
   # 创建.env文件并填写Cloudinary相关信息
   cp .env.example .env
   # 使用编辑器打开.env文件
   nano .env
   ```

3. 构建并启动Docker容器
   ```bash
   # 构建并在后台启动容器
   docker-compose up -d --build
   ```

4. 访问应用
   ```
   http://localhost:3000
   ```

5. 查看容器日志
   ```bash
   docker-compose logs -f
   ```

6. 停止容器
   ```bash
   docker-compose down
   ```

#### 环境变量配置

确保在Docker部署之前设置以下环境变量：

```
NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=您的云名称
CLOUDINARY_API_KEY=您的API密钥
CLOUDINARY_API_SECRET=您的API密钥
CLOUDINARY_FOLDER=您的文件夹路径
```

您可以通过创建.env文件或直接在docker-compose命令中传递这些变量：

```bash
NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=your_name \
CLOUDINARY_API_KEY=your_key \
CLOUDINARY_API_SECRET=your_secret \
CLOUDINARY_FOLDER=your_folder \
docker-compose up -d
```

#### 查看构建状态

```bash
# 列出所有容器
docker ps

# 查看应用日志
docker-compose logs -f
```

#### 更新应用

当有代码更新时，按照以下步骤更新容器：

```bash
# 拉取最新代码
git pull

# 重新构建并启动容器
docker-compose up -d --build
```

#### 在生产环境中使用

生产环境部署建议：

1. 配置Nginx作为反向代理
2. 启用HTTPS支持
3. 设置适当的缓存策略

详细的生产环境部署指南请参考`DOCKER_DEPLOY.md`文件。

### 使用管理脚本

项目提供了两个管理脚本，用于更轻松地管理应用程序的启动、停止和监控。

#### 基本脚本 (manage.sh)

简单的管理脚本，适用于开发环境：

```bash
# 查看帮助信息
./manage.sh

# 启动应用
./manage.sh start

# 停止应用
./manage.sh stop

# 重启应用
./manage.sh restart

# 查看应用状态
./manage.sh status
```

#### 高级脚本 (manage-pro.sh)

支持开发和生产环境的高级管理脚本：

```bash
# 查看帮助信息
./manage-pro.sh

# 开发环境启动
./manage-pro.sh start --dev

# 生产环境启动（会自动构建）
./manage-pro.sh start --prod

# 构建生产版本
./manage-pro.sh build

# 停止生产环境
./manage-pro.sh stop --prod

# 查看生产环境状态
./manage-pro.sh status --prod

# 查看应用日志
./manage-pro.sh logs --dev
./manage-pro.sh logs --prod

# 查看服务器状态
./manage-pro.sh server
```

### 手动开发

如果不使用管理脚本，可以直接运行：

```bash
# 开发模式
npm run dev

# 构建生产版本
npm run build

# 启动生产服务器
npm start
```

## 项目结构

```
with-cloudinary-app/
├── components/         # 可复用组件
│   ├── Icons/          # 图标组件
│   ├── Carousel.tsx    # 图片轮播组件
│   ├── Modal.tsx       # 模态框组件
│   └── SharedModal.tsx # 共享模态框组件
├── pages/              # 页面组件
│   ├── _app.tsx        # 应用入口
│   ├── _document.tsx   # 自定义文档
│   ├── index.tsx       # 主页
│   └── p/[photoId].tsx # 图片详情页
├── public/             # 静态资源
├── styles/             # 样式文件
├── utils/              # 工具函数
│   ├── cloudinary.ts   # Cloudinary 配置
│   └── ...
├── .env.local.example  # 环境变量示例
├── next.config.js      # Next.js 配置
├── manage.sh           # 基本管理脚本
├── manage-pro.sh       # 高级管理脚本
└── README.md           # 项目文档
```

## 管理脚本功能

两个管理脚本都提供了以下核心功能：

- **进程管理**：使用 PID 文件跟踪进程状态
- **日志管理**：自动将输出重定向到日志文件
- **状态监控**：显示 CPU、内存使用情况及运行时长
- **彩色输出**：使用颜色编码使输出更易读

高级脚本额外提供：
- **环境区分**：支持开发和生产环境分离
- **服务器信息**：显示服务器和 Node.js 相关信息
- **更多日志选项**：灵活的日志查看功能

## 部署

### Vercel 部署

点击下面的按钮一键部署到 Vercel:

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/vercel/next.js/tree/canary/examples/with-cloudinary&project-name=nextjs-image-gallery&repository-name=with-cloudinary&env=NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME,CLOUDINARY_API_KEY,CLOUDINARY_API_SECRET,CLOUDINARY_FOLDER&envDescription=API%20Keys%20from%20Cloudinary%20needed%20to%20run%20this%20application.)

### 自托管部署

1. 构建生产版本
   ```bash
   npm run build
   ```

2. 启动生产服务器
   ```bash
   npm start
   ```

3. 或使用管理脚本启动生产环境
   ```bash
   ./manage-pro.sh start --prod
   ```

## Cloudinary 设置

1. 注册 [Cloudinary](https://cloudinary.com/) 账户
2. 创建一个新的文件夹用于存储图片
3. 上传图片到该文件夹
4. 获取云名称、API 密钥和 API 密钥
5. 将这些信息添加到 `.env.local` 文件中

## 贡献

欢迎贡献代码、报告问题或提出新功能建议。

## 许可证

此项目采用 MIT 许可证 - 详情请参阅 LICENSE 文件。

## References

- Cloudinary API: https://cloudinary.com/documentation/transformation_reference
