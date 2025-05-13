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
  
  # 检查端口3000是否已被占用
  if ss -tuln | grep -q ":3000 "; then
    echo -e "${RED}错误: 端口3000已被占用！${NC}"
    echo -e "${YELLOW}请先停止占用该端口的应用，或使用不同端口。${NC}"
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
  
  # 检查是否有进程在监听3000端口
  PORT_PIDS=$(ss -tulnp | grep ":3000 " | awk '{print $7}' | sed -E 's/.*pid=([0-9]+).*/\1/g')
  
  if [ -n "$PORT_PIDS" ]; then
    echo -e "${BLUE}发现监听3000端口的进程：${NC}$PORT_PIDS"
    for PID in $PORT_PIDS; do
      echo -e "${YELLOW}正在终止进程 ${NC}$PID"
      kill -15 $PID 2>/dev/null
    done
    
    # 等待进程结束
    echo -e "${BLUE}等待应用停止...${NC}"
    sleep 3
    
    # 检查进程是否仍然存在
    REMAINING_PIDS=""
    for PID in $PORT_PIDS; do
      if ps -p $PID > /dev/null 2>&1; then
        REMAINING_PIDS="$REMAINING_PIDS $PID"
      fi
    done
    
    # 如果有进程仍在运行，强制终止
    if [ -n "$REMAINING_PIDS" ]; then
      echo -e "${YELLOW}有进程未响应，强制终止：${NC}$REMAINING_PIDS"
      for PID in $REMAINING_PIDS; do
        kill -9 $PID 2>/dev/null
      done
      sleep 1
    fi
  fi
  
  # 检查PID文件是否存在
  if [ -f "$PID_FILE" ]; then
    # 获取PID文件中的进程ID
    PID=$(cat "$PID_FILE")
    
    # 检查进程是否存在
    if ps -p $PID > /dev/null 2>&1; then
      echo -e "${YELLOW}正在终止PID文件中记录的进程：${NC}$PID"
      kill -15 $PID
      sleep 2
      
      # 如果进程仍然存在，强制终止
      if ps -p $PID > /dev/null 2>&1; then
        echo -e "${YELLOW}进程未响应，强制终止：${NC}$PID"
        kill -9 $PID
        sleep 1
      fi
    else
      echo -e "${YELLOW}PID文件中的进程不存在，可能已经停止。${NC}"
    fi
    
    # 删除PID文件
    rm -f "$PID_FILE"
  else
    echo -e "${YELLOW}未找到PID文件。${NC}"
  fi
  
  # 查找可能的node/next进程
  NODE_PIDS=$(ps aux | grep "[n]ode.*next" | awk '{print $2}')
  if [ -n "$NODE_PIDS" ]; then
    echo -e "${YELLOW}发现可能相关的Node.js进程：${NC}$NODE_PIDS"
    for PID in $NODE_PIDS; do
      echo -e "${YELLOW}正在终止进程 ${NC}$PID"
      kill -15 $PID 2>/dev/null
      sleep 1
      if ps -p $PID > /dev/null 2>&1; then
        kill -9 $PID 2>/dev/null
      fi
    done
  fi
  
  # 最后检查端口是否已释放
  if ss -tuln | grep -q ":3000 "; then
    echo -e "${RED}警告：端口3000仍然被占用！${NC}"
    echo -e "${YELLOW}请使用以下命令查看占用端口的进程：${NC}"
    echo -e "ss -tulnp | grep \":3000\""
  else
    echo -e "${GREEN}应用已成功停止，端口3000已释放！${NC}"
  fi
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
  
  # 检查端口3000占用情况
  PORT_INFO=$(ss -tulnp | grep ":3000 ")
  
  if [ -n "$PORT_INFO" ]; then
    echo -e "${GREEN}端口3000已被占用，应用可能正在运行。${NC}"
    echo -e "${BLUE}端口信息：${NC}"
    echo "$PORT_INFO"
  fi
  
  # 检查PID文件是否存在
  if [ ! -f "$PID_FILE" ]; then
    if [ -z "$PORT_INFO" ]; then
      echo -e "${YELLOW}应用未运行！${NC}"
      return 1
    else
      echo -e "${YELLOW}PID文件不存在，但端口3000已被占用。${NC}"
      echo -e "${YELLOW}可能是其他进程或应用未正常退出。${NC}"
      return 1
    fi
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
    
    # 检查端口是否仍被占用
    if [ -n "$PORT_INFO" ]; then
      echo -e "${YELLOW}警告：端口3000仍被占用，可能是其他进程。${NC}"
    fi
    
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