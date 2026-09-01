#!/usr/bin/env bash
# dev-made-easy — Installer
#
# Usage:
#   bash install.sh --global                    Install agents globally (~/.claude/agents/)
#   bash install.sh --local                     Install agents in current project (.claude/agents/)
#   bash install.sh --path /path/to/other/repo  Install agents into a different repository
#   bash install.sh                             Interactive prompt (choose 1, 2, or 3)
#   bash install.sh --update-cache                Force-sync agents into the plugin cache
#   bash install.sh --uninstall --global
#   bash install.sh --uninstall --local
#   bash install.sh --uninstall --path /path/to/other/repo
#
# About the --path option:
#   Use this when you want to install the agents into a repository that is already
#   checked out on your machine but is separate from this plugin directory.
#   The installer copies all agent .md files into <path>/.claude/agents/, creating
#   the directory if it does not exist. This is ideal for:
#     - Team repos where you want the agents committed alongside the project
#     - Monorepos with multiple services that share the same pipeline
#     - Testing the agents in a sandbox repo before committing to global install
#
#   Example:
#     bash install.sh --path ~/projects/my-api
#     Installs into: ~/projects/my-api/.claude/agents/

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SRC="$PLUGIN_DIR/agents"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}checkmark${NC} $1"; }
print_warn()    { echo -e "${YELLOW}warning${NC} $1"; }
print_error()   { echo -e "${RED}error${NC} $1"; }

print_header() {
  echo ""
  echo "================================================="
  echo "  Development Plugin — Installer"
  echo "================================================="
  echo ""
}

determine_target() {
  local mode="${1:-}"
  local custom_path="${2:-}"

  case "$mode" in
    --global)
      TARGET_DIR="$HOME/.claude/agents"
      INSTALL_TYPE="global"
      ;;
    --local)
      TARGET_DIR="$(pwd)/.claude/agents"
      INSTALL_TYPE="project-local"
      ;;
    --path)
      if [[ -z "$custom_path" ]]; then
        print_error "No path provided. Usage: bash install.sh --path /path/to/repo"
        exit 1
      fi
      if [[ ! -d "$custom_path" ]]; then
        print_error "Path does not exist: $custom_path"
        print_error "Provide the root of an existing repository."
        exit 1
      fi
      TARGET_DIR="${custom_path%/}/.claude/agents"
      INSTALL_TYPE="custom ($custom_path)"
      ;;
    *)
      echo "Where would you like to install the agents?"
      echo ""
      echo "  1) Global       — available in all your projects"
      echo "                    installs to: ~/.claude/agents/"
      echo ""
      echo "  2) Local        — available in this project only"
      echo "                    installs to: .claude/agents/ (current directory)"
      echo ""
      echo "  3) Custom path  — install into a different repository on your machine"
      echo "                    useful for team repos, monorepos, or sandbox testing"
      echo "                    installs to: <your-path>/.claude/agents/"
      echo ""
      read -rp "Enter 1, 2, or 3: " choice
      case "$choice" in
        1)
          TARGET_DIR="$HOME/.claude/agents"
          INSTALL_TYPE="global"
          ;;
        2)
          TARGET_DIR="$(pwd)/.claude/agents"
          INSTALL_TYPE="project-local"
          ;;
        3)
          echo ""
          echo "Enter the full path to the target repository root."
          echo "Example: ~/projects/my-api  or  /Users/you/work/foldername"
          echo ""
          read -rp "Repository path: " custom_path
          custom_path="${custom_path/#\~/$HOME}"  # expand ~ manually
          if [[ -z "$custom_path" || ! -d "$custom_path" ]]; then
            print_error "Path does not exist: $custom_path"
            print_error "Provide the root of an existing repository and try again."
            exit 1
          fi
          TARGET_DIR="${custom_path%/}/.claude/agents"
          INSTALL_TYPE="custom ($custom_path)"
          ;;
        *)
          print_error "Invalid choice. Run again and enter 1, 2, or 3."
          exit 1
          ;;
      esac
      ;;
  esac
}

install_agents() {
  echo "Installing agents ($INSTALL_TYPE) to: $TARGET_DIR"
  echo ""

  mkdir -p "$TARGET_DIR"

  if ! ls "$AGENTS_SRC"/*.md &>/dev/null; then
    print_error "No agent files found in $AGENTS_SRC"
    exit 1
  fi

  local count=0
  for agent_file in "$AGENTS_SRC"/*.md; do
    filename="$(basename "$agent_file")"
    dest="$TARGET_DIR/$filename"

    if [[ -f "$dest" ]]; then
      print_warn "Overwriting existing: $filename"
    fi

    cp "$agent_file" "$dest"
    print_success "Installed: $filename"
    ((count++))
  done

  echo ""
  echo "================================================="
  print_success "$count agents installed ($INSTALL_TYPE)"
  echo "================================================="
  echo ""
  echo "Start the pipeline in Claude Code:"
  echo ""
  echo '  @dev-made-easy:Development Orchestrator'
  echo ""
}

uninstall_agents() {
  local target_flag="${1:-}"
  local custom_path="${2:-}"
  local target

  case "$target_flag" in
    --global) target="$HOME/.claude/agents" ;;
    --local)  target="$(pwd)/.claude/agents" ;;
    --path)
      if [[ -z "$custom_path" ]]; then
        print_error "No path provided. Usage: bash install.sh --uninstall --path /path/to/repo"
        exit 1
      fi
      target="${custom_path%/}/.claude/agents"
      ;;
    *)
      print_error "Specify --global, --local, or --path <dir> with --uninstall"
      exit 1
      ;;
  esac

  echo "Uninstalling agents from: $target"
  echo ""

  local count=0
  for agent_file in "$AGENTS_SRC"/*.md; do
    filename="$(basename "$agent_file")"
    dest="$target/$filename"
    if [[ -f "$dest" ]]; then
      rm "$dest"
      print_success "Removed: $filename"
      ((count++))
    fi
  done

  echo ""
  print_success "$count agents removed."
}

update_cache() {
  local cache_dir="$HOME/.claude/plugins/cache/agentic-development/dev-made-easy"

  # Find the versioned cache directory (e.g., 1.0.0/)
  if [[ ! -d "$cache_dir" ]]; then
    print_error "Plugin cache not found at: $cache_dir"
    print_error "Install the plugin first: claude plugin install dev-made-easy@agentic-development --scope user"
    exit 1
  fi

  local version_dir
  version_dir=$(find "$cache_dir" -mindepth 1 -maxdepth 1 -type d | head -1)

  if [[ -z "$version_dir" || ! -d "$version_dir/agents" ]]; then
    print_error "No versioned cache directory found under: $cache_dir"
    exit 1
  fi

  echo "Force-syncing agents to plugin cache..."
  echo "  Source: $AGENTS_SRC/"
  echo "  Target: $version_dir/agents/"
  echo ""

  local count=0
  for agent_file in "$AGENTS_SRC"/*.md; do
    filename="$(basename "$agent_file")"
    cp "$agent_file" "$version_dir/agents/$filename"
    print_success "Synced: $filename"
    ((count++))
  done

  echo ""
  echo "================================================="
  print_success "$count agents synced to plugin cache"
  echo "================================================="
  echo ""
  echo "Now run /reload-plugins inside your Claude Code session."
  echo ""

  # Verify
  local mismatches=0
  for agent_file in "$AGENTS_SRC"/*.md; do
    filename="$(basename "$agent_file")"
    if ! diff -q "$agent_file" "$version_dir/agents/$filename" &>/dev/null; then
      print_error "MISMATCH: $filename"
      ((mismatches++))
    fi
  done

  if [[ "$mismatches" -eq 0 ]]; then
    print_success "Verification passed — all agents match"
  else
    print_error "$mismatches file(s) did not match after copy"
    exit 1
  fi
}

main() {
  print_header

  local mode="${1:-}"

  if [[ "$mode" == "--uninstall" ]]; then
    uninstall_agents "${2:-}" "${3:-}"
    exit 0
  fi

  if [[ "$mode" == "--update-cache" ]]; then
    update_cache
    exit 0
  fi

  determine_target "$mode" "${2:-}"
  install_agents
}

main "$@"
