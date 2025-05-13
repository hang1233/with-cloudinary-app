#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # 无颜色

# 项目目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE_DEV="$PROJECT_DIR/.nextjs-dev.pid"
PID_FILE_PROD="$PROJECT_DIR/.nextjs-prod.pid"
LOG_FILE_DEV="$PROJECT_DIR/.nextjs-dev.log"
LOG_FILE_PROD="$PROJECT_DIR/.nextjs-prod.log"

# 默认环境
ENV="dev"

# 显示帮助信息
show_help() {
  echo -e "${BLUE}图片画廊应用高级管理脚本${NC}"
  echo -e "用法: $0 [命令] [选项]"
  echo
  echo -e "命令:"
  echo -e "  ${GREEN}start${NC}     启动应用"
  echo -e "  ${RED}stop${NC}      停止应用"
  echo -e "  ${YELLOW}restart${NC}   重启应用"
  echo -e "  ${BLUE}status${NC}    查看应用状态"
  echo -e "  ${CYAN}logs${NC}      查看应用日志"
  echo -e "  ${CYAN}build${NC}     构建生产版本"
  echo -e "  ${NC}help${NC}      显示帮助信息"
  echo
  echo -e "选项:"
  echo -e "  ${GREEN}--dev${NC}     开发环境 (默认)"
  echo -e "  ${YELLOW}--prod${NC}    生产环境"
  echo
  echo -e "示例:"
  echo -e "  $0 start --dev     # 开发模式启动"
  echo -e "  $0 start --prod    # 生产模式启动"
  echo -e "  $0 logs --prod     # 查看生产环境日志"
}

# 解析参数
parse_args() {
  CMD=$1
  shift
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dev)
        ENV="dev"
        ;;
      --prod)
        ENV="prod"
        ;;
      *)
        echo -e "${RED}未知选项: $1${NC}"
        show_help
        exit 1
        ;;
    esac
    shift
  done
  
  # 根据环境设置PID和LOG文件
  if [[ "$ENV" == "dev" ]]; then
    PID_FILE="$PID_FILE_DEV"
    LOG_FILE="$LOG_FILE_DEV"
  else
    PID_FILE="$PID_FILE_PROD"
    LOG_FILE="$LOG_FILE_PROD"
  fi
}

# 构建生产版本
build_app() {
  echo -e "${BLUE}正在构建生产版本...${NC}"
  cd "$PROJECT_DIR"
  
  # 构建应用
  npm run build
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}构建成功！${NC}"
  else
    echo -e "${RED}构建失败！${NC}"
    return 1
  fi
}

# 启动应用
start_app() {
  echo -e "${GREEN}正在启动图片画廊应用 (${ENV}环境)...${NC}"
  
  # 检查应用是否已经运行
  if [ -f "$PID_FILE" ] && ps -p $(cat "$PID_FILE") > /dev/null; then
    echo -e "${YELLOW}应用已经在运行中！${NC}"
    return 1
  fi
  
  # 切换到项目目录
  cd "$PROJECT_DIR"
  
  # 根据环境启动应用
  if [[ "$ENV" == "dev" ]]; then
    # 开发模式
    npm run dev > "$LOG_FILE" 2>&1 &
  else
    # 生产模式 - 先检查是否已经构建
    if [ ! -d "$PROJECT_DIR/.next" ]; then
      echo -e "${YELLOW}生产版本尚未构建，正在构建...${NC}"
      build_app
      if [ $? -ne 0 ]; then
        return 1
      fi
    fi
    
    # 启动生产服务器
    npm start > "$LOG_FILE" 2>&1 &
  fi
  
  # 保存进程ID
  echo $! > "$PID_FILE"
  
  # 等待应用启动
  echo -e "${BLUE}等待应用启动...${NC}"
  sleep 5
  
  # 检查应用是否成功启动
  if [ -f "$PID_FILE" ] && ps -p $(cat "$PID_FILE") > /dev/null; then
    echo -e "${GREEN}应用已成功启动！${NC}"
    echo -e "${BLUE}环境: ${NC}${ENV}"
    echo -e "${BLUE}访问地址: ${NC}http://localhost:3000"
    echo -e "${BLUE}日志文件: ${NC}$LOG_FILE"
  else
    echo -e "${RED}应用启动失败，请检查日志文件：${NC}$LOG_FILE"
    return 1
  fi
}

# 停止应用
stop_app() {
  echo -e "${YELLOW}正在停止图片画廊应用 (${ENV}环境)...${NC}"
  
  # 检查PID文件是否存在
  if [ ! -f "$PID_FILE" ]; then
    echo -e "${YELLOW}应用未运行！${NC}"
    return 0
  fi
  
  # 获取进程ID
  PID=$(cat "$PID_FILE")
  
  # 检查进程是否存在
  if ! ps -p $PID > /dev/null; then
    echo -e "${YELLOW}应用进程不存在，可能已经停止！${NC}"
    rm -f "$PID_FILE"
    return 0
  fi
  
  # 先尝试优雅停止
  kill -15 $PID
  
  # 等待进程结束
  echo -e "${BLUE}等待应用停止...${NC}"
  sleep 3
  
  # 检查进程是否仍然存在
  if ps -p $PID > /dev/null; then
    echo -e "${YELLOW}应用未响应，强制终止...${NC}"
    kill -9 $PID
    sleep 1
  fi
  
  # 删除PID文件
  rm -f "$PID_FILE"
  
  echo -e "${GREEN}应用已停止！${NC}"
}

# 重启应用
restart_app() {
  echo -e "${BLUE}正在重启图片画廊应用 (${ENV}环境)...${NC}"
  stop_app
  sleep 2
  start_app
}

# 查看应用状态
check_status() {
  echo -e "${BLUE}检查图片画廊应用状态 (${ENV}环境)...${NC}"
  
  # 检查PID文件是否存在
  if [ ! -f "$PID_FILE" ]; then
    echo -e "${YELLOW}应用未运行！${NC}"
    return 1
  fi
  
  # 获取进程ID
  PID=$(cat "$PID_FILE")
  
  # 检查进程是否存在
  if ps -p $PID > /dev/null; then
    echo -e "${GREEN}应用正在运行！${NC}"
    echo -e "${BLUE}环境: ${NC}${ENV}"
    echo -e "${BLUE}进程ID: ${NC}$PID"
    echo -e "${BLUE}访问地址: ${NC}http://localhost:3000"
    echo -e "${BLUE}运行时长: ${NC}$(ps -o etime= -p $PID)"
    echo -e "${BLUE}内存使用: ${NC}$(ps -o %mem= -p $PID)%"
    echo -e "${BLUE}CPU使用: ${NC}$(ps -o %cpu= -p $PID)%"
    echo -e "${BLUE}日志文件: ${NC}$LOG_FILE"
    
    # 显示最近的日志
    echo -e "${BLUE}最近日志 (最后10行):${NC}"
    show_logs 10
  else
    echo -e "${YELLOW}应用进程不存在，但PID文件存在！${NC}"
    echo -e "${YELLOW}清理PID文件...${NC}"
    rm -f "$PID_FILE"
    return 1
  fi
}

# 查看日志
show_logs() {
  LINES=${1:-50}
  
  if [ ! -f "$LOG_FILE" ]; then
    echo -e "${YELLOW}日志文件不存在！${NC}"
    return 1
  fi
  
  echo -e "${BLUE}显示 ${ENV} 环境日志 (最后 $LINES 行):${NC}"
  tail -n $LINES "$LOG_FILE"
}

# 检查服务器状态
check_server() {
  echo -e "${BLUE}检查服务器状态...${NC}"
  
  # 系统信息
  echo -e "${CYAN}系统信息:${NC}"
  echo -e "  操作系统: $(uname -s)"
  echo -e "  主机名: $(hostname)"
  echo -e "  内核版本: $(uname -r)"
  
  # CPU信息
  echo -e "${CYAN}CPU使用率:${NC}"
  top -bn1 | grep "Cpu(s)" | awk '{print "  " $2 "% 用户, " $4 "% 系统, " $8 "% 空闲"}'
  
  # 内存信息
  echo -e "${CYAN}内存使用:${NC}"
  free -h | grep "Mem:" | awk '{print "  总计: " $2 ", 已用: " $3 ", 空闲: " $4}'
  
  # 磁盘信息
  echo -e "${CYAN}磁盘使用:${NC}"
  df -h | grep -E "/$" | awk '{print "  总计: " $2 ", 已用: " $3 " (" $5 "), 可用: " $4}'
  
  # Node.js信息
  echo -e "${CYAN}Node.js版本:${NC}"
  node -v | awk '{print "  " $1}'
  
  # npm信息
  echo -e "${CYAN}npm版本:${NC}"
  npm -v | awk '{print "  " $1}'
}

# 主程序
parse_args "$@"

case "$CMD" in
  start)
    start_app
    ;;
  stop)
    stop_app
    ;;
  restart)
    restart_app
    ;;
  status)
    check_status
    ;;
  logs)
    show_logs 50
    ;;
  build)
    build_app
    ;;
  server)
    check_server
    ;;
  *)
    show_help
    ;;
esac

exit 0 