#!/usr/bin/env bash
set -euo pipefail

# repo 구조 예시:
#   your-repo/
#   ├── nvim/
#   │   └── init.lua
#   └── scripts/
#       └── install-neovim.sh

log() {
  printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$*"
}

fail() {
  printf "\n[ERROR] %s\n" "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "필수 명령어 없음: $1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOTFILES_NVIM_DIR="$REPO_ROOT/nvim"

INSTALL_BASE="$HOME/apps"
NVIM_DIR="$INSTALL_BASE/nvim-macos-arm64"
ARCHIVE="$INSTALL_BASE/nvim-macos-arm64.tar.gz"

BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"
TARGET_LINK="$CONFIG_DIR/nvim"
PROFILE_FILE="$HOME/.zprofile"

NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz"

require_cmd curl
require_cmd tar
require_cmd xattr
require_cmd ln
require_cmd mkdir
require_cmd rm

if [[ "$(uname -s)" != "Darwin" ]]; then
  fail "이 스크립트는 macOS 전용이다."
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  fail "이 스크립트는 Apple Silicon(arm64) 기준이다."
fi

if [[ ! -d "$DOTFILES_NVIM_DIR" ]]; then
  fail "repo 내 Neovim 설정 디렉터리가 없음: $DOTFILES_NVIM_DIR"
fi

mkdir -p "$INSTALL_BASE" "$BIN_DIR" "$CONFIG_DIR"

log "Neovim nightly 다운로드"
rm -f "$ARCHIVE"
curl -fL "$NVIM_URL" -o "$ARCHIVE"

log "기존 nightly 설치 제거"
rm -rf "$NVIM_DIR"

log "Gatekeeper 속성 제거"
xattr -c "$ARCHIVE"

log "압축 해제"
tar xzf "$ARCHIVE" -C "$INSTALL_BASE"

if [[ ! -x "$NVIM_DIR/bin/nvim" ]]; then
  fail "nvim 실행 파일이 없음: $NVIM_DIR/bin/nvim"
fi

log "~/.local/bin/nvim 링크 생성"
ln -sfn "$NVIM_DIR/bin/nvim" "$BIN_DIR/nvim"

log "~/.config/nvim 링크 생성"
if [[ -e "$TARGET_LINK" || -L "$TARGET_LINK" ]]; then
  rm -rf "$TARGET_LINK"
fi
ln -sfn "$DOTFILES_NVIM_DIR" "$TARGET_LINK"

log "PATH 설정"
if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$PROFILE_FILE" 2>/dev/null; then
  {
    echo ''
    echo '# Added by scripts/install-neovim.sh'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
  } >> "$PROFILE_FILE"
fi

export PATH="$HOME/.local/bin:$PATH"

log "설치 확인"
"$BIN_DIR/nvim" --version | head -n 5

cat <<EOF

완료

repo root:
  $REPO_ROOT

linked config:
  $TARGET_LINK -> $DOTFILES_NVIM_DIR

다음 실행:
  source "$PROFILE_FILE"
  which nvim
  nvim --version
  ls -ld "$TARGET_LINK"

EOF
