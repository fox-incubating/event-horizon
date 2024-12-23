PREFIX ::= /usr/local
CC ::= gcc
CFLAGS ::= -g -Wpedantic -fsanitize=address,undefined
XDG_DATA_HOME ::= ~/.local/share

.PHONY: prebuild
prebuild:
	cmake -S . -B ./build -G Ninja -DCMAKE_TOOLCHAIN_FILE=./build/Debug/generators/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Debug

.PHONY: build
build:
	cmake --build ./build/ --config Debug

.PHONY: install
install:
	sudo install -D ./build/keymon $(PREFIX)/bin/keymon
	install -D -m0644 ./config/keymon.service $(XDG_DATA_HOME)/systemd/user/keymon.service
	sudo install -D -m0644 ./config/keymon.sudoers /etc/sudoers.d/keymon

	sudo install -D -m0644 ./fonts/Rubik-Regular.ttf $(PREFIX)/share/launcher/fonts/Rubik-Regular.ttf
	sudo install -D ./build/launcher $(PREFIX)/bin/launcher

	systemctl --user daemon-reload
	systemctl --user enable --now keymon.service
	systemctl --user restart keymon.service

.PHONY: uninstall
uninstall:
	systemctl --user disable --now keymon.service

	sudo rm -f $(PREFIX)/bin/keymon
	rm -f $(XDG_DATA_HOME)/systemd/user/keymon.service
	sudo rm -f /etc/sudoers.d/keymon

	sudo rm -f $(PREFIX)/bin/launcher
	sudo rm -rf $(PREFIX)/share/launcher/fonts/

	systemctl --user daemon-reload
