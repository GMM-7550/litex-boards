board_dir := "litex_boards/targets/gmm7550"

build:
  make -C {{board_dir}}
  python {{board_dir}}_usb3.py --build --cpu-variant=lite --with-async-ram --usb pd 1 3

clean:
  make -C {{board_dir}} clean
  rm -rf build/
