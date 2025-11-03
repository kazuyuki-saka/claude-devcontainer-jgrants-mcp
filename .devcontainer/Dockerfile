FROM node:20

# 基本的な開発ツールをインストール
RUN apt update && apt install -y \
  git \
  less \
  procps \
  sudo \
  jq \
  python3 \
  python3-pip \
  python3-venv

# nodeユーザーにsudo権限を付与
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# デフォルトのnodeユーザーが/usr/local/shareにアクセスできるようにする
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

# npmキャッシュディレクトリを作成し、権限を設定
RUN mkdir -p /home/node/.npm && \
  chown -R node:node /home/node/.npm

# `DEVCONTAINER`環境変数を設定（VS Code自体が必要とするものではない）
# アプリケーションが開発コンテナ内で動作していることを検出し、必要に応じて特別な設定や動作を適用するためのフラグ
ENV DEVCONTAINER=true

# ワークスペースと設定ディレクトリを作成
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

# node（非root）ユーザーを設定
USER node

# npmグローバルパッケージを設定
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# npm設定でuid/gid問題を回避
ENV npm_config_unsafe_perm=true

# Claudeをインストール（エラー時の詳細表示のため--verboseを追加）
# インストール後にclaudeコマンドのシンボリックリンクを明示的に作成
RUN npm install -g @anthropic-ai/claude-code --verbose && \
    ln -sf /usr/local/share/npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js /usr/local/share/npm-global/bin/claude

# JグランツMCPをインストール
# MCPディレクトリの作成
RUN mkdir -p /home/node/mcp

# jGrants MCP serverのクローン
RUN git clone https://github.com/digital-go-jp/jgrants-mcp-server.git /home/node/mcp/jgrants

# Python仮想環境の作成とpipのアップグレード
RUN python3 -m venv /home/node/mcp/jgrants/venv && \
    /home/node/mcp/jgrants/venv/bin/pip install --upgrade pip

# 依存パッケージのインストール
RUN /home/node/mcp/jgrants/venv/bin/pip install -r /home/node/mcp/jgrants/requirements.txt

# Python仮想環境をPATHに追加
ENV PATH="/home/node/mcp/jgrants/venv/bin:$PATH"

# MCPサーバー起動スクリプトを作成
RUN echo '#!/bin/bash\ncd /home/node/mcp/jgrants && python -m jgrants_mcp_server.core --port 9000 > /tmp/mcp.log 2>&1 &' > /home/node/start-mcp.sh && \
    chmod +x /home/node/start-mcp.sh

# bashrcに起動スクリプトを追加（コンテナ起動時に自動実行）
RUN echo '\n# MCPサーバー自動起動\nif [ ! -f /tmp/mcp.pid ]; then\n  /home/node/start-mcp.sh\n  touch /tmp/mcp.pid\nfi' >> /home/node/.bashrc