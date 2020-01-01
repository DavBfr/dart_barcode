 # Copyright (C) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 #     http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.

 DART_SRC=$(shell find . -name '*.dart')
 COV_PORT=9292

all: format

format: format-dart

format-dart: $(DART_SRC)
	dartfmt -w --fix $^

.coverage:
	pub global activate coverage
	touch $@

node_modules:
	npm install lcov-summary

test-barcode: .coverage
	cd barcode; pub get
	cd barcode; pub global run coverage:collect_coverage --port=$(COV_PORT) -o coverage.json --resume-isolates --wait-paused &\
	dart --enable-asserts --disable-service-auth-codes --enable-vm-service=$(COV_PORT) --pause-isolates-on-exit test/all_tests.dart
	cd barcode; pub global run coverage:format_coverage --packages=.packages -i coverage.json --report-on lib --lcov --out ../lcov-tests.info

test: node_modules test-barcode barcodes
	lcov --add-tracefile lcov-tests.info -t test1 -a lcov-example.info -t test2 -o lcov.info
	cat lcov.info | node_modules/.bin/lcov-summary

clean:
	git clean -fdx -e .vscode

publish-barcode: format clean
	@find barcode -name pubspec.yaml -exec sed -i -e 's/^dependency_overrides:/_dependency_overrides:/g' '{}' ';'
	cd barcode; pub publish -f
	@find barcode -name pubspec.yaml -exec sed -i -e 's/^_dependency_overrides:/dependency_overrides:/g' '{}' ';'

publish-flutter: format clean
	@find flutter -name pubspec.yaml -exec sed -i -e 's/^dependency_overrides:/_dependency_overrides:/g' '{}' ';'
	cd flutter; pub publish -f
	@find flutter -name pubspec.yaml -exec sed -i -e 's/^_dependency_overrides:/dependency_overrides:/g' '{}' ';'

publish-image: format clean
	@find image -name pubspec.yaml -exec sed -i -e 's/^dependency_overrides:/_dependency_overrides:/g' '{}' ';'
	cd image; pub publish -f
	@find image -name pubspec.yaml -exec sed -i -e 's/^_dependency_overrides:/dependency_overrides:/g' '{}' ';'

.pana:
	pub global activate pana
	touch $@

analyze-barcode: .pana
	@find barcode -name pubspec.yaml -exec sed -i -e 's/^dependency_overrides:/_dependency_overrides:/g' '{}' ';'
	@pub global run pana --no-warning --source path barcode
	@find barcode -name pubspec.yaml -exec sed -i -e 's/^_dependency_overrides:/dependency_overrides:/g' '{}' ';'

analyze-flutter: .pana
	@find flutter -name pubspec.yaml -exec sed -i -e 's/^dependency_overrides:/_dependency_overrides:/g' '{}' ';'
	rm -f flutter/pubspec.lock
	@flutter pub global run pana --no-warning --source path flutter
	@find flutter -name pubspec.yaml -exec sed -i -e 's/^_dependency_overrides:/dependency_overrides:/g' '{}' ';'

analyze-image: .pana
	@find image -name pubspec.yaml -exec sed -i -e 's/^dependency_overrides:/_dependency_overrides:/g' '{}' ';'
	@pub global run pana --no-warning --source path image
	@find image -name pubspec.yaml -exec sed -i -e 's/^_dependency_overrides:/dependency_overrides:/g' '{}' ';'

.dartfix:
	pub global activate dartfix
	touch $@

fix: .dartfix
	cd barcode; pub get
	cd barcode; pub global run dartfix --overwrite .

barcodes: .coverage
	cd barcode; pub global run coverage:collect_coverage --port=$(COV_PORT) -o coverage.json --resume-isolates --wait-paused &\
	dart --enable-asserts --disable-service-auth-codes --enable-vm-service=$(COV_PORT) --pause-isolates-on-exit example/main.dart
	cd barcode; pub global run coverage:format_coverage --packages=.packages -i coverage.json --report-on lib --lcov --out ../lcov-example.info
	mv -f barcode/*.svg img/

maps: build_maps.py
	python3 build_maps.py > barcode/lib/src/barcode_maps.dart
	dartfmt -w --fix barcode/lib/src/barcode_maps.dart

gh-pages:
	test -z "$(shell git status --porcelain)"
	cd flutter/example; flutter build web
	git checkout gh-pages
	cp -rf flutter/example/build/web/* .

get:
	cd barcode; pub get
	cd flutter; flutter packages get
	cd image; pub get

.PHONY: test format format-dart clean publish analyze
