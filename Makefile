.PHONY: all build review update clean

all: install build

install:
	gitbook install

build:
	gitbook build

review:
	gitbook serve

update:
	git pull origin master --rebase

deploy:
	gitbook install
	gitbook build -g kevingo/webapck-tutorial-gitbook

clean:
	rm -rf _book/ node_modules/