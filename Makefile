generate-js: deps
	@find transitview/coffee -name '*.coffee' | xargs coffee --no-wrap -c -o transitview/static/gen

remove-js:
	@rm -fr transitview/static/gen/

deps:
	@test `which coffee` || echo "No CoffeeScript :("

dev: generate-js
	@coffee -wc --no-wrap -l -o transitview/static/gen transitview/coffee

.PHONY: all
