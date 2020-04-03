build: 
	crystal build --single-module --release --link-flags="-shared -fpic" -o extension.so ./src/extension.cr
	mkdir -p ./webExtension
	mv ./extension.so ./webExtension/