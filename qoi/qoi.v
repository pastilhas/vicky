module qoi

enum Colorspace as u8 {
	qoi_srgb
	qoi_linear
}

struct Decoder {
	width      u32
	height     u32
	channels   u8
	colorspace Colorspace
}

struct Rgba32_Component {
	r u8
	g u8
	b u8
	a u8
}

union Rgba32 {
	Rgba32_Component
	value u32
}

const op_index = u8(0x00)
const op_diff = u8(0x40)
const op_luma = u8(0x80)
const op_run = u8(0xc0)
const op_rgb = u8(0xfe)
const op_rgba = u8(0xff)
const mask_2 = u8(0xc0)
const magic = u32('q'.u32() << 24 | 'o'.u32() << 16 | 'i'.u32() << 8 | 'f'.u32())
const header_size = u32(14)
const max_pixels = u32(400_000_000)
const padding = [u8(0), 0, 0, 0, 0, 0, 0, 1]

fn write_int(mut bytes []u8, mut p &int, v u32) {
	bytes[*p] = u8(v >> 24 & 0x000000ff)
	bytes[*p + 1] = u8(v >> 16 & 0x000000ff)
	bytes[*p + 2] = u8(v >> 8 & 0x000000ff)
	bytes[*p + 3] = u8(v & 0x000000ff)
	unsafe {
		*p = *p + 4
	}
}

fn read_int(bytes []u8, mut p &int) u32 {
	a := u32(bytes[*p])
	b := u32(bytes[*p + 1])
	c := u32(bytes[*p + 2])
	d := u32(bytes[*p + 3])
	unsafe {
		*p = *p + 4
	}
	return a << 24 | b << 16 | c << 8 | d
}
