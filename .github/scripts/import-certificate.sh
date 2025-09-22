#!/bin/bash
set -euo pipefail

# 检查必要的环境变量
if [ -z "$SIGNING_CERTIFICATE_P12_DATA" ]; then
  echo "❌ 错误: SIGNING_CERTIFICATE_P12_DATA 环境变量未设置"
  exit 1
fi

if [ -z "$SIGNING_CERTIFICATE_PASSWORD" ]; then
  echo "❌ 错误: SIGNING_CERTIFICATE_PASSWORD 环境变量未设置"
  exit 1
fi

# 创建并配置钥匙串
security create-keychain -p "" build.keychain
security list-keychains -s build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p "" build.keychain
security set-keychain-settings

# 导入证书
echo "🔑 正在导入签名证书..."
echo "$SIGNING_CERTIFICATE_P12_DATA" | base64 --decode > signingCertificate.p12
security import signingCertificate.p12 \
                -f pkcs12 \
                -k build.keychain \
                -P "$SIGNING_CERTIFICATE_PASSWORD" \
                -T /usr/bin/codesign \
                -T /usr/bin/xcodebuild

# 设置钥匙串分区列表
security set-key-partition-list -S apple-tool:,apple: -s -k "" build.keychain

# 验证导入是否成功
echo "✅ 证书导入成功！"
security find-identity -v -p codesigning build.keychain