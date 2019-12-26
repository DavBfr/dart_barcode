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

test: .coverage node_modules
	pub get
	pub global run coverage:collect_coverage --port=$(COV_PORT) -o coverage.json --resume-isolates --wait-paused &\
	dart --enable-asserts --disable-service-auth-codes --enable-vm-service=$(COV_PORT) --pause-isolates-on-exit test/all_tests.dart
	pub global run coverage:format_coverage --packages=.packages -i coverage.json --report-on lib --lcov --out lcov.info
	cat lcov.info | node_modules/.bin/lcov-summary

clean:
	git clean -fdx -e .vscode

publish: format clean
	pub publish -f

.pana:
	pub global activate pana
	touch $@

analyze: .pana
	@pub global run pana --no-warning --source path .

.dartfix:
	pub global activate dartfix
	touch $@

fix: .dartfix
	pub get
	pub global run dartfix --overwrite .

.PHONY: test format format-dart clean publish analyze
