system_config() {
  case "$1" in
    "gentoo-server")
      echo "IMAGE_SIZE=3G"
      echo "IS_DESKTOP=false"
      echo "DESKTOP_ENV="
      echo "GENTOO_STAGE3_URL=${GENTOO_STAGE3_URL:-}"
      ;;
    *)
      echo "IMAGE_SIZE=3G"
      echo "IS_DESKTOP=false"
      echo "DESKTOP_ENV="
      ;;
  esac
}
