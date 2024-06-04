module main

import qoi

fn main() {
	println('Hello World!')

	a := []u8{}
	b := qoi.Decoder{10, 10, qoi.Channels.rgb, qoi.Colorspace.linear}
	mut c := 0

	qoi.encode(a, b, mut c) or { return }
}
