module main

import qoi

fn main() {
	println('Hello World!')

	data := []u8{len: 400}
	result := qoi.encode(data, 10, 10, 4, 0) or { panic(err) }

	print(result.len)
}
