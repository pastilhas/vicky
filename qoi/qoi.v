module qoi

pub enum Colorspace as u8 {
	srgb
	linear
}

pub enum Channels as u8 {
	rgb  = 3
	rgba = 4
}

pub struct Config {
	width      u32
	height     u32
	channels   Channels
	colorspace Colorspace
}

pub fn Config.new(w u32, h u32, ch u8, cs u8) Config {
	return Config{w, h, unsafe { Channels(ch) }, unsafe { Colorspace(cs) }}
}

struct RGBA {
	r u8
	g u8
	b u8
	a u8 = 0
}

union Pixel {
	RGBA
	value u32
}

const op_index = u8(0x00)
const op_diff = u8(0x40)
const op_luma = u8(0x80)
const op_run = u8(0xc0)
const op_rgb = u8(0xfe)
const op_rgba = u8(0xff)
const mask_2 = u8(0xc0)
const magic = u32(0x716f6966)
const header_size = u32(14)
const max_pixels = u32(400_000_000)
const padding = [u8(0), 0, 0, 0, 0, 0, 0, 1]

fn write_32(mut bytes []u8, mut p &int, v u32) {
	bytes[*p] = u8((v >> 24) & 0x000000ff)
	bytes[*p + 1] = u8((v >> 16) & 0x000000ff)
	bytes[*p + 2] = u8((v >> 8) & 0x000000ff)
	bytes[*p + 3] = u8(v & 0x000000ff)
	unsafe {
		*p = *p + 4
	}
}

fn write_8(mut bytes []u8, mut p &int, v u8) {
	bytes[*p] = u8(v & 0x000000ff)
	unsafe {
		*p = *p + 1
	}
}

fn read_32(bytes []u8, mut p &int) u32 {
	a := u32(bytes[*p])
	b := u32(bytes[*p + 1])
	c := u32(bytes[*p + 2])
	d := u32(bytes[*p + 3])
	unsafe {
		*p = *p + 4
	}
	return a << 24 | b << 16 | c << 8 | d
}

fn read_32(bytes []u8, mut p &int) u8 {
	a := u32(bytes[*p])
	unsafe {
		*p = *p + 1
	}
	return a
}

fn hash(pix Pixel) int {
	return int(pix.r) * 3 + int(pix.g) * 5 + int(pix.b) * 7 + int(pix.a) * 11
}
