#!/usr/bin/env bash
# Machine-readable software inventory. Read-only. No head caps. Output sections: "=== name ===".
export LC_ALL=C
S() { printf '\n=== %s ===\n' "$1"; }
S dpkg;        dpkg-query -W -f='${Package}\t${Version}\t${Architecture}\n' 2>&1 | sort
S dpkg_manual; apt-mark showmanual 2>&1 | sort
S tools
ver() { # name  command...
  local n=$1; shift; local p; p=$(command -v "$n" 2>/dev/null) || { printf 'MISSING\t%s\n' "$n"; return; }
  printf 'HAVE\t%s\t%s\t%s\n' "$n" "$p" "$(timeout 15 "$@" 2>&1 | head -1 | tr -d '\r' | cut -c1-120)"
}
for t in git gh curl wget jq yq tar zip unzip 7z zstd xz bzip2 rsync ssh sshpass openssl gpg sqlite3 psql pg_config mysql mysqld mongod redis-server redis-cli memcached nginx apache2 haproxy sudo zsh fish bash dash tcsh ksh vim nano less tree htop lsof strace ltrace gdb perf tcpdump nc nmap dig nslookup traceroute ping ip ss iptables nft tmux screen parallel shellcheck ccache sccache mold lld ninja make cmake meson bazel bazelisk pkg-config autoconf automake libtool bison flex nasm gfortran gcc g++ cc c++ clang clang++ clang-format clang-tidy llvm-config rustc cargo rustup rustfmt clippy-driver go gofmt node npm npx yarn pnpm bun deno python python3 pip pip3 pipx pytest uv poetry virtualenv conda ruby gem bundle bundler rake java javac mvn gradle ant sbt kotlin kotlinc scala groovy dotnet pwsh php composer perl R julia swift swiftc erl elixir mix ghc cabal stack ghcup opam ocaml lein clojure docker docker-compose containerd ctr runc podman buildah skopeo nerdctl kubectl kind minikube helm kustomize terraform packer vagrant ansible pulumi az aws gcloud sam azcopy oc doctl sops age direnv mise asdf just task actionlint hadolint yamllint firefox google-chrome chromium chromium-browser chromedriver geckodriver microsoft-edge msedgedriver xvfb-run Xvfb playwright convert magick ffmpeg sox tesseract tcl wish snap flatpak systemctl journalctl loginctl busctl resolvectl timedatectl hostnamectl lsblk lspci lsusb dmesg modprobe lsmod fallocate setfattr getfattr fuse-overlayfs fusermount3 mke2fs mkfs.ext4 mkfs.xfs e2fsck losetup mount umount unshare nsenter setpriv capsh newuidmap newgidmap qemu-system-x86_64 qemu-img kvm virsh cloud-init walinuxagent waagent hv_kvp_daemon unattended-upgrade needrestart apt apt-get dpkg aptitude; do
  case $t in
    gcc|g++|cc|c++|clang|clang++|gfortran|make|cmake|ninja|go|java|javac|ant|kotlin|kotlinc|ruby|gem|bundle|node|npm|npx|yarn|pnpm|python|python3|pip|pip3|pipx|perl|php|composer|dotnet|bash|dash|zsh|fish|ssh|gdb|ltrace|strace|tmux|screen|tree|vim|htop|cargo|rustc|rustup|rustfmt|packer|terraform|kubectl|helm|az|aws|gcloud|git|gh|jq|yq|curl|wget|nginx|apache2|haproxy|tcpdump|nmap|sudo|openssl|gpg|sqlite3|psql|mysql|mongod|redis-server|conda|julia|swift|swiftc|R|mvn|gradle|sbt|docker|docker-compose|podman|buildah|skopeo|ansible|pulumi|just|task|actionlint|hadolint|shellcheck|direnv|mise|firefox|google-chrome|chromium|chromedriver|geckodriver|microsoft-edge|msedgedriver|playwright|ffmpeg|bazel) ver "$t" "$t" --version ;;
    sudo|ip) ver "$t" "$t" -V ;;
    nc) ver "$t" "$t" -h ;;
    *) ver "$t" "$t" --version ;;
  esac
done
S go_docker_extra; docker compose version 2>&1; docker buildx version 2>&1; docker info --format '{{.ServerVersion}} {{.Driver}} {{.CgroupDriver}} {{.CgroupVersion}} {{.DockerRootDir}} {{.NCPU}} {{.MemTotal}}' 2>&1; docker images --format '{{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}' 2>&1
S hostedtoolcache; find /opt/hostedtoolcache -maxdepth 3 -mindepth 2 -type d 2>&1 | sort
S dirs_depth2
for d in /usr/local/bin /usr/local/lib /usr/local/share /opt /opt/pipx_bin /opt/pipx /opt/az /usr/lib/jvm /usr/share/dotnet/sdk /usr/share/dotnet/shared /usr/share/miniconda/envs /usr/local/lib/android/sdk /usr/local/lib/android/sdk/build-tools /usr/local/lib/android/sdk/platforms /usr/local/lib/android/sdk/ndk /usr/local/share/chromedriver-linux64 /usr/local/share/gecko_driver /usr/local/share/edge_driver /usr/local/share/vcpkg /usr/share/swift /usr/share/gradle* /usr/share/ant /home/runner /home/runner/.nvm/versions/node /home/runner/.cargo/bin /home/runner/.rustup/toolchains /home/runner/.local/bin /root /etc/skel /etc/sudoers.d /etc/profile.d /etc/security/limits.d /etc/sysctl.d /etc/systemd/system /etc/docker /etc/apt/sources.list.d /etc/cloud /var/lib/cloud /imagegeneration; do
  [ -e "$d" ] && { echo "--- $d"; ls -A1 "$d" 2>&1 | head -400; }
done
S language_pkgs; pip3 list --format=freeze 2>&1; echo ---pipx; pipx list --short 2>&1; echo ---npm-g; npm ls -g --depth=0 --parseable 2>&1; echo ---gem; gem list 2>&1; echo ---cargo; cargo install --list 2>&1; echo ---go; ls "$(go env GOPATH 2>/dev/null)/bin" 2>&1; echo ---brew; ls /home/linuxbrew/.linuxbrew/bin 2>&1 | head -50
S etc_files
for f in /etc/environment /etc/hosts /etc/hostname /etc/resolv.conf /etc/nsswitch.conf /etc/fstab /etc/docker/daemon.json /etc/sudoers /etc/security/limits.conf /etc/default/locale /etc/locale.gen /etc/timezone /etc/apt/apt.conf.d/99-azure-* /etc/apt/apt.conf.d/20auto-upgrades /etc/systemd/system.conf /etc/systemd/resolved.conf /etc/modules-load.d/*.conf /etc/modprobe.d/*.conf /etc/ld.so.conf.d/*.conf /etc/ssh/sshd_config /etc/ssh/ssh_config /etc/gitconfig /etc/profile; do
  for x in $f; do [ -f "$x" ] && { echo "--- $x"; (sudo -n cat "$x" 2>/dev/null || cat "$x" 2>&1) | grep -vE '^\s*#|^\s*$' | head -80; }; done
done
S systemd_units; systemctl list-unit-files --no-legend 2>&1 | sort | head -400; echo ---running; systemctl list-units --type=service --state=running --no-legend 2>&1
S env_full; env | sort | sed -E 's/((TOKEN|SECRET|PASSWORD|AUTH|KEY)[A-Z_]*=).*/\1<redacted>/I'
S mount_namespaces; cat /proc/self/mountinfo | head -120
S proc_tree; ps -eo pid,ppid,user,stat,etimes,comm,args --forest 2>&1 | cut -c1-200
S done; echo inventory-complete
