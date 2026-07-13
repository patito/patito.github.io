# Makefile — preview local do blog (Jekyll)
#
# Uso rápido:
#   make            # instala deps (na 1ª vez) e sobe o preview em http://localhost:4000
#   make build      # gera o site de produção em ./_site
#   make clean      # limpa build e caches
#
# Observação: o Ruby do sistema (2.6) é velho demais. Este Makefile usa
# automaticamente o Ruby do Homebrew, se existir.

# O Ruby do Homebrew é keg-only (fica fora do PATH padrão) e os shims do
# rbenv na sua máquina apontam pro Ruby de sistema (2.6). Por isso detectamos
# o bindir do Ruby do Homebrew no disco e chamamos o `bundle` por caminho
# ABSOLUTO, sem depender da ordem do PATH.
RUBY_BINDIR := $(or $(wildcard /opt/homebrew/opt/ruby/bin),$(wildcard /usr/local/opt/ruby/bin))
ifneq ($(RUBY_BINDIR),)
export PATH := $(RUBY_BINDIR):$(PATH)
BUNDLE      := $(RUBY_BINDIR)/bundle
else
BUNDLE      := bundle
endif

PORT       ?= 4000
DEV_CONFIG := _config.yml,_config.dev.yml

.DEFAULT_GOAL := serve
.PHONY: help serve build drafts clean install doctor

## help: lista os comandos disponíveis
help:
	@echo "Comandos:"
	@echo "  make serve    - sobe o preview local em http://localhost:$(PORT) (livereload)"
	@echo "  make build    - gera o site de produção em ./_site"
	@echo "  make drafts   - igual ao serve, incluindo posts em _drafts/"
	@echo "  make install  - instala as dependências (gems) em ./vendor/bundle"
	@echo "  make doctor   - roda checagens do Jekyll na configuração"
	@echo "  make clean    - remove ./_site e caches"

# Instala as gems localmente (isolado em ./vendor/bundle).
vendor/bundle:
	$(BUNDLE) config set --local path vendor/bundle
	$(BUNDLE) install

## install: instala as dependências
install: vendor/bundle

## serve: preview local com auto-reload; usa _config.dev.yml (aponta o baseurl pro localhost)
serve: vendor/bundle
	$(BUNDLE) exec jekyll serve --config $(DEV_CONFIG) --port $(PORT) --livereload

## drafts: preview local incluindo rascunhos em _drafts/
drafts: vendor/bundle
	$(BUNDLE) exec jekyll serve --config $(DEV_CONFIG) --port $(PORT) --livereload --drafts

## build: build de produção (mesmo config do site publicado)
build: vendor/bundle
	JEKYLL_ENV=production $(BUNDLE) exec jekyll build

## doctor: checagens de sanidade da configuração
doctor: vendor/bundle
	$(BUNDLE) exec jekyll doctor

## clean: remove artefatos de build
clean:
	$(BUNDLE) exec jekyll clean 2>/dev/null || rm -rf _site .jekyll-cache .jekyll-metadata
