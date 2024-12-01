#!/usr/bin/env bash

awsprof() {
	case "$1" in
	"")
		export AWS_PROFILE=""
		;;
	*)
		export AWS_PROFILE="${1}"
		;;
	esac

	echo "AWS Profile: ${AWS_PROFILE}"
}

_awsprof_completions() {
	COMPREPLY=($(compgen -W "$(
		grep '\[' ~/.aws/credentials |
			tr -d '[]'
	)" "${COMP_WORDS[1]}"))
}

complete -F _awsprof_completions awsprof

# Base64 conversion helpers
b64() {
	echo -n "$1" | base64
}
b64d() {
	echo -n "$1" | base64 -d
}

# `cdf` changes to the directory of the last commands argument
cdf() {
	cd "$(dirname "${1}")" || echo 'failed'
}

mkd() {
	mkdir -p "${1}" && cd "${1}" || return
}

gc() {
	base="${HOME}/src"

	# check http prefix otherwise assume ssh
	if [[ -z "${1##http*}" ]]; then
		server=$(echo "${1}" | sed -E 's_^https?://__' | awk -F '[/]' '{print $1}')
		org_repo=$(echo "${1%.git}" | sed -E 's_^https?://__' | awk -F '[/]' '{print $2 "/" $3}')
	else
		server=$(echo "${1}" | awk -F '[@:]' '{print $2}')
		org_repo=$(echo "${1%.git}" | awk -F '[@:]' '{print $3}')
	fi
	fullpath="${base}/${server}/${org_repo}"
	echo "${fullpath}"

	if [[ -d "${fullpath}" ]]; then
		echo "${fullpath} already exists, changing directory without re-cloning..."
	else
		git clone "${1}" "${fullpath}"
	fi
	cd "${fullpath}" || echo "*** FAILED to change directory to: ${fullpath} ***"
}

# `flushgit` deletes any branches merged with a merge commit
# squash merged branches aren't listed by git command
flushgit() {
	# handle merge commits
	git branch --merged |
		grep -v 'stashes\|master\|main' >/tmp/merged-branches &&
		vi /tmp/merged-branches &&
		xargs git branch -d </tmp/merged-branches

	# handle squash & merge (no merge commits)
	for branch in $(git branch | cut -d ' ' -f3 | grep -v '^main$'); do
		git show "$branch"
		read -r -p "git branch -D $branch - y/n?" confirm
		echo "confirmation: $confirm"
		if [[ "$confirm" == "y" ]]; then
			git branch -D "$branch"
		fi
	done
}

# `flushdns` clears DNS cache kept by systemd-resolve
flushdns() {
	sudo systemd-resolve --flush-caches
}

kdiff() {
	kitty +kitten diff "$@"
}

# kill_port sends SIGTERM to process listening on provided port
kill_port() {
	if [[ -n "$1" ]]; then
		kill "$(lsof -ti :"$1")"
	fi
}

# `kubeconfigs` looks for KUBECONFIG .yml files and exports KUBECONFIG
kubeconfigs() {

	if [[ -d "${HOME}/.kube" ]]; then

		kubeconfig_dirs=("${HOME}/.kube")
		kubeconfigs=""

		# Loop through directories looking for kubeconfigs
		for dir in "${kubeconfig_dirs[@]}"; do
			kubeconfigs+=$(find "$dir" -type f -name '*.yml' -print0 -exec \
				grep -qlr 'kind: Config' {} \; |
				xargs --null |
				sed -e 's/ /:/g')
			kubeconfigs+=":"
		done

		# Add default kube config location if it exists
		if hash "${HOME}/.kube/config" 2>/dev/null; then
			# shellcheck source=/dev/null
			kubeconfigs+="${HOME}/.kube/config:"
		fi

		# Trim trailing colon
		kubeconfigs=${kubeconfigs::-1}

		export KUBECONFIG="$kubeconfigs"
	fi
}

# Kubectl functions
kla() {
	kubectl logs -f -l "app.kubernetes.io/name=$*"
}

# I can never remember this and `nix search <package>` doesn't work on flakes.
nix_search() {
	nix-env -qaP "$@"
}

# Patchelf Binaries that use incorrect interpreter
pelf() {
	patchelf --set-interpreter "$(patchelf --print-interpreter "$(which cp)") $1"
}

r() {
	./run.sh "$@"
}

s() {
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$@"
}

# socat proxy from *:PORT to localhost:PORT - useful for kubectl/etc
sc() {
	echo "usage: sc <*:port> <localhost:port>"
	socat "tcp4-listen:${1},reuseaddr,fork" "tcp:localhost:${2}"
}
