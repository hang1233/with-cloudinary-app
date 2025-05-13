#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 项目目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$PROJECT_DIR/.nextjs.pid"
LOG_FILE="$PROJECT_DIR/.nextjs.log"

# 显示帮助信息
show_help() {
  echo -e "${BLUE}图片画廊应用管理脚本${NC}"
  echo -e "用法: $0 [选项]"
  echo
  echo -e "选项:"
  echo -e "  ${GREEN}start${NC}     启动应用"
  echo -e "  ${RED}stop${NC}      停止应用"
  echo -e "  ${YELLOW}restart${NC}   重启应用"
  echo -e "  ${BLUE}status${NC}    查看应用状态"
  echo -e "  ${NC}help${NC}      显示帮助信息"
}

# 启动应用
start_app() {
  echo -e "${GREEN}正在启动图片画廊应用...${NC}"
  
  # 检查应用是否已经运行
  if [ -f "$PID_FILE" ] && ps -p $(cat "$PID_FILE") > /dev/null; then
    echo -e "${YELLOW}应用已经在运行中！${NC}"
    return 1
  fi
  
  # 切换到项目目录
  cd "$PROJECT_DIR"
  
  # 启动应用（开发模式）
  npm run dev > "$LOG_FILE" 2>&1 &
  
  # 保存进程ID
  echo $! > "$PID_FILE"
  
  # 等待应用启动
  echo -e "${BLUE}等待应用启动...${NC}"
  sleep 5
  
  # 检查应用是否成功启动
  if [ -f "$PID_FILE" ] && ps -p $(cat "$PID_FILE") > /dev/null; then
    echo -e "${GREEN}应用已成功启动！${NC}"
    echo -e "${BLUE}访问地址: ${NC}http://localhost:3000"
    echo -e "${BLUE}日志文件: ${NC}$LOG_FILE"
  else
    echo -e "${RED}应用启动失败，请检查日志文件：${NC}$LOG_FILE"
    return 1
  fi
}

# 停止应用
stop_app() {
  echo -e "${YELLOW}正在停止图片画廊应用...${NC}"
  
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
  echo -e "${BLUE}正在重启图片画廊应用...${NC}"
  stop_app
  sleep 2
  start_app
}

# 查看应用状态
check_status() {
  echo -e "${BLUE}检查图片画廊应用状态...${NC}"
  
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
    echo -e "${BLUE}进程ID: ${NC}$PID"
    echo -e "${BLUE}访问地址: ${NC}http://localhost:3000"
    echo -e "${BLUE}运行时长: ${NC}$(ps -o etime= -p $PID)"
    echo -e "${BLUE}内存使用: ${NC}$(ps -o %mem= -p $PID)%"
    echo -e "${BLUE}CPU使用: ${NC}$(ps -o %cpu= -p $PID)%"
    echo -e "${BLUE}日志文件: ${NC}$LOG_FILE"
    
    # 显示最近的日志
    echo -e "${BLUE}最近日志 (最后10行):${NC}"
    if [ -f "$LOG_FILE" ]; then
      tail -n 10 "$LOG_FILE"
    else
      echo -e "${YELLOW}日志文件不存在！${NC}"
    fi
  else
    echo -e "${YELLOW}应用进程不存在，但PID文件存在！${NC}"
    echo -e "${YELLOW}清理PID文件...${NC}"
    rm -f "$PID_FILE"
    return 1
  fi
}

# 命令分发
case "$1" in
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
  *)
    show_help
    ;;
esac

exit 0 