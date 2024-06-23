PHONY = home local os

ifneq ($(pxy),)
no_proxy=127.0.0.1,localhost,internal.domain,my-pi,mirrors.tuna.tsinghua.edu.cn,mirror.sjtu.edu.cn,mirrors.ustc.edu.cn
all_proxy=socks5://192.168.31.142:10809
ftp_proxy=$(all_proxy)
http_proxy=$(all_proxy)
https_proxy=$(all_proxy)
rsync_proxy=$(all_proxy)
export all_proxy ftp_proxy http_proxy https_proxy no_proxy rsync_proxy
$(info -- all_proxy: $(all_proxy))
$(info -- no_proxy: $(no_proxy))
endif

dbg =
bak =
tac =

local: Tnixos-gtr5 = os
local: Tnixos-xps13 = os
local: Pnixos-xps13 = pxy-xps13
local: Tfool-GTR5 = home
local: t := $(T$(shell hostname))
local: p := $(P$(shell hostname))
local:
	$(if $(t),,$(error unsupported hostname $(shell hostname)))
	$(if $(p),$(if $(pxy),$(MAKE) $(t) sharp=$(p)))
	$(MAKE) $(t)

os: sharp =
os: _sp = $(if $(sharp),\#$(sharp))
os:
	sudo nixos-rebuild switch --flake .$(_sp) \
		$(if $(dbg), --verbose --show-trace -L)


home: s = \#
home: has_hm = $(shell which home-manager>/dev/null && echo y)
home: NIX_FALLBACK = nix run home-manager/release-23.11 --
home: NIX_FALLBACK = $(if $(pxy),$(NIX_FALLBACK),$(error need proxy enable $(has_hm)))
home: HM = $(if $(has_hm),home-manager,$(NIX_FALLBACK))
home: _dbg := $(if $(dbg), --debug)
home: _bak := $(if $(bak), -b backup)
home: _tac := $(if $(tac), --show-trace)
home: more_flags = $(_dbg)$(_bak)$(_tac)
home:
	$(HM) switch --flake .$(s)$(USER)$(more_flags)

PHONY += vm
vm:
	colmena apply --on vm-nixos

PHONY += pi
pi:
	colmena apply --on pi4b

_dev_ln = rm -f $1 && cd $(dir $1) && ln $(CURDIR)/$2 $(notdir $1)

PHONY += dev-nvim
dev-nvim: c = $(call _dev_ln,$(HOME)/$1,assets/nvim/$2)
dev-nvim:
	$(call c,.vimrc,vimrc)
	$(call c,.vim/init.lua,init.lua)
	$(call c,.config/nvim/init.vim,init.vim)
	$(call c,.lintd/nvim/lsp.lua,lsp.lua)

.PHONY: $(PHONY)
