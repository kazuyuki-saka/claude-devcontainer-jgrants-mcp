#!/bin/bash

# エラー時に停止
set -e  

echo "共有volumesの作成を行います。既に存在している場合は、処理がスキップされます。"

# 共有volumes
VOLUMES=(
    "claude-code-bashhistory"
    "claude-code-config"
    "gh-config"
)

# volumeを作成
for volume in "${VOLUMES[@]}"; do
    if docker volume inspect "$volume" >/dev/null 2>&1; then
        echo "✓ $volume は既に存在します"
    else
        echo "✓ $volume を作成しました"
        docker volume create "$volume"
    fi
done

echo ""
echo "共有volumesの作成が完了しました。"
echo ""
echo "使用方法："
echo "1. 各プロジェクトの .devcontainer/docker-compose.yml で"
echo "   volumes:"
echo "     claude-code-bashhistory:"
echo "       external: true"
echo "     claude-code-config:"
echo "       external: true"
echo "     gh-config:"
echo "       external: true"
echo "   を設定してください"
echo ""
echo "2. これで複数のプロジェクト間で設定や履歴が共有されます" 