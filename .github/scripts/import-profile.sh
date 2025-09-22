#!/bin/bash
set -euo pipefail

# 检查必要的环境变量
if [ -z "$PROVISIONING_PROFILE_DATA" ]; then
  echo "❌ 错误: PROVISIONING_PROFILE_DATA 环境变量未设置"
  exit 1
fi

# 创建配置文件目录
PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
mkdir -p "$PROFILE_DIR"

# 导入配置文件
echo "📱 正在导入配置文件..."
echo "$PROVISIONING_PROFILE_DATA" | base64 --decode > "$PROFILE_DIR/profile.mobileprovision"

# 获取配置文件UUID
PROFILE_UUID=$(grep -aA1 "UUID" "$PROFILE_DIR/profile.mobileprovision" | tail -1 | tr -d '[:space:]' | cut -d'>' -f2 | cut -d'<' -f1)

if [ -n "$PROFILE_UUID" ]; then
  # 重命名配置文件为UUID
  mv "$PROFILE_DIR/profile.mobileprovision" "$PROFILE_DIR/$PROFILE_UUID.mobileprovision"
  echo "✅ 配置文件导入成功！UUID: $PROFILE_UUID"
else
  echo "⚠️ 配置文件已导入，但无法提取UUID"
fi

# 验证导入是否成功
ls -la "$PROFILE_DIR" | grep .mobileprovision